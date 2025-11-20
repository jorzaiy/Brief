import { preferences } from '@kit.ArkData';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Context } from '@kit.AbilityKit';

export class KeywordManager {
  private static readonly PREF_NAME = 'BriefPreferences';
  private static readonly KEY_KEYWORDS = 'user_keywords';
  private static readonly DEFAULT_KEYWORDS = ['HarmonyOS', '鸿蒙', 'OpenHarmony', 'AI', '人工智能'];
  
  private static keywords: string[] = [];
  private static prefsStore: preferences.Preferences | null = null;
  private static initialized: boolean = false;

  static async init(context: Context): Promise<void> {
    if (this.initialized) {
      return;
    }

    try {
      this.prefsStore = await preferences.getPreferences(context, this.PREF_NAME);
      await this.loadKeywords();
      this.initialized = true;
      hilog.info(0x0000, 'KeywordManager', 'Initialized with keywords: %{public}s', JSON.stringify(this.keywords));
    } catch (err) {
      hilog.error(0x0000, 'KeywordManager', 'Failed to init: %{public}s', JSON.stringify(err));
      this.keywords = [...this.DEFAULT_KEYWORDS];
    }
  }

  private static async loadKeywords(): Promise<void> {
    try {
      if (!this.prefsStore) {
        this.keywords = [...this.DEFAULT_KEYWORDS];
        return;
      }

      const savedKeywords = await this.prefsStore.get(this.KEY_KEYWORDS, JSON.stringify(this.DEFAULT_KEYWORDS));
      this.keywords = JSON.parse(savedKeywords as string);
      
      if (!Array.isArray(this.keywords) || this.keywords.length === 0) {
        this.keywords = [...this.DEFAULT_KEYWORDS];
      }
    } catch (err) {
      hilog.error(0x0000, 'KeywordManager', 'Failed to load keywords: %{public}s', JSON.stringify(err));
      this.keywords = [...this.DEFAULT_KEYWORDS];
    }
  }

  static async saveKeywords(): Promise<void> {
    try {
      if (!this.prefsStore) {
        return;
      }
      await this.prefsStore.put(this.KEY_KEYWORDS, JSON.stringify(this.keywords));
      await this.prefsStore.flush();
      hilog.info(0x0000, 'KeywordManager', 'Keywords saved: %{public}s', JSON.stringify(this.keywords));
    } catch (err) {
      hilog.error(0x0000, 'KeywordManager', 'Failed to save keywords: %{public}s', JSON.stringify(err));
    }
  }

  static getKeywords(): string[] {
    return [...this.keywords];
  }

  static async addKeyword(keyword: string): Promise<void> {
    if (keyword && !this.keywords.includes(keyword)) {
      this.keywords.push(keyword);
      await this.saveKeywords();
    }
  }

  static async removeKeyword(keyword: string): Promise<void> {
    const index = this.keywords.indexOf(keyword);
    if (index > -1) {
      this.keywords.splice(index, 1);
      await this.saveKeywords();
    }
  }

  static async setKeywords(keywords: string[]): Promise<void> {
    this.keywords = keywords;
    await this.saveKeywords();
  }

  static matchesKeyword(text: string): boolean {
    if (!text) {
      return false;
    }
    
    const lowerText = text.toLowerCase();
    return this.keywords.some(keyword => 
      lowerText.includes(keyword.toLowerCase())
    );
  }
}
