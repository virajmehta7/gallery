import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gallery/utils/format_image_count.dart';
import 'package:gallery/utils/sub_string_name.dart';
import 'package:gallery/utils/colors.dart';
import 'package:gallery/views/photos/photo_view.dart';
import 'package:gallery/views/photos/specific_folder_photos.dart';
import 'package:photo_manager/photo_manager.dart';

class FolderPhotoView extends StatefulWidget {
  const FolderPhotoView({super.key});

  @override
  State<FolderPhotoView> createState() => _FolderPhotoViewState();
}

class _FolderPhotoViewState extends State<FolderPhotoView> {
  Map<AssetPathEntity, List<AssetEntity>> folderImages = {};
  List<AssetPathEntity> sortedFolders = [];

  loadImages() async {
    final List<AssetPathEntity> paths =
        await PhotoManager.getAssetPathList(type: RequestType.image);

    final filteredPath =
        paths.where((element) => element.name != 'Recent').toList();

    for (final path in filteredPath) {
      final entitiesCount = await path.assetCountAsync;
      final entities =
          await path.getAssetListPaged(page: 0, size: entitiesCount);

      entities
          .sort(((a, b) => b.modifiedDateTime.compareTo(a.modifiedDateTime)));

      folderImages[path] = entities;
    }

    sortedFolders = folderImages.keys.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  @override
  Widget build(BuildContext context) {
    if (sortedFolders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: CircularProgressIndicator(color: red),
        ),
      );
    }
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ListView.builder(
          itemCount: sortedFolders.length,
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            AssetPathEntity folder = sortedFolders[index];
            List<AssetEntity> images = folderImages[folder] ?? [];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SpecificFolderPhotos(
                                  folderName: subStringName(folder.name, 15),
                                  images: images)));
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          subStringName(folder.name, 20),
                          style: const TextStyle(
                            fontSize: 18,
                            fontFamily: 'dotmatrix',
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          ' >',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'dotmatrix',
                            color: red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    itemCount: images.length < 8 ? images.length : 8,
                    itemBuilder: (context, index) {
                      return FutureBuilder<Uint8List?>(
                        future: images[index].thumbnailData,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              snapshot.hasData) {
                            if (index == 7) {
                              return GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SpecificFolderPhotos(
                                                  folderName: subStringName(
                                                      folder.name, 15),
                                                  images: images)));
                                },
                                child: Stack(
                                  fit: StackFit.expand,
                                  alignment: Alignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: Opacity(
                                        opacity: 0.2,
                                        child: Image.memory(
                                          snapshot.data!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        "+${formatImageCount(images.length - 7)}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontFamily: 'dotmatrix',
                                        ),
                                        overflow: TextOverflow.visible,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PhotoView(
                                            galleryItems: images,
                                            initialIndex: index)));
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: Image.memory(
                                  snapshot.data!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.all(50),
                            child: CircularProgressIndicator(color: red),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
