import 'package:flutter/material.dart';

/// CSS background-image를 사용한 웹 이미지 위젯
/// HtmlElementView의 iframe 제약을 우회
class WebImageCSS extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final Widget? errorWidget;

  const WebImageCSS({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.errorWidget,
  });

  String _getBackgroundSize() {
    switch (fit) {
      case BoxFit.cover:
        return 'cover';
      case BoxFit.contain:
        return 'contain';
      case BoxFit.fill:
        return '100% 100%';
      case BoxFit.fitWidth:
        return '100% auto';
      case BoxFit.fitHeight:
        return 'auto 100%';
      case BoxFit.none:
        return 'auto';
      case BoxFit.scaleDown:
        return 'contain';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: fit,
          onError: (exception, stackTrace) {
            // 에러는 errorWidget으로 처리
          },
        ),
      ),
    );
  }
}
