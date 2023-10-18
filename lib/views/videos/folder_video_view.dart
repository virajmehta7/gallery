import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery/utils/format_duration.dart';
import 'package:gallery/utils/sub_string_name.dart';
import 'package:gallery/utils/colors.dart';
import 'package:gallery/views/videos/video_view.dart';
import 'package:photo_manager/photo_manager.dart';

class FolderVideoView extends StatefulWidget {
  const FolderVideoView({super.key});

  @override
  State<FolderVideoView> createState() => _FolderVideoViewState();
}

class _FolderVideoViewState extends State<FolderVideoView> {
  Map<AssetPathEntity, List<AssetEntity>> folderVideos = {};
  List<AssetPathEntity> sortedFolders = [];

  loadVideos() async {
    folderVideos = {};
    sortedFolders = [];

    final List<AssetPathEntity> paths =
        await PhotoManager.getAssetPathList(type: RequestType.video);

    final filteredPath =
        paths.where((element) => element.name != 'Recent').toList();

    for (final path in filteredPath) {
      final entitiesCount = await path.assetCountAsync;
      final entities =
          await path.getAssetListPaged(page: 0, size: entitiesCount);

      entities
          .sort(((a, b) => b.modifiedDateTime.compareTo(a.modifiedDateTime)));

      folderVideos[path] = entities;
    }

    sortedFolders = folderVideos.keys.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadVideos();
  }

  @override
  Widget build(BuildContext context) {
    if (sortedFolders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.video_collection,
              color: red,
              size: 40,
            ),
            const SizedBox(height: 5),
            const Text(
              'No Videos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ],
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
          itemCount: sortedFolders.length,
          itemBuilder: (context, index) {
            AssetPathEntity folder = sortedFolders[index];
            List<AssetEntity> videos = folderVideos[folder] ?? [];

            return videos.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subStringName(folder.name, 20),
                          style: const TextStyle(
                            fontSize: 18,
                            fontFamily: 'dotmatrix',
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        GridView.builder(
                          itemCount: videos.length,
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                          ),
                          itemBuilder: (context, index) {
                            return FutureBuilder<Uint8List?>(
                              future: videos[index].thumbnailData,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.done &&
                                    snapshot.hasData) {
                                  return GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () async {
                                      File? file = await videos[index].file;
                                      String path = file!.path;

                                      // ignore: use_build_context_synchronously
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => VideoView(
                                                    video: videos[index],
                                                    videoPath: path,
                                                  ))).then((value) {
                                        loadVideos();
                                      });
                                    },
                                    child: Stack(
                                      alignment: Alignment.center,
                                      fit: StackFit.expand,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          child: Image.memory(
                                            snapshot.data!,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.play_circle_fill,
                                              size: 36,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              formatDuration(
                                                  videos[index].videoDuration),
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
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
                  )
                : Container();
          },
        ),
      ),
    );
  }
}
