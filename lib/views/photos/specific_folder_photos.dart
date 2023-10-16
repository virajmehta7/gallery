import 'package:flutter/material.dart';
import 'package:gallery/utils/utils.dart';
import 'package:gallery/views/photos/photo_view.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:intl/intl.dart';

class SpecificFolderPhotos extends StatefulWidget {
  const SpecificFolderPhotos({
    Key? key,
    required this.folderName,
    required this.images,
  }) : super(key: key);

  final String folderName;
  final List<AssetEntity> images;

  @override
  State<SpecificFolderPhotos> createState() => _SpecificFolderPhotosState();
}

class _SpecificFolderPhotosState extends State<SpecificFolderPhotos> {
  Map<String, List<AssetEntity>> groupedImages = {};

  groupImagesByMonth() {
    widget.images
        .sort((a, b) => b.modifiedDateTime.compareTo(a.modifiedDateTime));

    for (final entity in widget.images) {
      final dt = entity.modifiedDateTime;
      final formattedMonthYear = DateFormat('EE, dd MMM, yyyy').format(dt);
      if (!groupedImages.containsKey(formattedMonthYear)) {
        groupedImages[formattedMonthYear] = [];
      }
      groupedImages[formattedMonthYear]!.add(entity);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    groupImagesByMonth();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.folderName,
          style: TextStyle(
            fontFamily: 'dotmatrix',
            color: red,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: backgroundColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: groupedImages.length,
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final monthYear = groupedImages.keys.elementAt(index);
          final allImages = groupedImages[monthYear];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  monthYear,
                  style: const TextStyle(
                    fontFamily: 'dotmatrix',
                    color: Colors.white,
                    fontSize: 16,
                    letterSpacing: 1.5,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 32),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    itemCount: allImages!.length,
                    itemBuilder: (context, index) {
                      final entity = allImages[index];

                      return GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          int overallIndex = 0;

                          for (int i = 0;
                              i <
                                  groupedImages.keys
                                      .toList()
                                      .indexOf(monthYear);
                              i++) {
                            overallIndex +=
                                groupedImages[groupedImages.keys.elementAt(i)]!
                                    .length;
                          }
                          overallIndex += index;
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PhotoView(
                                        galleryItems: widget.images,
                                        initialIndex: overallIndex,
                                      )));
                        },
                        child: FutureBuilder(
                          future: entity.file,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.hasData) {
                              if (entity.type == AssetType.image) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              }
                              // else if (entity.type == AssetType.video) {
                              //   return FutureBuilder(
                              //     future: generateThumbnail(snapshot.data),
                              //     builder: (context, thumbSnapshot) {
                              //       if (thumbSnapshot.connectionState ==
                              //               ConnectionState.done &&
                              //           thumbSnapshot.hasData) {
                              //         return Stack(
                              //           alignment: Alignment.center,
                              //           fit: StackFit.expand,
                              //           children: [
                              //             ClipRRect(
                              //               borderRadius:
                              //                   BorderRadius.circular(10),
                              //               child: Image.memory(
                              //                 thumbSnapshot.data as Uint8List,
                              //                 fit: BoxFit.cover,
                              //               ),
                              //             ),
                              //             const Icon(
                              //               Icons.play_circle_fill,
                              //               size: 48,
                              //               color: Colors.white,
                              //             ),
                              //           ],
                              //         );
                              //       } else {
                              //         return Padding(
                              //           padding: const EdgeInsets.all(50),
                              //           child: CircularProgressIndicator(
                              //               color: red),
                              //         );
                              //       }
                              //     },
                              //   );
                              // }
                              else {
                                return const Text('eww');
                              }
                            } else {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: CircularProgressIndicator(color: red),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
