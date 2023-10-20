import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery/provider/multiple_selected_videos.dart';
import 'package:gallery/utils/format_duration.dart';
import 'package:gallery/utils/sub_string_name.dart';
import 'package:gallery/utils/colors.dart';
import 'package:gallery/views/videos/video_view.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

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
    final multipleVideos =
        Provider.of<MultipleSelectedVideos>(context, listen: false);

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
      bottomNavigationBar: Consumer<MultipleSelectedVideos>(
        builder: (context, value, child) {
          return Visibility(
            visible: multipleVideos.getselectedVideos.isNotEmpty,
            child: BottomAppBar(
              color: Colors.transparent,
              elevation: 0,
              padding: EdgeInsets.zero,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      await PhotoManager.editor
                          .deleteWithIds(multipleVideos.getselectedVideos)
                          .then((value) => multipleVideos.clearVideos());
                      loadVideos();
                    },
                    highlightColor: red,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.share,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      if (multipleVideos.getselectedVideos.isNotEmpty) {
                        List<String> filePaths = [];

                        for (String id in multipleVideos.getselectedVideos) {
                          for (final List<AssetEntity> entities
                              in folderVideos.values) {
                            final entity =
                                entities.where((entity) => entity.id == id);

                            if (entity.isNotEmpty) {
                              final data = await entity.first.file;
                              if (data != null) {
                                filePaths.add(data.path);
                              }
                            }
                          }
                        }

                        if (filePaths.isNotEmpty) {
                          await Share.shareFiles(filePaths)
                              .then((value) => multipleVideos.clearVideos());
                        }
                      }
                    },
                    highlightColor: red,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ListView.builder(
          itemCount: sortedFolders.length,
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            AssetPathEntity folder = sortedFolders[index];
            List<AssetEntity> videos = folderVideos[folder] ?? [];

            return videos.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(10),
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
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: GridView.builder(
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
                                        if (multipleVideos
                                            .getselectedVideos.isEmpty) {
                                          File? file = await videos[index].file;
                                          String path = file!.path;

                                          // ignore: use_build_context_synchronously
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      VideoView(
                                                        video: videos[index],
                                                        videoPath: path,
                                                      ))).then((value) {
                                            multipleVideos.clearVideos;
                                            loadVideos();
                                          });
                                        } else if (multipleVideos
                                            .getselectedVideos.isNotEmpty) {
                                          multipleVideos
                                              .selectVideos(videos[index].id);
                                        }
                                      },
                                      onLongPress: () {
                                        multipleVideos
                                            .selectVideos(videos[index].id);
                                      },
                                      child: Consumer<MultipleSelectedVideos>(
                                        builder: (context, value, child) {
                                          final isVideoSelected = multipleVideos
                                              .getselectedVideos
                                              .contains(videos[index].id);

                                          final pad = isVideoSelected
                                              ? const EdgeInsets.all(10)
                                              : EdgeInsets.zero;

                                          final bRadius = isVideoSelected
                                              ? BorderRadius.circular(20)
                                              : BorderRadius.zero;

                                          return Stack(
                                            alignment: Alignment.center,
                                            fit: StackFit.expand,
                                            children: [
                                              Container(
                                                color: Colors.grey.shade300,
                                                child: Padding(
                                                  padding: pad,
                                                  child: ClipRRect(
                                                    borderRadius: bRadius,
                                                    child: Image.memory(
                                                      snapshot.data!,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
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
                                                    formatDuration(videos[index]
                                                        .videoDuration),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (multipleVideos
                                                  .getselectedVideos
                                                  .contains(videos[index].id))
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.grey.shade700,
                                                      radius: 12,
                                                      child: const Icon(
                                                        Icons.check,
                                                        color: Colors.white,
                                                        size: 18,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                            ],
                                          );
                                        },
                                      ),
                                    );
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.all(50),
                                    child:
                                        CircularProgressIndicator(color: red),
                                  );
                                },
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
      ),
    );
  }
}
