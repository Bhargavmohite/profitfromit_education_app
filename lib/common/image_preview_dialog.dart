import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:webinar/app/models/popup_list_model.dart';
import 'package:webinar/common/common.dart';

class ImagePreviewDialog {
  static void show(BuildContext context, {required List<PopupList> images, int initialIndex = 0}) {
    final PageController controller = PageController(initialPage: initialIndex);
    final ValueNotifier<int> currentPage = ValueNotifier(initialIndex);
    void preloadNearbyImages(int index) {
      final nearbyIndexes = [
        index - 1,
        index,
        index + 1,
      ];

      for (final i in nearbyIndexes) {
        if (i >= 0 && i < images.length) {
          precacheImage(
            CachedNetworkImageProvider(images[i].imageUrl.toString()),
            context,
          );
        }
      }
    }
    preloadNearbyImages(initialIndex);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: 500,
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: controller,
                        physics: const BouncingScrollPhysics(),
                        itemCount: images.length,
                        onPageChanged: (index) {
                          currentPage.value = index;
                          preloadNearbyImages(index);
                        },
                        itemBuilder: (_, index) {
                          return InteractiveViewer(
                            minScale: 1,
                            maxScale: 4,
                            child: GestureDetector(
                              onTap: () {
                                openExternalBrowser(images[index].url.toString());
                                Navigator.of(context).pop();
                              },
                              child: Center(
                                child: CachedNetworkImage(
                                  imageUrl: images[index].imageUrl.toString(),
                                  filterQuality: FilterQuality.high,
                                  fadeInDuration: Duration.zero,
                                  fadeOutDuration: Duration.zero,
                                  placeholder: (_, __) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                  errorWidget: (_, __, ___) {
                                    return const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.broken_image,
                                            color: Colors.black54,
                                            size: 60,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            "Failed to load image",
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      child: ValueListenableBuilder<int>(
                        valueListenable: currentPage,
                        builder: (_, value, __) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              images.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(
                                  milliseconds: 250,
                                ),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                width: value == index ? 18 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: value == index ? Colors.black : Colors.black26,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
