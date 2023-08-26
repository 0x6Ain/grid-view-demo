import 'package:freezed_annotation/freezed_annotation.dart';

part 'gallery_list_item.g.dart';
part 'gallery_list_item.freezed.dart';

@freezed
class GalleryListItem with _$GalleryListItem {
  factory GalleryListItem(
      {String? galContentTypeId,
      String? galPhotographyMonth,
      String? galPhotographyLocation,
      String? galWebImageUrl,
      String? galCreatedtime,
      String? galModifiedtime,
      String? galPhotographer,
      String? galSearchKeyword,
      String? galContentId,
      String? galTitle}) = _GalleryListItem;

  factory GalleryListItem.fromJson(Map<String, dynamic> json) =>
      _$GalleryListItemFromJson(json);
}
