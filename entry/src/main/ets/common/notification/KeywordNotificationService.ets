import { notificationManager } from '@kit.NotificationKit';
import { preferences } from '@kit.ArkData';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Context } from '@kit.AbilityKit';
import { wantAgent, WantAgent } from '@kit.AbilityKit';
import { NewsItem } from '../models/NewsItem';

export class KeywordNotificationService {
  private static readonly PREF_NAME = 'BriefPreferences';
  private static readonly KEY_NOTIFIED_IDS = 'notified_news_ids';
  private static readonly MAX_NOTIFIED_IDS = 1000;
  private static readonly NOTIFICATION_SLOT_ID = 'keyword_alerts';
  
  private static prefsStore: preferences.Preferences | null = null;
  private static notifiedIds: Set<string> = new Set();
  private static initialized: boolean = false;
  private static context: Context | null = null;

  static async init(context: Context): Promise<void> {
    if (this.initialized) {
      return;
    }

    this.context = context;

    try {
      // Initialize preferences
      this.prefsStore = await preferences.getPreferences(context, this.PREF_NAME);
      await this.loadNotifiedIds();

      // Create notification slot
      await this.createNotificationSlot();

      // Request notification enable if not already enabled
      await this.requestNotificationEnable();

      this.initialized = true;
      hilog.info(0x0000, 'KeywordNotificationService', 'Initialized successfully');
    } catch (err) {
      hilog.error(0x0000, 'KeywordNotificationService', 'Failed to init: %{public}s', JSON.stringify(err));
    }
  }

  private static async createNotificationSlot(): Promise<void> {
    try {
      const notificationSlot: notificationManager.NotificationSlot = {
        type: notificationManager.SlotType.SOCIAL_COMMUNICATION,
        slotId: this.NOTIFICATION_SLOT_ID,
        level: notificationManager.SlotLevel.LEVEL_HIGH,
        desc: '关键词匹配通知',
        badgeFlag: true,
        bypassDnd: false,
        lockscreenVisibility: notificationManager.BundleOption.NOTIFICATION_CONTENT_PRESENT,
        vibrationEnabled: true,
        sound: '',
        lightEnabled: false,
        lightColor: 0
      };

      await notificationManager.addSlot(notificationSlot);
      hilog.info(0x0000, 'KeywordNotificationService', 'Notification slot created');
    } catch (err) {
      hilog.error(0x0000, 'KeywordNotificationService', 'Failed to create slot: %{public}s', JSON.stringify(err));
    }
  }

  private static async requestNotificationEnable(): Promise<void> {
    try {
      const isEnabled = await notificationManager.isNotificationEnabled();
      if (!isEnabled) {
        hilog.warn(0x0000, 'KeywordNotificationService', 'Notifications are disabled');
        // Note: In HarmonyOS, apps cannot directly enable notifications
        // User must enable via system settings
      } else {
        hilog.info(0x0000, 'KeywordNotificationService', 'Notifications are enabled');
      }
    } catch (err) {
      hilog.error(0x0000, 'KeywordNotificationService', 'Failed to check notification status: %{public}s', JSON.stringify(err));
    }
  }

  private static async loadNotifiedIds(): Promise<void> {
    try {
      if (!this.prefsStore) {
        return;
      }

      const savedIds = await this.prefsStore.get(this.KEY_NOTIFIED_IDS, '[]');
      const idsArray = JSON.parse(savedIds as string) as string[];
      this.notifiedIds = new Set(idsArray);
      
      hilog.info(0x0000, 'KeywordNotificationService', 'Loaded %{public}d notified IDs', this.notifiedIds.size);
    } catch (err) {
      hilog.error(0x0000, 'KeywordNotificationService', 'Failed to load notified IDs: %{public}s', JSON.stringify(err));
      this.notifiedIds = new Set();
    }
  }

