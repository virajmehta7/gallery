import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery/utils/colors.dart';
import 'package:gallery/views/entity_info.dart';
import 'package:intl/intl.dart';
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
  PageController? pageController;

  bool uiVisible = true;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    pageController = PageController(initialPage: currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Hero(
            tag: widget.galleryItems![currentIndex].id,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (uiVisible) {
                  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive,
                      overlays: []);
                } else {
                  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge,
                      overlays: SystemUiOverlay.values);
                }
                setState(() {
                  uiVisible = !uiVisible;
                });
              },
              child: PhotoViewGallery.builder(
                itemCount: widget.galleryItems!.length,
                backgroundDecoration: const BoxDecoration(color: Colors.black),
                pageController: pageController,
                scrollPhysics: const BouncingScrollPhysics(),
                builder: (BuildContext context, int index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider:
                        AssetEntityImageProvider(widget.galleryItems![index]),
                    initialScale: PhotoViewComputedScale.contained,
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 2.5,
                  );
                },
                loadingBuilder: (context, event) {
                  return Center(
                    child: FutureBuilder<Uint8List?>(
                      future: widget.galleryItems![currentIndex].thumbnailData,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          return Image.memory(
                            snapshot.data!,
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width,
                          );
                        } else {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40),
                              child: CircularProgressIndicator(color: red),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
              ),
            ),
          ),
          Visibility(
            visible: uiVisible,
            child: Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('dd MMMM, yyyy').format(
                          widget.galleryItems![currentIndex].modifiedDateTime),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      DateFormat('hh:mm a').format(
                          widget.galleryItems![currentIndex].modifiedDateTime),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                elevation: 0,
                backgroundColor: Colors.transparent,
                iconTheme: const IconThemeData(color: Colors.white),
              ),
            ),
          ),
          Visibility(
            visible: uiVisible,
            child: Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomAppBar(
                color: Colors.transparent,
                elevation: 0,
                padding: EdgeInsets.zero,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.share,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        final filePath =
                            await widget.galleryItems![currentIndex].file;
                        Share.shareFiles([filePath!.path]);
                      },
                      highlightColor: red,
                    ),
                    // IconButton(
                    //   icon: const Icon(
                    //     Icons.edit,
                    //     color: Colors.white,
                    //   ),
                    //   onPressed: () {},
                    //   highlightColor: red,
                    // ),
                    // IconButton(
                    //   icon: const Icon(
                    //     Icons.star,
                    //     color: Colors.white,
                    //   ),
                    //   onPressed: () {},
                    //   highlightColor: red,
                    // ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                      highlightColor: red,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.info,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EntityInfo(
                                    entity:
                                        widget.galleryItems![currentIndex])));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
