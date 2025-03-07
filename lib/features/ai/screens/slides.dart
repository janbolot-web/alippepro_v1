import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SlidesScreen extends StatefulWidget {
  const SlidesScreen({super.key});

  @override
  State<SlidesScreen> createState() => _SlidesScreenState();
}

class _SlidesScreenState extends State<SlidesScreen> {
  var controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000))
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // Update loading bar.
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) {},
        onHttpError: (HttpResponseError error) {},
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith('https://www.youtube.com/')) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    )
    ..loadRequest(Uri.parse('https://gamma.app/signin'));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: WebViewWidget(
      controller: controller,
    ));
  }
}


