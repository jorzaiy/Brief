export interface SourceItem {
  id: string;
  title: string;
  description?: string;
  link?: string;
  pubDate?: string;
  updatedTime?: string;
  author?: string;
  category?: string;
}

export class NewsItem {
  id: string;
  title: string;
  description: string;
  link: string;
  pubDate: string;
  author: string;
  category: string;

  constructor(source: SourceItem) {
    this.id = source.id || '';
    this.title = source.title || '';
    this.description = source.description || '';
    this.link = source.link || '';
    // Fallback to updatedTime if pubDate is missing
    this.pubDate = source.pubDate || source.updatedTime || new Date().toISOString();
    this.author = source.author || '';
    this.category = source.category || '';
  }
}

export interface SourceResponse {
  items?: SourceItem[];
  data?: SourceItem[];
  news?: SourceItem[];
  articles?: SourceItem[];
}
