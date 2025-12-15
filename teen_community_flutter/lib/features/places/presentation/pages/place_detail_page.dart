import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'place_detail_stub.dart'
    if (dart.library.html) 'place_detail_web.dart';

/// 장소 상세 페이지 (카카오맵 WebView/IFrame)
class PlaceDetailPage extends StatefulWidget {
  final String url;
  final String name;

  const PlaceDetailPage({
    super.key,
    required this.url,
    required this.name,
  });

  @override
  State<PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends State<PlaceDetailPage> {
  WebViewController? _controller;
  bool _isLoading = true;
  final String _iframeViewId = 'kakao-map-iframe';

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _initIframe();
    } else {
      _initWebView();
    }
  }

  void _initIframe() {
    // 웹용 iframe 등록
    registerIframe(_iframeViewId, widget.url);

    // 로딩 완료
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  /// 외부 브라우저에서 열기
  Future<void> _openInBrowser() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('브라우저를 열 수 없습니다')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: _openInBrowser,
            tooltip: '브라우저에서 열기',
          ),
        ],
      ),
      body: Stack(
        children: [
          // 플랫폼별 뷰
          if (kIsWeb)
            HtmlElementView(viewType: _iframeViewId)
          else if (_controller != null)
            WebViewWidget(controller: _controller!),

          // 로딩 인디케이터
          if (_isLoading)
            Container(
              color: theme.colorScheme.surface,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      '장소 정보 불러오는 중...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
