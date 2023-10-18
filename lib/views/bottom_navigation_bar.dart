import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery/utils/colors.dart';
import 'package:gallery/views/change_title.dart';
import 'package:gallery/views/photos/folder_photo_view.dart';
import 'package:gallery/views/videos/folder_video_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int currentIndex = 0;

  final tabs = [
    const FolderPhotoView(),
    const FolderVideoView(),
  ];

  String title = "VM's";

  changeName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? pTitle = prefs.getString('title');
    if (pTitle != null) {
      title = pTitle;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    changeName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: GestureDetector(
          onDoubleTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChangeTitle(title: title)));
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'dotmatrix',
                  color: red,
                ),
              ),
              const Text(
                ' Gallery',
                style: TextStyle(
                  fontFamily: 'dotmatrix',
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: backgroundColor,
      ),
      body: tabs[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: backgroundColor,
        elevation: 0,
        iconSize: 26,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: red,
        unselectedItemColor: Colors.white,
        selectedLabelStyle: const TextStyle(fontFamily: 'dotmatrix'),
        unselectedLabelStyle: const TextStyle(fontFamily: 'dotmatrix'),
        onTap: (index) {
          HapticFeedback.vibrate();
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.photo),
            label: 'PHOTOS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_collection),
            label: 'VIDEOS',
          ),
        ],
      ),
    );
  }
}
