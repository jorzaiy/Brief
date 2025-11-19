import { NewsItem } from '../models/NewsItem';

@Entry
@Component
struct Index {
  @State newsItems: NewsItem[] = [];
  @State loading: boolean = true;
  @State error: string = '';

  aboutToAppear() {
    this.loadNews();
  }

  loadNews() {
    this.loading = true;
    this.error = '';

    // Simulate loading news items
    setTimeout(() => {
      this.newsItems = [
        {
          id: '1',
          title: 'Breaking News: New Technology Breakthrough Announced Today',
          source: 'Tech Daily',
          publishTime: Date.now() - 3600000
        },
        {
          id: '2',
          title: 'Global Markets React to Economic Updates',
          source: 'Financial Times',
          publishTime: Date.now() - 7200000
        },
        {
          id: '3',
          title: 'Science Discovers New Species in Amazon',
          source: 'Nature Weekly',
          publishTime: Date.now() - 86400000
        },
        {
          id: '4',
          title: 'Sports Team Wins Championship After Thrilling Match',
          source: 'Sports News',
          publishTime: Date.now() - 172800000
        },
        {
          id: '5',
          title: 'Entertainment: New Film Breaks Box Office Records This Weekend',
          source: 'Entertainment Weekly',
          publishTime: Date.now() - 259200000
        }
      ];
      this.loading = false;
    }, 800);
  }

  formatPublishTime(timestamp: number): string {
    const now = Date.now();
    const diff = now - timestamp;

    const seconds = Math.floor(diff / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);
    const days = Math.floor(hours / 24);

    if (seconds < 60) {
      return $r('app.string.just_now');
    } else if (minutes < 60) {
      return `${minutes} ${minutes === 1 ? $r('app.string.minute_ago') : $r('app.string.minutes_ago')}`;
    } else if (hours < 24) {
      return `${hours} ${hours === 1 ? $r('app.string.hour_ago') : $r('app.string.hours_ago')}`;
    } else if (days < 7) {
      return `${days} ${days === 1 ? $r('app.string.day_ago') : $r('app.string.days_ago')}`;
    } else {
      const date = new Date(timestamp);
      return date.toLocaleDateString();
    }
  }

  build() {
    Column() {
      if (this.loading) {
        Column() {
          LoadingProgress()
            .width($r('app.float.loading_size'))
            .height($r('app.float.loading_size'))
            .color(Color.Blue)

          Text($r('app.string.loading'))
            .fontSize($r('app.float.secondary_font_size'))
            .margin({ top: $r('app.float.large_margin') })
            .fontColor(Color.Grey)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (this.error) {
        Column() {
          Text($r('app.string.error_title'))
            .fontSize($r('app.float.subtitle_font_size'))
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: $r('app.float.medium_margin') })

          Text(this.error)
            .fontSize($r('app.float.secondary_font_size'))
            .fontColor(Color.Grey)
            .textAlign(TextAlign.Center)
            .margin({ bottom: $r('app.float.large_margin') })

          Button($r('app.string.retry'))
            .onClick(() => {
              this.loadNews();
            })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .padding($r('app.float.page_padding'))
      } else if (this.newsItems.length === 0) {
        Column() {
          Text($r('app.string.empty_title'))
            .fontSize($r('app.float.subtitle_font_size'))
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: $r('app.float.medium_margin') })

          Text($r('app.string.empty_message'))
            .fontSize($r('app.float.secondary_font_size'))
            .fontColor(Color.Grey)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .padding($r('app.float.page_padding'))
      } else {
        NewsList({ newsItems: this.newsItems, formatTime: this.formatPublishTime.bind(this) })
      }
    }
    .width('100%')
    .height('100%')
  }
}

@Component
struct NewsList {
  @Prop newsItems: NewsItem[];
  formatTime: (timestamp: number) => string;

  build() {
    List({ space: $r('app.float.list_item_spacing') }) {
      LazyForEach(
        new NewsDataSource(this.newsItems),
        (item: NewsItem) => {
          ListItem() {
            NewsItemRow({ newsItem: item, formatTime: this.formatTime })
          }
          .padding({
            left: $r('app.float.page_padding'),
            right: $r('app.float.page_padding'),
            top: $r('app.float.list_item_padding'),
            bottom: $r('app.float.list_item_padding')
          })
        }
      )
    }
    .width('100%')
    .height('100%')
    .padding({ top: $r('app.float.page_padding'), bottom: $r('app.float.page_padding') })
    .scrollBar(BarState.On)
  }
}

@Component
struct NewsItemRow {
  @Prop newsItem: NewsItem;
  formatTime: (timestamp: number) => string;

  build() {
    Column() {
      Text(this.newsItem.title)
        .fontSize($r('app.float.title_font_size'))
        .fontWeight(FontWeight.Medium)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ bottom: $r('app.float.small_margin') })

      Row({ space: $r('app.float.small_margin') }) {
        Text(this.newsItem.source)
          .fontSize($r('app.float.secondary_font_size'))
          .fontColor(Color.Grey)

        Text('•')
          .fontSize($r('app.float.secondary_font_size'))
          .fontColor(Color.Grey)

        Text(this.formatTime(this.newsItem.publishTime))
          .fontSize($r('app.float.secondary_font_size'))
          .fontColor(Color.Grey)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .backgroundColor('#f5f5f5')
    .borderRadius($r('app.float.list_item_border_radius'))
    .padding($r('app.float.list_item_padding'))
  }
}

class NewsDataSource extends BasicDataSource {
  private newsItems: NewsItem[] = [];

  constructor(items: NewsItem[]) {
    super();
    this.newsItems = items;
  }

  totalCount(): number {
    return this.newsItems.length;
  }

  getDataByIndex(index: number): NewsItem | null {
    if (index >= 0 && index < this.newsItems.length) {
      return this.newsItems[index];
    }
    return null;
  }
}

abstract class BasicDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];

  onDataReloaded(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    });
  }

  onDataAdded(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdded(index);
    });
  }

  onDataChanged(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChanged(index);
    });
  }

  onDataDeleted(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDeleted(index);
    });
  }

  onDataMoved(from: number, to: number): void {
    this.listeners.forEach(listener => {
      listener.onDataMoved(from, to);
    });
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  abstract totalCount(): number;

  abstract getDataByIndex(index: number): NewsItem | null;
}
