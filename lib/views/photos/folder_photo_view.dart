import 'package:flutter/material.dart';
import 'package:gallery/utils/format_image_count.dart';
import 'package:gallery/utils/sub_string_name.dart';
import 'package:gallery/utils/utils.dart';
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
  List? sortedFolders = [];

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
    if (sortedFolders == null || sortedFolders!.isEmpty) {
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
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: sortedFolders!.length,
          itemBuilder: (context, index) {
            final folder = sortedFolders![index];
            final images = folderImages[folder] ?? [];

            return Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 32),
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
                            fontSize: 22,
                            fontFamily: 'dotmatrix',
                            color: red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    itemCount: images.length < 6 ? images.length : 6,
                    itemBuilder: (context, index) {
                      final entity = images[index];
                      return FutureBuilder(
                        future: entity.file,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              snapshot.hasData) {
                            if (index == 5) {
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
                                      borderRadius: BorderRadius.circular(10),
                                      child: Opacity(
                                        opacity: 0.2,
                                        child: Image.file(
                                          snapshot.data!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        "+${formatImageCount(images.length - 5)}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
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
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  snapshot.data!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                            // else if (entity.type == AssetType.video) {
                            //   return FutureBuilder(
                            //     future: generateThumbnail(snapshot.data),
                            //     builder: (context, thumbSnapshot) {
                            //       if (thumbSnapshot.connectionState ==
                            //               ConnectionState.done &&
                            //           thumbSnapshot.hasData) {
                            //         if (index == 5) {
                            //           return GestureDetector(
                            //             behavior: HitTestBehavior.translucent,
                            //             onTap: () {
                            //               Navigator.push(
                            //                   context,
                            //                   MaterialPageRoute(
                            //                       builder: (context) =>
                            //                           SpecificFolderImages(
                            //                               folderName:
                            //                                   subStringName(
                            //                                       folder.name,
                            //                                       15),
                            //                               images: images)));
                            //             },
                            //             child: Stack(
                            //               fit: StackFit.expand,
                            //               alignment: Alignment.center,
                            //               children: [
                            //                 ClipRRect(
                            //                   borderRadius:
                            //                       BorderRadius.circular(10),
                            //                   child: Opacity(
                            //                     opacity: 0.2,
                            //                     child: Image.memory(
                            //                       thumbSnapshot.data
                            //                           as Uint8List,
                            //                       fit: BoxFit.cover,
                            //                     ),
                            //                   ),
                            //                 ),
                            //                 Center(
                            //                   child: Text(
                            //                     "+${formatImageCount(images.length - 5)}",
                            //                     style: const TextStyle(
                            //                       color: Colors.white,
                            //                       fontSize: 24,
                            //                     ),
                            //                     overflow: TextOverflow.visible,
                            //                     textAlign: TextAlign.center,
                            //                   ),
                            //                 ),
                            //               ],
                            //             ),
                            //           );
                            //         }
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
                            //           padding: const EdgeInsets.all(40),
                            //           child:
                            //               CircularProgressIndicator(color: red),
                            //         );
                            //       }
                            //     },
                            //   );
                            // }
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
