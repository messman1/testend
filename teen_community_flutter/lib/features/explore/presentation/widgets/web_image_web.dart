import 'package:flutter/material.dart';

/// 웹용 이미지 위젯 (CORS 프록시 사용)
class WebImage extends StatefulWidget {
  final String imageUrl;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BoxFit fit;

  const WebImage({
    super.key,
    required this.imageUrl,
    this.placeholder,
    this.errorWidget,
    this.fit = BoxFit.cover,
  });

  @override
  State<WebImage> createState() => _WebImageState();
}

class _WebImageState extends State<WebImage> {
  bool _hasError = false;

  /// CORS 프록시를 통한 이미지 URL 생성
  String _getCorsProxyUrl(String originalUrl) {
    // CORS 프록시 사용 - corsproxy.io
    return 'https://corsproxy.io/?${Uri.encodeComponent(originalUrl)}';
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return widget.errorWidget ?? const Icon(Icons.error);
    }

    return Image.network(
      _getCorsProxyUrl(widget.imageUrl),
      fit: widget.fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return widget.placeholder ??
            const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        print('[WebImage 에러] ${widget.imageUrl} - $error');
        // 에러 발생 시 상태 업데이트 및 errorWidget 표시
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_hasError) {
            setState(() {
              _hasError = true;
            });
          }
        });
        return widget.errorWidget ?? const Icon(Icons.error);
      },
    );
  }
}
