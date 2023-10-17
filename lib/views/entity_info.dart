import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gallery/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';

class EntityInfo extends StatefulWidget {
  const EntityInfo({super.key, required this.entity});

  final AssetEntity entity;

  @override
  State<EntityInfo> createState() => _EntityInfoState();
}

class _EntityInfoState extends State<EntityInfo> {
  String path = '';
  String size = '';

  getPath() async {
    File? file = await widget.entity.file;
    path = file!.path;

    int len = await file.length();
    // int bytes = (await file.readAsBytes()).lengthInBytes;

    double sizeMB = len / (1024 * 1024);

    size = '${sizeMB.toStringAsFixed(2)} MB';

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getPath();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: backgroundColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: FutureBuilder<Uint8List?>(
          future: widget.entity.thumbnailData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.2,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.memory(
                            snapshot.data!,
                            fit: BoxFit.contain,
                          ),
                          (widget.entity.type == AssetType.video)
                              ? const CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 18,
                                  child: Icon(
                                    Icons.play_arrow,
                                    size: 26,
                                    color: Colors.black,
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              widget.entity.title.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'dotmatrix',
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 20),
                            child: Divider(),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.photo,
                                color: Colors.white,
                                size: 32,
                              ),
                              const SizedBox(width: 20),
                              Flexible(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      path,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.visible,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "${widget.entity.size.shortestSide.toStringAsFixed(0)}x${widget.entity.size.longestSide.toStringAsFixed(0)}  •  $size",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.calendar_month,
                                color: Colors.white,
                                size: 32,
                              ),
                              const SizedBox(width: 20),
                              Flexible(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Modified ${DateFormat('dd MMM, yyyy, hh:mm a').format(widget.entity.modifiedDateTime)}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.visible,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Taken ${DateFormat('dd MMM, yyyy, hh:mm a').format(widget.entity.modifiedDateTime)}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}
