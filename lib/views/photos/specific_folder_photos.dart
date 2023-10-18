import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gallery/utils/colors.dart';
import 'package:gallery/views/photos/photo_view.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  int count = 4;
  BoxFit photoSize = BoxFit.cover;
  String photoSizeName = 'Aspect';

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

  getCountAndSize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int? pCount = prefs.getInt('count');
    if (pCount != null) {
      count = pCount;
    }

    String? pPhotoSizeName = prefs.getString('photoSizeName');
    if (pPhotoSizeName != null) {
      if (pPhotoSizeName == 'Aspect') {
        photoSize = BoxFit.cover;
      } else if (pPhotoSizeName == 'Square') {
        photoSize = BoxFit.contain;
      }
      photoSizeName = pPhotoSizeName;
    }

    setState(() {});
  }

  deleteEntity(List<String> result) {
    for (String id in result) {
      for (var date in groupedImages.keys) {
        groupedImages[date]!.removeWhere((entity) => entity.id == id);
      }
      widget.images.removeWhere((entity) => entity.id == id);
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    groupImagesByDate();
    getCountAndSize();
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
        actions: [
          PopupMenuButton<int>(
            onSelected: (choice) {},
            color: Colors.white,
            elevation: 5,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            position: PopupMenuPosition.under,
            itemBuilder: (BuildContext context) {
              return [
                if (count != 3)
                  PopupMenuItem(
                    value: 1,
                    onTap: () async {
                      count -= 1;

                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setInt('count', count);
                      setState(() {});
                    },
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(width: 5),
                        const Text(
                          'Zoom In',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.08),
                        const Spacer(),
                        const Icon(
                          Icons.zoom_in,
                          color: Colors.black,
                          size: 28,
                        ),
                      ],
                    ),
                  ),
                if (count != 3) const PopupMenuDivider(),
                if (count != 5)
                  PopupMenuItem(
                    value: 2,
                    onTap: () async {
                      count += 1;

                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setInt('count', count);
                      setState(() {});
                    },
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(width: 5),
                            const Text(
                              'Zoom Out',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * 0.08),
                            const Spacer(),
                            const Icon(
                              Icons.zoom_out,
                              color: Colors.black,
                              size: 28,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                if (count != 5) const PopupMenuDivider(),
                PopupMenuItem(
                  value: 3,
                  onTap: () async {
                    if (photoSize == BoxFit.cover) {
                      photoSize = BoxFit.contain;
                      photoSizeName = 'Square';
                    } else if (photoSize == BoxFit.contain) {
                      photoSize = BoxFit.cover;
                      photoSizeName = 'Aspect';
                    }

                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setString('photoSizeName', photoSizeName);

                    setState(() {});
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 5),
                      Text(
                        photoSizeName,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.08),
                      const Spacer(),
                      const Icon(
                        Icons.aspect_ratio,
                        color: Colors.black,
                        size: 28,
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: groupedImages.length,
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          String date = groupedImages.keys.elementAt(index);
          List<AssetEntity> images = groupedImages[date] ?? [];

          return images.isNotEmpty
              ? Padding(
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
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: count,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                          ),
                          itemBuilder: (context, index) {
                            final entity = images[index];

                            return GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () async {
                                int overallIndex = 0;

                                for (int i = 0;
                                    i <
                                        groupedImages.keys
                                            .toList()
                                            .indexOf(date);
                                    i++) {
                                  overallIndex += groupedImages[
                                          groupedImages.keys.elementAt(i)]!
                                      .length;
                                }
                                overallIndex += index;
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PhotoView(
                                              galleryItems: widget.images,
                                              initialIndex: overallIndex,
                                            ))).then((result) {
                                  if (result != null) {
                                    deleteEntity(result);
                                  }
                                });
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
                                          fit: photoSize,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(40),
                                        child: CircularProgressIndicator(
                                            color: red),
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
                )
              : Container();
        },
      ),
    );
  }
}
