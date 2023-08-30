import 'package:image_picker/image_picker.dart';

class UtilImage {
  static Future pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image == null) return;

    return image.path;
  }
}
