import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window, router } from '@kit.ArkUI';
import { KeywordNotificationService } from '../common/notification/KeywordNotificationService';
import { KeywordManager } from '../common/models/KeywordManager';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  private pendingNavigation: { routerUrl: string; url?: string; title?: string } | null = null;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');

    // Initialize notification service and keyword manager
    KeywordNotificationService.init(this.context).catch(err => {
      hilog.error(DOMAIN, 'testTag', 'Failed to init notification service: %{public}s', JSON.stringify(err));
    });

    KeywordManager.init(this.context).catch(err => {
      hilog.error(DOMAIN, 'testTag', 'Failed to init keyword manager: %{public}s', JSON.stringify(err));
    });

    this.captureNavigationFromWant(want);
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
      this.navigateToPendingArticle();
    });
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onNewWant');
    this.captureNavigationFromWant(want);
    this.navigateToPendingArticle();
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }

  private captureNavigationFromWant(want: Want): void {
    if (want.parameters && want.parameters['routerUrl']) {
      const routerUrl = want.parameters['routerUrl'] as string;
      const url = want.parameters['url'] as string;
      const title = want.parameters['title'] as string;
      
      this.pendingNavigation = {
        routerUrl: routerUrl,
        url: url,
        title: title
      };
      
      hilog.info(DOMAIN, 'testTag', 'Captured navigation to: %{public}s', routerUrl);
    }
  }

  private navigateToPendingArticle(): void {
    if (this.pendingNavigation) {
      const nav = this.pendingNavigation;
      this.pendingNavigation = null;
      
      hilog.info(DOMAIN, 'testTag', 'Navigating to pending article: %{public}s', nav.routerUrl);
      
      setTimeout(() => {
        try {
          router.pushUrl({
            url: nav.routerUrl,
            params: {
              url: nav.url,
              title: nav.title
            }
          });
        } catch (err) {
          hilog.error(DOMAIN, 'testTag', 'Failed to navigate: %{public}s', JSON.stringify(err));
        }
      }, 500);
    }
  }
}