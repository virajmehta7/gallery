import 'package:flutter/material.dart';
import 'package:gallery/utils/colors.dart';
import 'package:gallery/views/bottom_navigation_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

class CheckPermission extends StatefulWidget {
  const CheckPermission({super.key});

  @override
  State<CheckPermission> createState() => _CheckPermissionState();
}

class _CheckPermissionState extends State<CheckPermission> {
  checkPermission() async {
    final permissionStatus = await Permission.photos.request();

    if (permissionStatus.isGranted) {
      final PermissionState permissionState =
          await PhotoManager.requestPermissionExtend();

      if (permissionState.isAuth) {
        // ignore: use_build_context_synchronously
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const BottomNavBar()),
            (route) => false);
      } else {
        openAppSettings();
      }
    } else {
      openAppSettings();
    }
  }

  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: CircularProgressIndicator(color: red),
      ),
    );
  }
}
