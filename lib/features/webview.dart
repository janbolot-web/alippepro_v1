import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class JitsiCustomView extends StatefulWidget {
  const JitsiCustomView({super.key});

  @override
  State<JitsiCustomView> createState() => _JitsiCustomViewState();
}

class _JitsiCustomViewState extends State<JitsiCustomView> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url
                .startsWith('https://jitsi.103-195-6-237.cloud-xip.com/')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://jitsi.103-195-6-237.cloud-xip.com/'));
  }

  @override
  void dispose() {
    controller.clearCache(); // Очистка кеша
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: isLoading ? Colors.white : Colors.black,
        foregroundColor:
            isLoading ? Colors.black : Colors.white, // Улучшение видимости
        toolbarHeight: 40,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
