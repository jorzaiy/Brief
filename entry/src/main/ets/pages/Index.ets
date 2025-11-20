import { NewsItem } from '../common/models/NewsItem';
import { NewsService } from '../common/network/newsService';
import { ChannelManager, Channel } from '../common/models/ChannelManager';
import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { KeywordNotificationService } from '../common/notification/KeywordNotificationService';
import { KeywordManager } from '../common/models/KeywordManager';
import { KeywordMatcher } from '../common/utils/KeywordMatcher';

@Entry
@Component
struct Index {
  @State currentChannelIndex: number = 0;
  @State channels: Channel[] = [];
  @State newsItems: NewsItem[] = [];
  @State loading: boolean = false;
  @State error: string = '';
  @StorageLink('user_keywords') @Watch('onKeywordsChange') keywords: string[] = KeywordManager.getKeywords();
  @State allNewsItems: NewsItem[] = []; // Raw news data before filtering

  aboutToAppear() {
    this.channels = ChannelManager.getChannels();
    this.loadChannelNews();
  }

  // Filter news items based on keywords for Follow channel
  private filterNewsByKeywords(newsItems: NewsItem[]): NewsItem[] {
    const currentChannel = this.channels[this.currentChannelIndex];
    
    // Only filter Follow channel, leave Hot/Realtimes untouched
    if (currentChannel.type !== 'followed') {
      return newsItems;
    }

    // If no keywords, return empty array for Follow channel
    if (!this.keywords || this.keywords.length === 0) {
      hilog.info(0x0000, 'Index', 'No keywords configured for Follow channel, showing empty state');
      return [];
    }

    // Filter using KeywordMatcher
    const filteredItems = KeywordMatcher.filterByKeywords(newsItems, this.keywords);
    hilog.info(0x0000, 'Index', `Follow channel: ${newsItems.length} total items -> ${filteredItems.length} filtered items`);
    
    return filteredItems;
  }

  // Watch for keyword changes and re-filter
  onKeywordsChange() {
    const currentChannel = this.channels[this.currentChannelIndex];
    if (currentChannel.type === 'followed' && this.allNewsItems.length > 0) {
      hilog.info(0x0000, 'Index', 'Keywords changed, re-filtering Follow channel');
      this.newsItems = this.filterNewsByKeywords(this.allNewsItems);
    }
  }

  async loadChannelNews() {
    if (this.loading) {
      return;
    }

    this.loading = true;
    this.error = '';

    try {
      const currentChannel = this.channels[this.currentChannelIndex];
      hilog.info(0x0000, 'Index', `Loading channel: ${currentChannel.name}`);

      // 获取当前频道的所有数据源
      const sourceResults = await NewsService.fetchMultipleSources(currentChannel.sourceIds);

      // 合并所有数据源的新闻
      const allNews: NewsItem[] = [];
      sourceResults.forEach((items) => {
        allNews.push(...items);
      });

      // 按时间排序
      allNews.sort((a, b) => b.pubDate - a.pubDate);

      // Store raw data (for re-filtering when keywords change)
      this.allNewsItems = allNews.slice(0, 50);

      // Apply keyword filtering for Follow channel
      this.newsItems = this.filterNewsByKeywords(this.allNewsItems);
      
      this.loading = false;

      hilog.info(0x0000, 'Index', `Loaded ${this.newsItems.length} news items (filtered from ${this.allNewsItems.length} total)`);

      // Check for keyword matches in Follow channel and send notifications
      if (currentChannel.type === 'followed' && this.newsItems.length > 0) {
        this.checkAndNotifyKeywordMatches(this.newsItems);
      }
    } catch (err) {
      this.loading = false;
      this.error = err instanceof Error ? err.message : '加载失败';
      hilog.error(0x0000, 'Index', 'Error loading news: %{public}s', this.error);
    }
  }

  private checkAndNotifyKeywordMatches(newsItems: NewsItem[]) {
    // Run async in background to not block UI
    setTimeout(async () => {
      try {
        if (!KeywordNotificationService.isInitialized()) {
          hilog.warn(0x0000, 'Index', 'Notification service not initialized yet');
          return;
        }

        // Filter news items that match keywords
        const matches = newsItems.filter(item => {
          const titleMatch = KeywordManager.matchesKeyword(item.title);
          const descMatch = item.description ? KeywordManager.matchesKeyword(item.description) : false;
          return titleMatch || descMatch;
        });

        if (matches.length > 0) {
          hilog.info(0x0000, 'Index', `Found ${matches.length} keyword matches`);
          await KeywordNotificationService.notifyNewMatches(matches);
        }
      } catch (err) {
        hilog.error(0x0000, 'Index', 'Error checking keyword matches: %{public}s', JSON.stringify(err));
      }
    }, 0);
  }

  onChannelChange(index: number) {
    if (this.currentChannelIndex !== index) {
      this.currentChannelIndex = index;
      this.newsItems = [];
      this.allNewsItems = [];
      this.loadChannelNews();
    }
  }

