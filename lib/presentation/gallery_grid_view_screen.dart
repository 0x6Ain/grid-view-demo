import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grid_view_demo/data/gallery_repository.dart';
import 'package:grid_view_demo/presentation/gallery_detail_screen.dart';

import 'gallery_grid_view_item.dart';

class GalleryGridViewScreen extends ConsumerStatefulWidget {
  const GalleryGridViewScreen({super.key});

  @override
  ConsumerState<GalleryGridViewScreen> createState() =>
      _GalleryGridViewScreenState();
}

class _GalleryGridViewScreenState extends ConsumerState<GalleryGridViewScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    ref.read(galleryRepositoryProvider).fetchData();
  }

  void _scrollListener() {
    // Calculate the position at max of the scrollable extent
    final maxScrollExtent = _scrollController.position.maxScrollExtent;

    // Check if the current scroll position is at or beyond position
    if (_scrollController.position.pixels >= maxScrollExtent) {
      if (ref.read(galleryChangesProvider).value?.status != Status.loading) {
        ref.read(galleryRepositoryProvider).fetchMoreData();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final galleryValues = ref.watch(galleryChangesProvider);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Gallery'),
          actions: [
            IconButton(
                onPressed: () =>
                    ref.read(galleryRepositoryProvider).fetchData(),
                icon: const Icon(Icons.refresh))
          ],
        ),
        body: galleryValues.maybeWhen(
          loading: () {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
          data: (galleyItems) {
            return Stack(
              children: [
                Scrollbar(
                  controller: _scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: galleyItems.items.isEmpty
                        ? const Center(
                            child: Text('No contents yet'),
                          )
                        : GridView.builder(
                            controller: _scrollController,
                            shrinkWrap: true,
                            itemCount: galleyItems.items.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1 / 1.25,
                            ),
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GallaryDetailScreen(
                                      galleryListItem: galleyItems.items[index],
                                    ),
                                  ),
                                ),
                                child: Hero(
                                  tag:
                                      '${galleyItems.items[index].galContentId}',
                                  child: GalleryGridViewItem(
                                    galleryListItem: galleyItems.items[index],
                                  ),
                                ),
                              );
                            }),
                  ),
                ),
                if (galleyItems.status == Status.loading)
                  const Opacity(
                      opacity: 0.8,
                      child: ModalBarrier(
                        dismissible: false,
                        color: Colors.black,
                      )),
                if (galleyItems.status == Status.loading)
                  const Center(child: CircularProgressIndicator()),
              ],
            );
          },
          orElse: () {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Error occured'),
                  TextButton(
                    onPressed: () async {
                      if (galleryValues.value?.status == Status.initial) {
                        return ref.read(galleryRepositoryProvider).fetchData();
                      }
                      return ref.read(galleryRepositoryProvider).initialize();
                    },
                    child: const Text('Try Again'),
                  )
                ],
              ),
            );
          },
        ));
  }
}
