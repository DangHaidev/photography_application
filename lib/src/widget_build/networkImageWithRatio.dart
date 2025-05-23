import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NetworkImageWithRatio extends StatefulWidget {
  final String imageUrl;
  final double? maxHeight;
  final double? maxWidth;
  final BoxFit? defaultFit;

  const NetworkImageWithRatio({
    Key? key,
    required this.imageUrl,
    this.maxHeight,
    this.maxWidth,
    this.defaultFit,
  }) : super(key: key);

  @override
  State<NetworkImageWithRatio> createState() => _NetworkImageWithRatioState();
}

class _NetworkImageWithRatioState extends State<NetworkImageWithRatio> {
  BoxFit _fit = BoxFit.cover;

  @override
  void initState() {
    super.initState();
    _loadImageAndSetFit();
  }

  void _loadImageAndSetFit() {
    final image = Image.network(widget.imageUrl);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        final width = info.image.width;
        final height = info.image.height;

        if (mounted) {
          setState(() {
            // Nếu ảnh ngang => contain, dọc => cover
            _fit = width > height ? BoxFit.contain : BoxFit.cover;
          });
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: widget.imageUrl,
      fit: widget.defaultFit ?? _fit,
      width: widget.maxWidth ?? double.infinity,
      height: widget.maxHeight,
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[100],
        child: const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 40,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
