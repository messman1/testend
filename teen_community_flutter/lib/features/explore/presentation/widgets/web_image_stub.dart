import 'package:flutter/material.dart';

/// 비웹 플랫폼용 WebImage (일반 Image.network 사용)
class WebImage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? const Icon(Icons.error);
      },
    );
  }
}
