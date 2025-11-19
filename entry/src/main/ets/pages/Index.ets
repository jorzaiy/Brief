import { NewsItem } from '../common/models/NewsItem';
import { NewsService } from '../common/network/newsService';
import { ChannelManager, Channel } from '../common/models/ChannelManager';
import { router } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct Index {
  @State currentChannelIndex: number = 0;
  @State channels: Channel[] = [];
  @State newsItems: NewsItem[] = [];
  @State loading: boolean = false;
  @State error: string = '';

  aboutToAppear() {
    this.channels = ChannelManager.getChannels();
    this.loadChannelNews();
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

      // 取前50条
      this.newsItems = allNews.slice(0, 50);
      this.loading = false;

      hilog.info(0x0000, 'Index', `Loaded ${this.newsItems.length} news items`);
    } catch (err) {
      this.loading = false;
      this.error = err instanceof Error ? err.message : '加载失败';
      hilog.error(0x0000, 'Index', 'Error loading news: %{public}s', this.error);
    }
  }

  onChannelChange(index: number) {
    if (this.currentChannelIndex !== index) {
      this.currentChannelIndex = index;
      this.newsItems = [];
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
              Column() {
                Text('暂无内容')
                  .fontSize(16)
                  .fontColor('#999999')
              }
              .width('100%')
              .height('100%')
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
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

