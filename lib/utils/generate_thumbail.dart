import 'package:video_thumbnail/video_thumbnail.dart';

generateThumbnail(videofile) async {
  final thumbnail = await VideoThumbnail.thumbnailData(
    video: videofile.path,
    imageFormat: ImageFormat.JPEG,
    quality: 100,
  );
  return thumbnail;
}
