import http from '@ohos.net.http';
import { NewsItem, SourceResponse } from '../models/NewsItem';
import { hilog } from '@kit.PerformanceAnalysisKit';

export interface ApiConfig {
  baseUrl: string;
  defaultSourceId: string;
}

let configData: ApiConfig | null = null;

export class NewsService {
  private static readonly DEFAULT_TIMEOUT = 15000;
  private static readonly DEFAULT_BASE_URL = 'https://newsnow-opal.vercel.app';
  private static readonly DEFAULT_SOURCE_ID = 'zhihu';

  static setConfig(config: ApiConfig): void {
    configData = config;
    hilog.info(0x0000, 'NewsService', `Config updated: ${JSON.stringify(config)}`);
  }

  static getConfig(): ApiConfig {
    return configData || {
      baseUrl: NewsService.DEFAULT_BASE_URL,
      defaultSourceId: NewsService.DEFAULT_SOURCE_ID
    };
  }

  static async fetchNews(sourceId?: string): Promise<NewsItem[]> {
    try {
      const config = NewsService.getConfig();
      const actualSourceId = sourceId || config.defaultSourceId;
      const apiUrl = `${config.baseUrl}/api/s?id=${actualSourceId}`;

      hilog.info(0x0000, 'NewsService', `Fetching news from: ${apiUrl}`);

      const httpRequest = http.createHttp();
      const response = await httpRequest.request(
        apiUrl,
        {
          method: http.RequestMethod.GET,
          header: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          readTimeout: NewsService.DEFAULT_TIMEOUT,
          connectTimeout: NewsService.DEFAULT_TIMEOUT
        }
      );

      httpRequest.destroy();

      hilog.info(0x0000, 'NewsService', `Response code: ${response.responseCode}`);

      if (response.responseCode === 200 && response.result) {
        const responseData: SourceResponse = typeof response.result === 'string'
          ? JSON.parse(response.result) as SourceResponse
          : response.result as SourceResponse;

        hilog.info(0x0000, 'NewsService', `Response status: ${responseData.status}, items: ${responseData.items?.length || 0}`);

        return NewsService.parseResponse(responseData);
      } else {
        throw new Error(`HTTP Error: ${response.responseCode}`);
      }
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      hilog.error(0x0000, 'NewsService', 'Failed to fetch news: %{public}s', errorMessage);
      throw new Error(`Failed to fetch news: ${errorMessage}`);
    }
  }

  private static parseResponse(responseData: SourceResponse): NewsItem[] {
    if (!responseData.items || !Array.isArray(responseData.items)) {
      hilog.warn(0x0000, 'NewsService', 'No items in response');
      return [];
    }

    return responseData.items.map(item => new NewsItem(item));
  }
  
  // 获取多个数据源的新闻
  static async fetchMultipleSources(sourceIds: string[]): Promise<Map<string, NewsItem[]>> {
    const results = new Map<string, NewsItem[]>();
    
    for (const sourceId of sourceIds) {
      try {
        const items = await NewsService.fetchNews(sourceId);
        results.set(sourceId, items);
      } catch (error) {
        hilog.error(0x0000, 'NewsService', `Failed to fetch ${sourceId}: %{public}s`, 
          error instanceof Error ? error.message : 'Unknown error');
        results.set(sourceId, []);
      }
    }
    
    return results;
  }
}
