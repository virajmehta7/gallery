import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gallery/utils/utils.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

class VideoView extends StatefulWidget {
  const VideoView({super.key, required this.videoPath});

  final videoPath;

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  late VideoPlayerController _controller;
  bool iconVisible = true;

  final StreamController<Duration> _positionStreamController =
      StreamController<Duration>();
  Stream<Duration> get _positionStream => _positionStreamController.stream;

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});

        _controller.addListener(() {
          _positionStreamController.add(_controller.value.position);
        });
        _controller.setLooping(true);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: StreamBuilder<Duration>(
          stream: _positionStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(
                '${_formatDuration(snapshot.data!)} / ${_formatDuration(_controller.value.duration)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              );
            } else {
              return const SizedBox();
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
            onPressed: () async {
              final filePath = await widget.videoPath;
              Share.shareFiles([filePath!]);
            },
            icon: const Icon(Icons.share),
          )
        ],
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() {
                    if (_controller.value.isPlaying) {
                      _controller.pause();
                    } else {
                      _controller.play();
                    }
                    iconVisible = !iconVisible;
                  });
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                    AnimatedOpacity(
                      opacity: iconVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 30,
                        child: Icon(
                          _controller.value.isPlaying
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

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
