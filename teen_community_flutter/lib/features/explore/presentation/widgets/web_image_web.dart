// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

/// 웹용 이미지 위젯 (HTML img 태그 사용으로 CORS 우회)
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
  static int _counter = 0;
  late String _viewId;
  bool _hasError = false;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    // 각 위젯 인스턴스마다 완전히 고유한 viewId 생성
    _viewId = 'web-image-${_counter++}-${widget.imageUrl.hashCode}';
    _registerImageElement();
  }

  void _registerImageElement() {
    try {
      // ignore: undefined_prefixed_name
      ui_web.platformViewRegistry.registerViewFactory(
        _viewId,
        (int viewId) {
          final img = html.ImageElement()
            ..src = widget.imageUrl
            ..style.objectFit = _getObjectFit()
            ..style.width = '100%'
            ..style.height = '100%';

          // 이미지 로드 이벤트 리스너
          img.onLoad.listen((event) {
            print('[WebImage 성공] ${widget.imageUrl}');
            if (mounted) {
              setState(() {
                _isLoaded = true;
                _hasError = false;
              });
            }
          });

          img.onError.listen((event) {
            print('[WebImage 실패] ${widget.imageUrl}');
            if (mounted) {
              setState(() {
                _hasError = true;
                _isLoaded = false;
              });
            }
          });

          return img;
        },
      );
    } catch (e) {
      print('[WebImage 등록 에러] $_viewId - $e');
      setState(() {
        _hasError = true;
      });
    }
  }

  String _getObjectFit() {
    switch (widget.fit) {
      case BoxFit.cover:
        return 'cover';
      case BoxFit.contain:
        return 'contain';
      case BoxFit.fill:
        return 'fill';
      case BoxFit.fitWidth:
        return 'scale-down';
      case BoxFit.fitHeight:
        return 'scale-down';
      case BoxFit.none:
        return 'none';
      case BoxFit.scaleDown:
        return 'scale-down';
    }
  }

  @override
  Widget build(BuildContext context) {
    // 에러 발생 시 errorWidget 표시
    if (_hasError) {
      return widget.errorWidget ?? const Icon(Icons.error);
    }

    // 로딩 중일 때 placeholder 표시
    if (!_isLoaded && widget.placeholder != null) {
      return Stack(
        children: [
          widget.placeholder!,
          Positioned.fill(
            child: HtmlElementView(viewType: _viewId),
          ),
        ],
      );
    }

    return HtmlElementView(viewType: _viewId);
  }
}
