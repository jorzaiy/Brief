import { NewsItem } from '../models/NewsItem';
import { hilog } from '@kit.PerformanceAnalysisKit';

export interface KeywordMatchResult {
  matches: boolean;
  matchedKeywords: string[];
}

export class KeywordMatcher {
  /**
   * Check if a news item matches any of the provided keywords
   * @param newsItem The news item to check
   * @param keywords Array of keywords to match against
   * @returns KeywordMatchResult with match status and matched keywords
   */
  static matchesKeywords(newsItem: NewsItem, keywords: string[]): KeywordMatchResult {
    if (!keywords || keywords.length === 0) {
      return { matches: false, matchedKeywords: [] };
    }

    const matchedKeywords: string[] = [];
    const lowerKeywords = keywords.map(k => k.toLowerCase());

    // Check title
    if (newsItem.title) {
      const titleLower = newsItem.title.toLowerCase();
      lowerKeywords.forEach(keyword => {
        if (titleLower.includes(keyword)) {
          matchedKeywords.push(keyword);
        }
      });
    }

    // Check description
    if (newsItem.description) {
      const descLower = newsItem.description.toLowerCase();
      lowerKeywords.forEach(keyword => {
        if (descLower.includes(keyword) && !matchedKeywords.includes(keyword)) {
          matchedKeywords.push(keyword);
        }
      });
    }

    // Check extra.info
    if (newsItem.extra?.info && typeof newsItem.extra.info === 'string') {
      const infoLower = newsItem.extra.info.toLowerCase();
      lowerKeywords.forEach(keyword => {
        if (infoLower.includes(keyword) && !matchedKeywords.includes(keyword)) {
          matchedKeywords.push(keyword);
        }
      });
    }

    const result = {
      matches: matchedKeywords.length > 0,
      matchedKeywords: [...new Set(matchedKeywords)] // Remove duplicates
    };

    hilog.info(0x0000, 'KeywordMatcher', 
      `News "${newsItem.title.substring(0, 30)}..." - Matches: ${result.matches}, Keywords: [${result.matchedKeywords.join(', ')}]`);

    return result;
  }

  /**
   * Filter an array of news items by keywords
   * @param newsItems Array of news items to filter
   * @param keywords Array of keywords to filter by
   * @returns Filtered array with matched keywords attached to each item
   */
  static filterByKeywords(newsItems: NewsItem[], keywords: string[]): Array<NewsItem & { matchedKeywords: string[] }> {
    if (!keywords || keywords.length === 0) {
      hilog.info(0x0000, 'KeywordMatcher', 'No keywords provided, returning empty array');
      return [];
    }

    const filteredItems: Array<NewsItem & { matchedKeywords: string[] }> = [];
    
    newsItems.forEach(item => {
      const result = KeywordMatcher.matchesKeywords(item, keywords);
      if (result.matches) {
        // Create a new object with matchedKeywords property
        const itemWithMatches = Object.assign(item, { matchedKeywords: result.matchedKeywords });
        filteredItems.push(itemWithMatches);
      }
    });

    hilog.info(0x0000, 'KeywordMatcher', 
      `Filtered ${newsItems.length} items down to ${filteredItems.length} matches using [${keywords.join(', ')}]`);

    return filteredItems;
  }
}