  openArticle(item: NewsItem) {
    try {
      router.pushUrl({
        url: 'pages/WebViewPage',
        params: {
          url: item.mobileUrl || item.url,
          title: item.title
        }
      });
    } catch (error) {
      hilog.error(0x0000, 'Index', 'Failed to open article: %{public}s', JSON.stringify(error));
    }
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('Brief')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#000000')

        Blank()

        Button('刷新')
          .fontSize(14)
          .backgroundColor('#f0f0f0')
          .fontColor('#333333')
          .onClick(() => this.loadChannelNews())
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#ffffff')

      // 频道切换Tab
      Tabs({ index: this.currentChannelIndex }) {
        ForEach(this.channels, (channel: Channel, index: number) => {
          TabContent() {
            if (this.loading) {
              Column() {
                LoadingProgress()
                  .width(50)
                  .height(50)
                  .color('#1890ff')

                Text('加载中...')
                  .fontSize(14)
                  .fontColor('#999999')
                  .margin({ top: 16 })
              }
              .width('100%')
              .height('100%')
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
            } else if (this.error) {
              Column() {
                Text('⚠️')
                  .fontSize(48)
                  .margin({ bottom: 16 })

                Text(this.error)
                  .fontSize(14)
                  .fontColor('#999999')
                  .textAlign(TextAlign.Center)
                  .margin({ bottom: 16 })

                Button('重试')
                  .onClick(() => this.loadChannelNews())
              }
              .width('100%')
              .height('100%')
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .padding(16)
            } else if (this.newsItems.length === 0) {
              const currentChannel = this.channels[this.currentChannelIndex];
              if (currentChannel.type === 'followed') {
                // Special empty states for Follow channel
                if (!this.keywords || this.keywords.length === 0) {
                  Column() {
                    Text('📝')
                      .fontSize(48)
                      .margin({ bottom: 16 })

                    Text('暂无关键词')
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#333333')
                      .margin({ bottom: 8 })

                    Text('配置关键词以筛选关注内容')
                      .fontSize(14)
                      .fontColor('#999999')
                      .textAlign(TextAlign.Center)
                  }
                  .width('100%')
                  .height('100%')
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
                  .padding(16)
                } else {
                  Column() {
                    Text('🔍')
                      .fontSize(48)
                      .margin({ bottom: 16 })

                    Text('暂无匹配内容')
                      .fontSize(16)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#333333')
                      .margin({ bottom: 8 })

                    Text(`未找到包含关键词 "${this.keywords.slice(0, 3).join('", "')}"${this.keywords.length > 3 ? ' 等' : ''} 的内容`)
                      .fontSize(14)
                      .fontColor('#999999')
                      .textAlign(TextAlign.Center)
                      .margin({ bottom: 16 })

                    Button('刷新')
                      .fontSize(14)
                      .backgroundColor('#f0f0f0')
                      .fontColor('#333333')
                      .onClick(() => this.loadChannelNews())
                  }
                  .width('100%')
                  .height('100%')
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
                  .padding(16)
                }
              } else {
                Column() {
                  Text('暂无内容')
                    .fontSize(16)
                    .fontColor('#999999')
                }
                .width('100%')
                .height('100%')
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
              }
            } else {
              NewsList({
                newsItems: this.newsItems,
                onItemClick: (item: NewsItem): void => this.openArticle(item)
              })
            }
          }
          .tabBar(channel.name)
        }, (channel: Channel) => channel.id)
      }
      .width('100%')
      .layoutWeight(1)
      .barMode(BarMode.Fixed)
      .onChange((index: number) => this.onChannelChange(index))
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}

@Component
struct NewsList {
  @Prop newsItems: NewsItem[];
  onItemClick: (item: NewsItem) => void = () => {
  };

  build() {
    List({ space: 8 }) {
      ForEach(this.newsItems, (item: NewsItem) => {
        ListItem() {
          NewsItemRow({
            newsItem: item
          })
            .onClick(() => this.onItemClick(item))
        }
      }, (item: NewsItem) => item.id)
    }
    .width('100%')
    .height('100%')
    .padding({
      left: 12,
      right: 12,
      top: 8,
      bottom: 8
    })
    .scrollBar(BarState.Auto)
  }
}

@Component
struct NewsItemRow {
  @Prop newsItem: NewsItem;
  private onClickCallback: () => void = () => {
  };

  build() {
    Column() {
      Text(this.newsItem.title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#000000')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .lineHeight(22)
        .margin({ bottom: 8 })
      
      // Show matched keywords if available
      if (this.newsItem.matchedKeywords && this.newsItem.matchedKeywords.length > 0) {
        Row() {
          ForEach(this.newsItem.matchedKeywords.slice(0, 3), (keyword: string) => {
            Text(keyword)
              .fontSize(10)
              .fontColor('#1890ff')
              .backgroundColor('#e6f7ff')
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(4)
              .margin({ right: 6, bottom: 6 })
          }, (keyword: string) => keyword)
        }
        .width('100%')
        .margin({ bottom: 4 })
      }
      
      Row() {
        if (this.newsItem.extra?.info && typeof this.newsItem.extra.info === 'string') {
          Text(this.newsItem.extra.info)
            .fontSize(12)
            .fontColor('#999999')
            .margin({ right: 8 })
        }

        Blank()

        Text(this.newsItem.getFormattedTime())
          .fontSize(12)
          .fontColor('#999999')
      }
      .width('100%')
    }
    .width('100%')
    .backgroundColor('#ffffff')
    .borderRadius(8)
    .padding(12)
    .onClick(() => {
      this.onClickCallback();
    })
  }
}

