import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

choseImageFromLocalFiles(BuildContext context,
    {CropAspectRatio aspectRatio = const CropAspectRatio(ratioX: 1, ratioY: 1),
    int maxSizeInKB = 1024,
    int minSizeInKB = 5}) async {
  final imgSource = await showDialog(
    builder: (context) {
      return AlertDialog(
        title: const Text("Pick image source"),
        actions: [
          TextButton(
            child: const Text("Camera"),
            onPressed: () {
              Navigator.pop(context, ImageSource.camera);
            },
          ),
          TextButton(
            child: const Text("Gallery"),
            onPressed: () {
              Navigator.pop(context, ImageSource.gallery);
            },
          ),
        ],
      );
    },
    context: context,
  );

  var imgPicker = ImagePicker();
  XFile? imagePicked = await imgPicker.pickImage(
      source: imgSource, imageQuality: 40, maxWidth: 300, maxHeight: 300);

  PickedFile newimagePicked = PickedFile((await ImageCropper().cropImage(
          sourcePath: imagePicked!.path,
          aspectRatio: const CropAspectRatio(ratioX: 3, ratioY: 2),
          cropStyle: CropStyle.rectangle))!
      .path);

  return newimagePicked.path;
}
