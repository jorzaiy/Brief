import http from '@ohos.net.http';
import { NewsItem, SourceItem, SourceResponse } from '../models/NewsItem';
import { hilog } from '@kit.PerformanceAnalysisKit';

export interface ApiConfig {
  baseUrl: string;
  defaultSourceId: string;
}

let configData: ApiConfig | null = null;

export class NewsService {
  private static readonly DEFAULT_TIMEOUT = 10000;
  private static readonly DEFAULT_BASE_URL = 'https://newsnow-api.example.com';
  private static readonly DEFAULT_SOURCE_ID = 'source_1';

  static setConfig(config: ApiConfig): void {
    configData = config;
  }

  static getConfig(): ApiConfig {
    return configData || {
      baseUrl: this.DEFAULT_BASE_URL,
      defaultSourceId: this.DEFAULT_SOURCE_ID
    };
  }

  static async fetchNews(sourceId?: string): Promise<NewsItem[]> {
    try {
      const config = this.getConfig();
      const actualSourceId = sourceId || config.defaultSourceId;
      const apiUrl = `${config.baseUrl}/api/s?id=${actualSourceId}`;

      hilog.info(0x0000, 'NewsService', `Fetching news from: ${apiUrl}`);

      const httpRequest = http.createHttp();
      const response = await httpRequest.request(
        apiUrl,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json'
          },
          readTimeout: this.DEFAULT_TIMEOUT,
          connectTimeout: this.DEFAULT_TIMEOUT
        }
      );

      httpRequest.destroy();

      if (response.responseCode === 200 && response.result) {
        const responseData = typeof response.result === 'string'
          ? JSON.parse(response.result)
          : response.result;

        return this.parseResponse(responseData);
      } else {
        throw new Error(`HTTP Error: ${response.responseCode}`);
      }
    } catch (error) {
      hilog.error(0x0000, 'NewsService', 'Failed to fetch news: %{public}s', JSON.stringify(error));
      throw error;
    }
  }

  private static parseResponse(responseData: SourceResponse): NewsItem[] {
    let items: SourceItem[] = [];

    // Try different possible response structures
    if (Array.isArray(responseData)) {
      items = responseData;
    } else if (responseData.items && Array.isArray(responseData.items)) {
      items = responseData.items;
    } else if (responseData.data && Array.isArray(responseData.data)) {
      items = responseData.data;
    } else if (responseData.news && Array.isArray(responseData.news)) {
      items = responseData.news;
    } else if (responseData.articles && Array.isArray(responseData.articles)) {
      items = responseData.articles;
    }

    return items.map(item => new NewsItem(item));
  }
}
