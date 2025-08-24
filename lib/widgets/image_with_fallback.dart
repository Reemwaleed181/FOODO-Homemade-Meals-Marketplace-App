import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageWithFallback extends StatelessWidget {
  final String? imageUrl;
  final String? fallbackUrl;
  final BoxFit fit;
  final double? width;
  final double? height;

  const ImageWithFallback({
    this.imageUrl,
    this.fallbackUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl ?? fallbackUrl;

    if (url == null || url.isEmpty) {
      return _buildErrorWidget();
    }

    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => _buildErrorWidget(),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Icon(Icons.error_outline, color: Colors.grey[400], size: 32),
      ),
    );
  }
}