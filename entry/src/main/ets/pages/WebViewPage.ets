import { router } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';

@Entry
@Component
struct WebViewPage {
  @State url: string = '';
  @State title: string = '';
  webviewController: webview.WebviewController = new webview.WebviewController();

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>;
    if (params && params.url) {
      this.url = params.url;
      this.title = params.title || '详情';
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Button('返回')
          .fontSize(14)
          .backgroundColor('#f0f0f0')
          .fontColor('#333333')
          .onClick(() => {
            router.back();
          })
          .margin({ left: 8 })

        Text(this.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#000000')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
          .margin({ left: 12, right: 12 })

        if (this.webviewController) {
          Button('刷新')
            .fontSize(14)
            .backgroundColor('#f0f0f0')
            .fontColor('#333333')
            .onClick(() => {
              this.webviewController.refresh();
            })
            .margin({ right: 8 })
        }
      }
      .width('100%')
      .height(56)
      .backgroundColor('#ffffff')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      if (this.url) {
        Web({ src: this.url, controller: this.webviewController })
          .layoutWeight(1)
          .width('100%')
      } else {
        Column() {
          Text('未提供URL')
            .fontSize(16)
            .fontColor('#999999')
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
}
