import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:gallery/utils/colors.dart';
import 'package:gallery/views/entity_info.dart';
import 'package:intl/intl.dart';
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
  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        chewieController = ChewieController(
          videoPlayerController: videoPlayerController,
          aspectRatio: videoPlayerController.value.aspectRatio,
          materialProgressColors: ChewieProgressColors(
            backgroundColor: Colors.grey.shade300,
            bufferedColor: Colors.transparent,
            handleColor: red,
            playedColor: red,
          ),
        );
        setState(() {});
      });
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('dd MMMM, yyyy').format(widget.video.modifiedDateTime),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            Text(
              DateFormat('hh:mm a').format(widget.video.modifiedDateTime),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: backgroundColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      bottomNavigationBar: BottomAppBar(
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
              onPressed: () {
                final filePath = widget.videoPath;
                Share.shareFiles([filePath]);
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
                videoPlayerController.pause();
                setState(() {});
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            EntityInfo(entity: widget.video)));
              },
            ),
          ],
        ),
      ),
      body: videoPlayerController.value.isInitialized
          ? Center(
              child: AspectRatio(
                aspectRatio: videoPlayerController.value.aspectRatio,
                child: Chewie(controller: chewieController),
              ),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: CircularProgressIndicator(color: red),
              ),
            ),
    );
  }
}
