import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:grid_view_demo/models/gallery_list_item.dart';
import 'package:grid_view_demo/presentation/gallery_image_full_screen.dart';

class GallaryDetailScreen extends StatelessWidget {
  const GallaryDetailScreen({super.key, required this.galleryListItem});
  final GalleryListItem galleryListItem;

  @override
  Widget build(BuildContext context) {
    final key = Key(galleryListItem.galTitle ?? 'galleryContentKey');
    return Scaffold(
      appBar: AppBar(title: Text(galleryListItem.galTitle ?? '더보기')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: '${galleryListItem.galContentId}',
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GalleryImageFullScreen(
                          galleryListItem: galleryListItem,
                        ),
                      ),
                    ),
                    child: CachedNetworkImage(
                      key: key,
                      imageUrl: galleryListItem.galWebImageUrl!,
                      imageBuilder: (context, imageProvider) => Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Divider(),
                _GallaryDetailDescrtionSection(
                  title: '촬영장소',
                  contents: galleryListItem.galPhotographyLocation,
                ),
                _GallaryDetailDescrtionSection(
                  title: '촬영월',
                  contents: galleryListItem.galPhotographyMonth,
                ),
                _GallaryDetailDescrtionSection(
                  title: '등록일',
                  contents: galleryListItem.galCreatedtime,
                ),
                _GallaryDetailDescrtionSection(
                  title: '수정일',
                  contents: galleryListItem.galModifiedtime,
                ),
                _GallaryDetailDescrtionSection(
                  title: '촬영자',
                  contents: galleryListItem.galPhotographer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GallaryDetailDescrtionSection extends StatelessWidget {
  const _GallaryDetailDescrtionSection({
    required this.title,
    this.contents,
  });
  final String title;
  final String? contents;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        height: 30.0,
        child: Row(
          children: [
            Text(
              '$title :',
              softWrap: true,
            ),
            const Spacer(),
            if (contents != null)
              Text(
                contents!,
                softWrap: true,
              ),
          ],
        ),
      ),
    );
  }
}
