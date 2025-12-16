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
  late String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'web-image-${widget.imageUrl.hashCode}-${DateTime.now().millisecondsSinceEpoch}';
    _registerImageElement();
  }

  void _registerImageElement() {
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) {
        final img = html.ImageElement()
          ..src = widget.imageUrl
          ..style.objectFit = _getObjectFit()
          ..style.width = '100%'
          ..style.height = '100%';

        return img;
      },
    );
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
    return HtmlElementView(viewType: _viewId);
  }
}
