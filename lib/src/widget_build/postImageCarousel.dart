import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class PostImageCarousel extends StatelessWidget {
  final List<String> imageUrls;

  const PostImageCarousel({Key? key, required this.imageUrls}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    final PageController controller = PageController();

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PageView.builder(
            controller: controller,
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: imageUrls[index],
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 60, color: Colors.red),
                  ),
                ),
              );
            },
          ),
        ),
        if (imageUrls.length > 1) // Chỉ hiển thị dấu chấm nếu có nhiều hơn 1 ảnh
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SmoothPageIndicator(
              controller: controller,
              count: imageUrls.length,
              effect: const WormEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: Colors.blue,
                dotColor: Colors.grey,
              ),
            ),
          ),
      ],
    );
  }
}