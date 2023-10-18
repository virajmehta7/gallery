import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gallery/utils/format_duration.dart';
import 'package:gallery/utils/colors.dart';
import 'package:gallery/views/entity_info.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

class VideoView extends StatefulWidget {
  const VideoView({super.key, required this.videoPath, required this.video});

  final String videoPath;
  final AssetEntity video;

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  late VideoPlayerController controller;
  bool iconVisible = true;

  final StreamController<Duration> positionStreamController =
      StreamController<Duration>();

  Stream<Duration> get positionStream => positionStreamController.stream;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});

        controller.addListener(() {
          positionStreamController.add(controller.value.position);
        });
        controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    positionStreamController.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: StreamBuilder<Duration>(
          stream: positionStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(
                '${formatDuration(snapshot.data!)} / ${formatDuration(controller.value.duration)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              );
            } else {
              return Container();
            }
          },
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: backgroundColor,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              final filePath = widget.videoPath;
              Share.shareFiles([filePath]);
            },
            icon: const Icon(Icons.share),
          ),
          IconButton(
            onPressed: () {
              controller.pause();
              iconVisible = !iconVisible;
              setState(() {});

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EntityInfo(entity: widget.video)));
            },
            icon: const Icon(Icons.info),
          ),
        ],
      ),
      body: Center(
        child: controller.value.isInitialized
            ? GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() {
                    if (controller.value.isPlaying) {
                      controller.pause();
                    } else {
                      controller.play();
                    }
                    iconVisible = !iconVisible;
                  });
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: VideoPlayer(controller),
                    ),
                    AnimatedOpacity(
                      opacity: iconVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 30,
                        child: Icon(
                          controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          size: 40,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: red),
                ),
              ),
      ),
    );
  }
}
