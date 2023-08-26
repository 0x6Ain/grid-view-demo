import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:grid_view_demo/models/gallery_list_item.dart';

class GalleryImageFullScreen extends StatefulWidget {
  const GalleryImageFullScreen({super.key, required this.galleryListItem});
  final GalleryListItem galleryListItem;

  @override
  State<GalleryImageFullScreen> createState() => _GalleryImageFullScreenState();
}

class _GalleryImageFullScreenState extends State<GalleryImageFullScreen>
    with TickerProviderStateMixin {
  late final TransformationController _transformationController;
  late AnimationController _animationController;

  final initialScale = Matrix4.identity();
  final minScale = 1.0;
  final doubleTapScale = 3.0;
  final maxScale = 5.0;

  TapDownDetails? _tapDownDetails;
  bool _pagingEnabled = true;
  bool _visible = true;
  Animation<Matrix4>? _animation;
  @override
  void initState() {
    _transformationController = TransformationController();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300))
      ..addListener(() {
        _transformationController.value = _animation!.value;
      });

    super.initState();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void animateZoomIn(Matrix4 intialPositionToZoom) {
    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: intialPositionToZoom,
    ).animate(CurveTween(curve: Curves.easeIn).animate(_animationController));
    _animationController.forward(from: 0);

    setState(() {
      _pagingEnabled = false;
    });
  }

  void animateZoomOut() {
    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: initialScale,
    ).animate(CurveTween(curve: Curves.easeIn).animate(_animationController));
    _animationController.forward(from: 0);

    setState(() {
      _pagingEnabled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _visible
          ? AppBar(
              backgroundColor: Colors.transparent,
            )
          : null,
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        onDoubleTapDown: (details) => _tapDownDetails = details,
        onDoubleTap: () {
          if (_transformationController.value.isIdentity()) {
            final position = _tapDownDetails!.localPosition;
            final x = -position.dx * (maxScale - 2.5);
            final y = -position.dy * (maxScale - 2.5);
            final zoomed = Matrix4.identity()
              ..translate(x, y)
              ..scale(doubleTapScale);
            animateZoomIn(zoomed);
          } else {
            animateZoomOut();
          }
        },
        onTap: () {
          setState(() {
            _visible = !_visible;
          });
        },
        onVerticalDragUpdate: (details) {
          if (_pagingEnabled && details.primaryDelta! > 0) {
            Navigator.of(context).pop();
          }
        },
        child: InteractiveViewer(
          minScale: minScale,
          maxScale: maxScale,
          transformationController: _transformationController,
          child: CachedNetworkImage(
            imageUrl: widget.galleryListItem.galWebImageUrl!,
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            errorWidget: (context, url, error) =>
                const Icon(Icons.error_outline),
            progressIndicatorBuilder: (context, url, progress) => Container(
              alignment: Alignment.center,
              child: SizedBox.fromSize(
                size: const Size(150.0, 150.0),
                child: CircularProgressIndicator(
                    value: progress.progress, color: Colors.white60),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
