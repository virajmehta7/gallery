import 'dart:typed_data';
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

  groupImagesByDate() {
    widget.images
        .sort((a, b) => b.modifiedDateTime.compareTo(a.modifiedDateTime));

    for (final entity in widget.images) {
      final formattedDate =
          DateFormat('EE,dd MMM,yyyy').format(entity.modifiedDateTime);
      if (!groupedImages.containsKey(formattedDate)) {
        groupedImages[formattedDate] = [];
      }
      groupedImages[formattedDate]!.add(entity);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    groupImagesByDate();
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
            fontSize: 20,
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
          String date = groupedImages.keys.elementAt(index);
          List<AssetEntity> images = groupedImages[date] ?? [];

          return Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontFamily: 'dotmatrix',
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: GridView.builder(
                    itemCount: images.length,
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    itemBuilder: (context, index) {
                      final entity = images[index];

                      return GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          int overallIndex = 0;

                          for (int i = 0;
                              i < groupedImages.keys.toList().indexOf(date);
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
                        child: FutureBuilder<Uint8List?>(
                          future: entity.thumbnailData,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.hasData) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Hero(
                                  tag: entity.id,
                                  child: Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
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