  private static async saveNotifiedIds(): Promise<void> {
    try {
      if (!this.prefsStore) {
        return;
      }

      // Keep only last MAX_NOTIFIED_IDS items
      const idsArray = Array.from(this.notifiedIds);
      if (idsArray.length > this.MAX_NOTIFIED_IDS) {
        const trimmedIds = idsArray.slice(idsArray.length - this.MAX_NOTIFIED_IDS);
        this.notifiedIds = new Set(trimmedIds);
      }

      await this.prefsStore.put(this.KEY_NOTIFIED_IDS, JSON.stringify(Array.from(this.notifiedIds)));
      await this.prefsStore.flush();
    } catch (err) {
      hilog.error(0x0000, 'KeywordNotificationService', 'Failed to save notified IDs: %{public}s', JSON.stringify(err));
    }
  }

  static async notifyNewMatches(matches: NewsItem[]): Promise<void> {
    if (!this.initialized || !this.context) {
      hilog.warn(0x0000, 'KeywordNotificationService', 'Service not initialized');
      return;
    }

    try {
      // Filter out already notified items
      const newMatches = matches.filter(item => !this.notifiedIds.has(item.id));

      if (newMatches.length === 0) {
        hilog.info(0x0000, 'KeywordNotificationService', 'No new matches to notify');
        return;
      }

      hilog.info(0x0000, 'KeywordNotificationService', 'Found %{public}d new matches', newMatches.length);

      // Notify for each new match (async, but don't wait)
      for (const item of newMatches) {
        this.publishNotification(item).catch(err => {
          hilog.error(0x0000, 'KeywordNotificationService', 
            'Failed to publish notification for %{public}s: %{public}s', item.id, JSON.stringify(err));
        });
        
        // Mark as notified
        this.notifiedIds.add(item.id);
      }

      // Save updated notified IDs
      await this.saveNotifiedIds();
    } catch (err) {
      hilog.error(0x0000, 'KeywordNotificationService', 'Error in notifyNewMatches: %{public}s', JSON.stringify(err));
    }
  }

  private static async publishNotification(item: NewsItem): Promise<void> {
    try {
      if (!this.context) {
        return;
      }

      // Create want agent for deep linking
      const wantAgentInfo: wantAgent.WantAgentInfo = {
        wants: [
          {
            bundleName: this.context.abilityInfo.bundleName,
            abilityName: 'EntryAbility',
            parameters: {
              routerUrl: 'pages/WebViewPage',
              url: item.mobileUrl || item.url,
              title: item.title
            }
          }
        ],
        requestCode: 0,
        operationType: wantAgent.OperationType.START_ABILITY,
        wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
      };

      const wantAgentObj: WantAgent = await wantAgent.getWantAgent(wantAgentInfo);

      // Build notification content
      const sourceInfo = item.extra?.info && typeof item.extra.info === 'string' ? item.extra.info : '新闻';
      
      const notificationRequest: notificationManager.NotificationRequest = {
        id: Date.now(),
        slotType: notificationManager.SlotType.SOCIAL_COMMUNICATION,
        content: {
          notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: {
            title: '关键词匹配',
            text: item.title,
            additionalText: sourceInfo
          }
        },
        actionButtons: [],
        wantAgent: wantAgentObj,
        showDeliveryTime: true,
        deliveryTime: new Date().getTime(),
        tapDismissed: true,
        autoDeletedTime: 0,
        color: 0,
        colorEnabled: false,
        isAlertOnce: false,
        isStopwatch: false,
        isCountDown: false,
        showStopwatch: false,
        groupName: '',
        isRemoveAllowed: true,
        badge: null,
        notificationFlags: null,
        extraInfo: null
      };

      await notificationManager.publish(notificationRequest);
      hilog.info(0x0000, 'KeywordNotificationService', 'Published notification for: %{public}s', item.title);
    } catch (err) {
      hilog.error(0x0000, 'KeywordNotificationService', 'Failed to publish notification: %{public}s', JSON.stringify(err));
      throw err;
    }
  }

  static isInitialized(): boolean {
    return this.initialized;
  }

  static async clearNotifiedIds(): Promise<void> {
    this.notifiedIds.clear();
    await this.saveNotifiedIds();
    hilog.info(0x0000, 'KeywordNotificationService', 'Cleared all notified IDs');
  }
}
