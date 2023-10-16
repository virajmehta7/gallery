import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery/utils/generate_thumbail.dart';
import 'package:gallery/utils/sub_string_name.dart';
import 'package:gallery/utils/utils.dart';
import 'package:gallery/views/videos/video_view.dart';
import 'package:photo_manager/photo_manager.dart';

class FolderVideoView extends StatefulWidget {
  const FolderVideoView({super.key});

  @override
  State<FolderVideoView> createState() => _FolderVideoViewState();
}

class _FolderVideoViewState extends State<FolderVideoView> {
  Map<AssetPathEntity, List<AssetEntity>> folderVideos = {};
  List? sortedFolders = [];

  loadVideos() async {
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
    if (sortedFolders == null || sortedFolders!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(70),
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
            final videos = folderVideos[folder] ?? [];

            return Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 32),
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
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    itemCount: videos.length,
                    itemBuilder: (context, index) {
                      final entity = videos[index];
                      return FutureBuilder(
                        future: entity.file,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              snapshot.hasData) {
                            return FutureBuilder(
                              future: generateThumbnail(snapshot.data),
                              builder: (context, thumbSnapshot) {
                                if (thumbSnapshot.connectionState ==
                                        ConnectionState.done &&
                                    thumbSnapshot.hasData) {
                                  return GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => VideoView(
                                                    videoPath:
                                                        snapshot.data!.path,
                                                  )));
                                    },
                                    child: Stack(
                                      alignment: Alignment.center,
                                      fit: StackFit.expand,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.memory(
                                            thumbSnapshot.data as Uint8List,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.play_circle_fill,
                                          size: 48,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return Padding(
                                  padding: const EdgeInsets.all(70),
                                  child: CircularProgressIndicator(color: red),
                                );
                              },
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.all(70),
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
