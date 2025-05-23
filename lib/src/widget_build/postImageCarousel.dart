import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'networkImageWithRatio.dart';


class PostImageCarousel extends StatefulWidget {
  final List<String> imageUrls;

  const PostImageCarousel({Key? key, required this.imageUrls}) : super(key: key);

  @override
  State<PostImageCarousel> createState() => _PostImageCarouselState();
}

class _PostImageCarouselState extends State<PostImageCarousel> {
  late final PageController _controller;
  late final ValueNotifier<int> _pageNotifier;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _pageNotifier = ValueNotifier<int>(0);

    _controller.addListener(() {
      if (_controller.page != null) {
        _pageNotifier.value = _controller.page!.round();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        double maxHeight = MediaQuery.of(context).size.height * 0.75;

        return Stack(
          children: [
            // Image container
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxHeight: maxHeight,
              ),
              child: PageView.builder(
                controller: _controller,
                itemCount: widget.imageUrls.length,
                itemBuilder: (context, index) {
                  return NetworkImageWithRatio(
                    imageUrl: widget.imageUrls[index],
                    maxHeight: maxHeight,
                  );
                },
              ),
            ),

            // Top page number indicator
            if (widget.imageUrls.length > 1)
              Positioned(
                top: 12.0,
                right: 0,
                left: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ValueListenableBuilder<int>(
                      valueListenable: _pageNotifier,
                      builder: (context, page, child) {
                        return Text(
                          '${page + 1}/${widget.imageUrls.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

            // Dots indicator
            if (widget.imageUrls.length > 1)
              Positioned(
                bottom: 12.0,
                left: 0,
                right: 0,
                child: Center(
                  child: SmoothPageIndicator(
                    controller: _controller,
                    count: widget.imageUrls.length,
                    effect: const WormEffect(
                      dotHeight: 6,
                      dotWidth: 6,
                      spacing: 4,
                      radius: 3,
                      activeDotColor: Colors.white,
                      dotColor: Colors.white38,
                    ),
                    onDotClicked: (index) => _controller.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
