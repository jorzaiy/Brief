import { NewsService } from '../common/network/newsService';
import { NewsItem } from '../common/models/NewsItem';
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct NewsList {
  @State newsItems: NewsItem[] = [];
  @State isLoading: boolean = false;
  @State errorMessage: string = '';
  @State retryCount: number = 0;
  @State sourceId: string = '';

  aboutToAppear(): void {
    this.loadNews();
  }

  loadNews(): void {
    this.isLoading = true;
    this.errorMessage = '';
    
    NewsService.fetchNews(this.sourceId)
      .then((items: NewsItem[]) => {
        this.newsItems = items;
        this.isLoading = false;
        this.retryCount = 0;
      })
      .catch((error: Error) => {
        this.isLoading = false;
        this.errorMessage = `Failed to load news: ${error.message}`;
        hilog.error(0x0000, 'NewsList', 'Error loading news: %{public}s', JSON.stringify(error));
        this.showErrorToast(this.errorMessage);
      });
  }

  showErrorToast(message: string): void {
    promptAction.showToast({
      message: message,
      duration: 2000
    });
  }

  openArticle(url: string): void {
    if (!url) {
      this.showErrorToast('No URL available for this article');
      return;
    }

    try {
      router.pushUrl({
        url: 'pages/WebViewPage',
        params: {
          url: url
        }
      });
    } catch (error) {
      hilog.error(0x0000, 'NewsList', 'Failed to open article: %{public}s', JSON.stringify(error));
      this.showErrorToast('Failed to open article');
    }
  }

  onRetry(): void {
    this.retryCount++;
    if (this.retryCount <= 3) {
      this.loadNews();
    } else {
      this.showErrorToast('Max retries exceeded');
    }
  }

  build() {
    Column() {
      Row() {
        Text('News Feed')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16 })

        Blank()

        Button('Refresh')
          .onClick(() => this.loadNews())
          .margin({ right: 16 })
      }
      .width('100%')
      .height(56)
      .backgroundColor($r('app.color.start_window_background'))

      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
          Text('Loading news...')
            .margin({ top: 16 })
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(ItemAlign.Center)
        .width('100%')
        .height('100%')
      } else if (this.errorMessage) {
        Column() {
          Text('⚠️')
            .fontSize(48)
            .margin({ bottom: 16 })
          
          Text(this.errorMessage)
            .fontSize(14)
            .textAlign(TextAlign.Center)
            .margin({ bottom: 16, left: 16, right: 16 })
          
          Button('Retry')
            .onClick(() => this.onRetry())
            .margin({ bottom: 16 })
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(ItemAlign.Center)
        .width('100%')
        .height('100%')
        .padding(16)
      } else if (this.newsItems.length === 0) {
        Column() {
          Text('No news available')
            .fontSize(16)
            .fontColor(Color.Gray)
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(ItemAlign.Center)
        .width('100%')
        .height('100%')
      } else {
        List() {
          ForEach(this.newsItems, (item: NewsItem) => {
            ListItem() {
              Column() {
                Text(item.title)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .margin({ bottom: 8 })

                if (item.description) {
                  Text(item.description)
                    .fontSize(14)
                    .fontColor(Color.Gray)
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .margin({ bottom: 8 })
                }

                Row() {
                  if (item.author) {
                    Text(`By ${item.author}`)
                      .fontSize(12)
                      .fontColor(Color.Gray)
                  }

                  Blank()

                  if (item.pubDate) {
                    Text(this.formatDate(item.pubDate))
                      .fontSize(12)
                      .fontColor(Color.Gray)
                  }
                }
                .width('100%')
              }
              .width('100%')
              .padding(16)
              .backgroundColor(Color.White)
              .borderRadius(8)
              .margin({ bottom: 8 })
            }
            .onClick(() => this.openArticle(item.link))
          }, (item: NewsItem) => item.id)
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 8, right: 8, top: 8, bottom: 8 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  private formatDate(dateString: string): string {
    try {
      const date = new Date(dateString);
      const now = new Date();
      const diffMs = now.getTime() - date.getTime();
      const diffMins = Math.floor(diffMs / (1000 * 60));
      const diffHours = Math.floor(diffMs / (1000 * 60 * 60));
      const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));

      if (diffMins < 1) {
        return 'Just now';
      } else if (diffMins < 60) {
        return `${diffMins}m ago`;
      } else if (diffHours < 24) {
        return `${diffHours}h ago`;
      } else if (diffDays < 7) {
        return `${diffDays}d ago`;
      } else {
        return date.toLocaleDateString();
      }
    } catch {
      return dateString;
    }
  }
}
