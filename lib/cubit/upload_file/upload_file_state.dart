part of 'upload_file_cubit.dart';

sealed class UploadFileState {
  final String? imageProfile;
  final String? imageKTP;
  final String? imageSIM;
  final String? imageSTNK;

  UploadFileState({
    this.imageProfile,
    this.imageKTP,
    this.imageSIM,
    this.imageSTNK,
  });
}

final class UploadFileInitial extends UploadFileState {}

final class UploadFileLoading extends UploadFileState {}

final class UploadFileImage extends UploadFileState {
  UploadFileImage({
    String? imageProfile,
    String? imageKTP,
    String? imageSIM,
    String? imageSTNK,
  }) : super(
          imageProfile: imageProfile,
          imageKTP: imageKTP,
          imageSIM: imageSIM,
          imageSTNK: imageSTNK,
        );
}

final class UploadFileSuccess extends UploadFileState {}

final class UploadFileError extends UploadFileState {
  UploadFileError(this.message);

  final String message;
}
