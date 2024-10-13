import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/local/api_constants.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'button_util.dart';
import 'common_utils.dart';

class WebViewPage extends StatefulWidget {
  final String url;
  final String? fromKey;

  const WebViewPage({Key? key, required this.url, this.fromKey}) : super(key: key);

  @override
  WebViewPageState createState() => WebViewPageState();
}

class WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  RxBool isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(allowsInlineMediaPlayback: true, mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{});
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }
    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) => isLoading.value = false,
          onPageFinished: (String url) => isLoading.value = false,
          onWebResourceError: (WebResourceError error) => printFunction("onWebResourceError", error.description),
          onNavigationRequest: (request) {
            printFunction("request.url", request.url);
            if (widget.fromKey == KYCType.dojah.toString() && request.url.contains(URLConstants.website)) {
              Future.delayed(const Duration(seconds: 2), () => Get.back(result: true));
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
    }
    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SizedBox(
              height: Get.height, width: Get.width, child: Obx(() => isLoading.value ? showLoading() : WebViewWidget(controller: _controller)))),
      floatingActionButton: buttonOnlyIcon(
          onPressCallback: () => Get.back(), iconColor: context.theme.focusColor, size: Dimens.iconSizeLarge, iconData: Icons.arrow_circle_left),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
