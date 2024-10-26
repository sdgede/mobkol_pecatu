import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:exif/exif.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  static ImageUtils instance = ImageUtils();

  Future<File> flipSelfieImage(File imagePath) async {
    final originalFile = imagePath;
    List<int> imageBytes = await originalFile.readAsBytes();

    final originalImage = img.decodeImage(imageBytes);

    img.Image fixedImage;

    fixedImage = img.flipVertical(originalImage!);

    final fixedFile = await originalFile.writeAsBytes(img.encodeJpg(fixedImage));

    return fixedFile;
  }

  Future<File> fixRotationImage(String imagePath) async {
    final originalFile = File(imagePath);
    List<int> imageBytes = await originalFile.readAsBytes();

    final originalImage = img.decodeImage(imageBytes);

    final height = originalImage!.height;
    final width = originalImage.width;

    if (height >= width) {
      return originalFile;
    }
    final exifData = await readExifFromBytes(imageBytes);

    img.Image? fixedImage;

    if (height < width) {
      if (exifData['Image Orientation']!.printable.contains('Horizontal')) {
        fixedImage = img.copyRotate(originalImage, 90);
      } else if (exifData['Image Orientation']!.printable.contains('180')) {
        fixedImage = img.copyRotate(originalImage, -90);
      } else {
        fixedImage = img.copyRotate(originalImage, 0);
      }
    }

    final fixedFile = await originalFile.writeAsBytes(img.encodeJpg(fixedImage!));

    return fixedFile;
  }

  Future<File> cropImage(File file, int originX, int originY, int width, int height) async {
    File croppedFile = await FlutterNativeImage.cropImage(file.path, originX, originY, width, height);
    return croppedFile;
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  Future<String> saveTemporaryImage({
    Uint8List? imageFile,
    String? fileName,
  }) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = '${tempDir.path}$fileName';
    File image = File(tempPath);
    bool isExist = await image.exists();
    if (isExist) await image.delete();
    await File(tempPath).writeAsBytes(imageFile!);
    return tempPath;
  }

  void deleteTemporaryImage({String? fileName}) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = '${tempDir.path}$fileName';
    File image = File(tempPath);
    bool isExist = await image.exists();
    if (isExist) await image.delete();
  }
}
