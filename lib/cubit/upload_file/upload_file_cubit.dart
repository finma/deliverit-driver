import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';

import '/config/firebase.dart';

part 'upload_file_state.dart';

class UploadFileCubit extends Cubit<UploadFileState> {
  UploadFileCubit() : super(UploadFileInitial());

  void setImagePaths({
    String? imageProfile,
    String? imageKTP,
    String? imageSIM,
    String? imageSTNK,
  }) {
    final currentState = state;

    emit(UploadFileImage(
      imageProfile: imageProfile ?? currentState.imageProfile,
      imageKTP: imageKTP ?? currentState.imageKTP,
      imageSIM: imageSIM ?? currentState.imageSIM,
      imageSTNK: imageSTNK ?? currentState.imageSTNK,
    ));
  }

  void uploadFile({
    required String userId,
    required String vehicleType,
    required String imageProfile,
    required String imageKTP,
    required String imageSIM,
    required String imageSTNK,
  }) async {
    try {
      emit(UploadFileLoading());

      final Reference storageReference = FirebaseStorage.instance.ref();

      final UploadTask profileImageTask = storageReference
          .child('driver/$userId/${basename(imageProfile)}')
          .putFile(File(imageProfile));
      final UploadTask ktpImageTask = storageReference
          .child('driver/$userId/${basename(imageKTP)}')
          .putFile(File(imageKTP));
      final UploadTask simImageTask = storageReference
          .child('driver/$userId/${basename(imageSIM)}')
          .putFile(File(imageSIM));
      final UploadTask stnkImageTask = storageReference
          .child('driver/$userId/${basename(imageSTNK)}')
          .putFile(File(imageSTNK));

      final List<TaskSnapshot> taskSnapshots = await Future.wait([
        profileImageTask,
        ktpImageTask,
        simImageTask,
        stnkImageTask,
      ]);

      final List<String> downloadUrls = await Future.wait(
        taskSnapshots.map((taskSnapshot) => taskSnapshot.ref.getDownloadURL()),
      );

      final Map<String, String> driverInfo = {
        'vehicleType': vehicleType,
        'imageProfile': downloadUrls[0],
        'imageKTP': downloadUrls[1],
        'imageSIM': downloadUrls[2],
        'imageSTNK': downloadUrls[3],
      };

      await driverRef.child(userId).update(driverInfo);

      emit(UploadFileSuccess());
    } catch (e) {
      emit(UploadFileError(e.toString()));
    }
  }
}
