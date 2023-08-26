import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:grid_view_demo/models/gallery_list_item.dart';

class GalleryGridViewItem extends StatelessWidget {
  const GalleryGridViewItem({super.key, required this.galleryListItem});
  final GalleryListItem galleryListItem;

  @override
  Widget build(BuildContext context) {
    final key = Key(galleryListItem.galTitle ?? 'galleryContentKey');
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (galleryListItem.galWebImageUrl != '')
            CachedNetworkImage(
              key: key,
              imageUrl: galleryListItem.galWebImageUrl!,
              imageBuilder: (context, imageProvider) => Container(
                width: 400,
                height: 150,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    //image size fill
                    image: imageProvider,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          Expanded(
            child: Center(
              child: Text(
                galleryListItem.galTitle ?? '',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
