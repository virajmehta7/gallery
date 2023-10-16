import 'package:flutter/material.dart';
import 'package:gallery/utils/utils.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';

class PhotoView extends StatefulWidget {
  const PhotoView(
      {Key? key, required this.galleryItems, required this.initialIndex})
      : super(key: key);

  final List<AssetEntity>? galleryItems;
  final int initialIndex;

  @override
  State<PhotoView> createState() => _PhotoViewState();
}

class _PhotoViewState extends State<PhotoView> {
  int currentIndex = 0;
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () async {
              final filePath = await widget.galleryItems![currentIndex].file;
              Share.shareFiles([filePath!.path]);
            },
            icon: const Icon(Icons.share),
          )
        ],
      ),
      body: PhotoViewGallery.builder(
        itemCount: widget.galleryItems!.length,
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        pageController: _pageController,
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          return PhotoViewGalleryPageOptions(
            imageProvider:
                AssetEntityImageProvider(widget.galleryItems![index]),
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 1.5,
          );
        },
        loadingBuilder: (context, event) {
          return Center(
            child: CircularProgressIndicator(color: red),
          );
        },
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
