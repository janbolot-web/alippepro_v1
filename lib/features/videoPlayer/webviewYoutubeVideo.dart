// ignore_for_file: file_names

import 'dart:async';

import 'package:alippepro_v1/services/course_services.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:youtube_captioned_player/youtube_captioned_player.dart';

class WebYoutube extends StatefulWidget {
  final String? courseId; // Nullable courseId
  final String? lessonId; // Nullable lessonId

  const WebYoutube({super.key, this.courseId, this.lessonId});

  @override
  State<WebYoutube> createState() => _WebYoutubeState();
}

class _WebYoutubeState extends State<WebYoutube> {
  Map<String, dynamic>? courses;
  final CourseService courseService = CourseService();
  String? url;
  // ignore: prefer_typing_uninitialized_variables
  var video;

  @override
  void initState() {
    super.initState();
    getLesson();
    video = Video(
        videoId: "C3aRyxcpy5A", captionLanguageCode: "en", setLoop: false);
  }

  Future<void> getLesson() async {
    final params = {"courseId": widget.courseId, "lessonId": widget.lessonId};

    courses = await courseService.getLesson(params);

    if (courses != null && courses!['youtubeUrl'] != null) {
      setState(() {
        url = courses!['youtubeUrl'];
      });

      // Initialize WebViewController after URL is set
      late final PlatformWebViewControllerCreationParams params;
      if (WebViewPlatform.instance is WebKitWebViewPlatform) {
        params = WebKitWebViewControllerCreationParams(
          allowsInlineMediaPlayback: true,
          mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
        );
      } else {
        params = const PlatformWebViewControllerCreationParams();
      }

      final WebViewController controller =
          WebViewController.fromPlatformCreationParams(params);

      controller
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              debugPrint('WebView is loading (progress : $progress%)');
            },
            onPageStarted: (String url) {
              debugPrint('Page started loading: $url');
            },
            onPageFinished: (String url) {
              debugPrint('Page finished loading: $url');
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
              ''');
            },
            onNavigationRequest: (NavigationRequest request) {
              if (request.url.startsWith('https://www.youtube.com/')) {
                debugPrint('blocking navigation to ${request.url}');
                return NavigationDecision.prevent;
              }
              debugPrint('allowing navigation to ${request.url}');
              return NavigationDecision.navigate;
            },
            onHttpError: (HttpResponseError error) {
              debugPrint(
                  'Error occurred on page: ${error.response?.statusCode}');
            },
            onUrlChange: (UrlChange change) {
              debugPrint('url change to ${change.url}');
            },
          ),
        )
        ..addJavaScriptChannel(
          'Toaster',
          onMessageReceived: (JavaScriptMessage message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message.message)),
            );
          },
        );

      final String initialUrl =
          url ?? 'https://rumble.com/embed/v557fcl/?pub=3ru6zz';
      controller.loadRequest(Uri.parse(initialUrl));

      if (controller.platform is AndroidWebViewController) {
        AndroidWebViewController.enableDebugging(true);
        (controller.platform as AndroidWebViewController)
            .setMediaPlaybackRequiresUserGesture(false);
      }

      setState(() {
      });
    } else {
      // Initialize WebViewController for HTML content if URL is not available
      late final PlatformWebViewControllerCreationParams params;
      if (WebViewPlatform.instance is WebKitWebViewPlatform) {
        params = WebKitWebViewControllerCreationParams(
          allowsInlineMediaPlayback: true,
          mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
        );
      } else {
        params = const PlatformWebViewControllerCreationParams();
      }

      final WebViewController controller =
          WebViewController.fromPlatformCreationParams(params);

      controller
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              debugPrint('WebView is loading (progress : $progress%)');
            },
            onPageStarted: (String url) {
              debugPrint('Page started loading: $url');
            },
            onPageFinished: (String url) {
              debugPrint('Page finished loading: $url');
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
              ''');
            },
            onNavigationRequest: (NavigationRequest request) {
              if (request.url.startsWith('https://www.youtube.com/')) {
                debugPrint('blocking navigation to ${request.url}');
                return NavigationDecision.prevent;
              }
              debugPrint('allowing navigation to ${request.url}');
              return NavigationDecision.navigate;
            },
            onHttpError: (HttpResponseError error) {
              debugPrint(
                  'Error occurred on page: ${error.response?.statusCode}');
            },
            onUrlChange: (UrlChange change) {
              debugPrint('url change to ${change.url}');
            },
          ),
        )
        ..addJavaScriptChannel(
          'Toaster',
          onMessageReceived: (JavaScriptMessage message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message.message)),
            );
          },
        );

      const String htmlContent = '''
      <!DOCTYPE html>
      <html>
      <head>
        <title>Embedded HTML</title>
        <style>
          body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            background-color: #000;
            color: #fff;
          }
          .container {
            max-width: 800px;
            padding: 20px;
            background-color: #222;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.5);
          }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>Welcome to AlippePro</h1>
          <p>This is a sample HTML content displayed in a WebView.</p>
        </div>
      </body>
      </html>
      ''';

      controller.loadHtmlString(htmlContent);

      if (controller.platform is AndroidWebViewController) {
        AndroidWebViewController.enableDebugging(true);
        (controller.platform as AndroidWebViewController)
            .setMediaPlaybackRequiresUserGesture(false);
      }

      setState(() {
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: url == null
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading indicator while URL is being fetched
          : YoutubeCaptionedPlayer(
              video: video,
              isUi: true,
              caption: true,
              sound: true,
              allowScrubbing: true,
            ),
    );
  }
}
