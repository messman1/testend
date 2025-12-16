import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/models/place_model.dart';
import '../../../profile/providers/bookmarks_provider.dart';

import 'place_detail_stub.dart'
    if (dart.library.html) 'place_detail_web.dart';

/// 장소 상세 페이지 (카카오맵 WebView/IFrame)
class PlaceDetailPage extends ConsumerStatefulWidget {
  final String url;
  final String name;
  final PlaceModel? place;

  const PlaceDetailPage({
    super.key,
    required this.url,
    required this.name,
    this.place,
  });

  @override
  ConsumerState<PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends ConsumerState<PlaceDetailPage> {
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

  /// 북마크 토글
  Future<void> _toggleBookmark() async {
    final place = widget.place;
    if (place == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('장소 정보가 없습니다')),
      );
      return;
    }

    try {
      final result = await ref.read(bookmarksControllerProvider.notifier).toggleBookmark(
        placeName: place.name,
        placeUrl: place.url,
        category: place.category.code,
        location: place.location,
        address: place.address,
        phone: place.phone,
        latitude: place.y,
        longitude: place.x,
      );

      if (mounted) {
        // 북마크 상태 새로고침
        ref.invalidate(isBookmarkedProvider(widget.url));
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result ? '찜 목록에 추가되었습니다' : '찜 목록에서 삭제되었습니다'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBookmarkedAsync = ref.watch(isBookmarkedProvider(widget.url));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.name,
          style: TextStyle(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
        elevation: 1,
        actions: [
          // 북마크 버튼 (PlaceModel이 있을 때만 표시)
          if (widget.place != null)
            isBookmarkedAsync.when(
              data: (isBookmarked) => IconButton(
                icon: Icon(
                  isBookmarked ? Icons.favorite : Icons.favorite_border,
                  color: isBookmarked ? Colors.red : null,
                ),
                onPressed: _toggleBookmark,
                tooltip: isBookmarked ? '찜 취소' : '찜하기',
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (_, __) => IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: _toggleBookmark,
                tooltip: '찜하기',
              ),
            ),
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
