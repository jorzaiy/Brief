// newsnow API 数据结构
export interface IconInfo {
  url: string;
  scale: number;
}

export interface NewsItemExtra {
  hover?: string;
  date?: number | string;
  info?: false | string;
  diff?: number;
  icon?: false | string | IconInfo;
}

export interface SourceItem {
  id: string | number;
  title: string;
  url: string;
  mobileUrl?: string;
  pubDate?: number | string;
  extra?: NewsItemExtra;
  description?: string;
  author?: string;
}

export class NewsItem {
  id: string;
  title: string;
  url: string;
  mobileUrl: string;
  pubDate: number;
  extra?: NewsItemExtra;
  description?: string;
  author?: string;
  matchedKeywords?: string[]; // Optional property to store matched keywords

  constructor(source: SourceItem) {
    this.id = String(source.id || '');
    this.title = source.title || '';
    this.url = source.url || '';
    this.mobileUrl = source.mobileUrl || source.url || '';

    // 处理 pubDate，可能是时间戳或字符串
    if (typeof source.pubDate === 'number') {
      this.pubDate = source.pubDate;
    } else if (typeof source.pubDate === 'string') {
      this.pubDate = new Date(source.pubDate).getTime();
    } else {
      this.pubDate = Date.now();
    }
    this.extra = source.extra;
    this.description = source.description;
    this.author = source.author;
  }

  // 格式化发布时间
  getFormattedTime(): string {
    const now = Date.now();
    const diff = now - this.pubDate;

    const seconds = Math.floor(diff / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);
    const days = Math.floor(hours / 24);

    if (seconds < 60) {
      return '刚刚';
    } else if (minutes < 60) {
      return `${minutes}分钟前`;
    } else if (hours < 24) {
      return `${hours}小时前`;
    } else if (days < 7) {
      return `${days}天前`;
    } else {
      const date = new Date(this.pubDate);
      return `${date.getMonth() + 1}-${date.getDate()}`;
    }
  }
}

export interface SourceResponse {
  status: 'success' | 'cache';
  id: string;
  updatedTime: number | string;
  items: SourceItem[];
}
