// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CustomWidgetFactory extends WidgetFactory {
  @override
  Widget? buildImageWidget(BuildMetadata meta, ImageSource src) {
    final imageUrl = src.url;

    if (imageUrl != null) {
      // Use CachedNetworkImage for better performance and error handling
      return CachedNetworkImage(
        imageUrl: imageUrl,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red,),
        fit: BoxFit.cover,
      );
    }

    // Fallback to default behavior
    return super.buildImageWidget(meta, src);
  }
}
