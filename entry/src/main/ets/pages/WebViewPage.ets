import { router } from '@kit.ArkUI';
import { web } from '@kit.ArkWeb';

@Entry
@Component
struct WebViewPage {
  @State url: string = '';
  webviewController: web.WebviewController = new web.WebviewController();

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>;
    if (params && params.url) {
      this.url = params.url;
    }
  }

  build() {
    Column() {
      Row() {
        Button('Back')
          .onClick(() => {
            router.back();
          })
          .margin({ left: 8 })

        Blank()

        if (this.webviewController) {
          Button('Reload')
            .onClick(() => {
              this.webviewController.refresh();
            })
            .margin({ right: 8 })
        }
      }
      .width('100%')
      .height(56)
      .backgroundColor($r('app.color.start_window_background'))

      if (this.url) {
        Web({ src: this.url, controller: this.webviewController })
          .layoutWeight(1)
      } else {
        Column() {
          Text('No URL provided')
            .fontSize(16)
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(ItemAlign.Center)
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
  }
}
