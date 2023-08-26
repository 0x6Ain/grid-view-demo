import 'dart:async';
import 'dart:io';

import 'package:grid_view_demo/models/gallery_list_item.dart';
import 'package:grid_view_demo/services/http_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gallery_repository.g.dart';

enum Status { initial, loading, loaded }

class GalleryRepositoryState {
  final List<GalleryListItem> items;
  Status status = Status.initial;

  GalleryRepositoryState(this.items, this.status);
}

class GalleryRepository {
  GalleryRepository(this._httpService);
  final HttpService _httpService;
  final List<GalleryListItem> _list = [];
  int _currentIndex = 1;
  late int? _totalCount;

  List<GalleryListItem> get list => _list;
  int get length => _list.length;
  final StreamController<GalleryRepositoryState> _listController =
      StreamController.broadcast();

  Stream<GalleryRepositoryState> get listChanges => _listController.stream;

  Future<void> initialize() async {
    _list.isEmpty
        ? await fetchData()
        : _listController.add(GalleryRepositoryState(_list, Status.loaded));
  }

  Future<void> fetchData() async {
    try {
      _listController.add(GalleryRepositoryState(_list, Status.loading));

      final response = await _httpService.sendRequest(
          resource: Resource.galleryList1,
          httpMethod: HttpMethod.get,
          numOfRows: 50,
          pageNo: 1);
      _totalCount = response.totalCount;
      List data = response.items;
      List<GalleryListItem> galleryListItemList =
          data.map((e) => GalleryListItem.fromJson(e)).toList();
      _list.clear();
      _currentIndex = 1;
      _list.addAll(galleryListItemList);
      _listController.add(GalleryRepositoryState(_list, Status.loaded));
    } on HttpException catch (e) {
      _listController.addError(e);
    }
  }

  Future<void> fetchMoreData() async {
    if (length > _totalCount!) {
      return;
    }
    try {
      _listController.add(GalleryRepositoryState(_list, Status.loading));
      final response = await _httpService.sendRequest(
          resource: Resource.galleryList1,
          httpMethod: HttpMethod.get,
          numOfRows: 50,
          pageNo: ++_currentIndex);

      List data = response.items;
      List<GalleryListItem> moreItemList =
          data.map((e) => GalleryListItem.fromJson(e)).toList();

      _list.addAll(moreItemList);
      _listController.add(GalleryRepositoryState(_list, Status.loaded));
    } catch (e) {
      _listController.addError(e);
    }
  }
}

@Riverpod(keepAlive: true)
GalleryRepository galleryRepository(GalleryRepositoryRef ref) =>
    GalleryRepository(ref.read(httpServiceProvider.notifier));

@Riverpod(keepAlive: true)
Stream<GalleryRepositoryState> galleryChanges(GalleryChangesRef ref) {
  final galleryRepository = ref.watch(galleryRepositoryProvider);
  return galleryRepository.listChanges;
}
