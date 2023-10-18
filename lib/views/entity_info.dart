import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gallery/utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';

class EntityInfo extends StatefulWidget {
  const EntityInfo({super.key, required this.entity});

  final AssetEntity entity;

  @override
  State<EntityInfo> createState() => _EntityInfoState();
}

class _EntityInfoState extends State<EntityInfo> {
  Uint8List? thumbnail;
  String? fileName = '';
  String path = '';
  String size = '';
  String mDate = '';
  String cDate = '';

  getDetails() async {
    AssetEntity entity = widget.entity;

    thumbnail = await entity.thumbnailData;
    fileName = entity.title;

    File? file = await entity.file;
    path = file!.path;

    int len = await file.length();
    // int bytes = (await file.readAsBytes()).lengthInBytes;  ----------it gives same answer and I doubt if size in MB is true
    double sizeMB = len / (1024 * 1024);
    size =
        "${widget.entity.size.shortestSide.toStringAsFixed(0)}x${widget.entity.size.longestSide.toStringAsFixed(0)}  •  ${sizeMB.toStringAsFixed(2)} MB";

    mDate =
        "Modified ${DateFormat('dd MMM, yyyy, hh:mm a').format(entity.modifiedDateTime)}";
    cDate =
        "Taken ${DateFormat('dd MMM, yyyy, hh:mm a').format(entity.createDateTime)}";

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getDetails();
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
      body: thumbnail == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(50),
                child: CircularProgressIndicator(color: red),
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.2,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(
                              thumbnail!,
                              fit: BoxFit.contain,
                            ),
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
                    const SizedBox(height: 40),
                    Center(
                      child: Text(
                        fileName!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'dotmatrix',
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                              const SizedBox(height: 5),
                              Text(
                                size,
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
                                mDate,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.visible,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                cDate,
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
            ),
    );
  }
}
