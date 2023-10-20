import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:gallery/provider/multiple_selected_images.dart';
import 'package:gallery/provider/multiple_selected_videos.dart';
import 'package:gallery/views/check_permission.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => MultipleSelectedImages()),
      ChangeNotifierProvider(create: (context) => MultipleSelectedVideos()),
    ],
    child: const VMGallery(),
  ));
}

class VMGallery extends StatefulWidget {
  const VMGallery({super.key});

  @override
  State<VMGallery> createState() => _VMGalleryState();
}

class _VMGalleryState extends State<VMGallery> {
  Future<void> setRefreshRate() async {
    final List<DisplayMode> supported = await FlutterDisplayMode.supported;
    final DisplayMode active = await FlutterDisplayMode.active;

    final List<DisplayMode> resolution = supported
        .where((DisplayMode m) =>
            m.width == active.width && m.height == active.height)
        .toList()
      ..sort((DisplayMode a, DisplayMode b) =>
          b.refreshRate.compareTo(a.refreshRate));

    final DisplayMode mostOptimalMode =
        resolution.isNotEmpty ? resolution.first : active;

    await FlutterDisplayMode.setPreferredMode(mostOptimalMode);
  }

  @override
  void initState() {
    setRefreshRate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: const CheckPermission(),
    );
  }
}
