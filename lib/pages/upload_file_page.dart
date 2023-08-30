import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '/bloc/bloc.dart';
import '/cubit/cubit.dart';
import '/models/vehicle.dart';
import '/routes/router.dart';
import '/utils/image.dart';
import '/widgets/custom_button_widget.dart';

// ignore: must_be_immutable
class UploadFilePage extends StatelessWidget {
  UploadFilePage({super.key});

  late bool _toastDisplayed = false;

  @override
  Widget build(BuildContext context) {
    AuthBloc auth = context.read<AuthBloc>();
    VehicleCubit vehicle = context.read<VehicleCubit>();
    UploadFileCubit upload = context.read<UploadFileCubit>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Unggah Dokumen',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back_rounded),
          color: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mendaftar sebagai',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(thickness: 1.5, height: 32),
            _buildRegisterAs(),

            const Divider(thickness: 1.5, height: 32),
            const Text(
              'Upload berkas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Mohon upload foto dan berkas-berkas berikut dan isi informasi yang dibutuhkan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
            const Divider(thickness: 1.5, height: 32),

            // * UPLOAD FOTO PROFILE
            BlocBuilder<UploadFileCubit, UploadFileState>(
              builder: (context, image) {
                return _buildUploadTile(
                    title: 'Foto Profile',
                    image: image.imageProfile,
                    onTap: () async {
                      final String? image = await UtilImage.pickImage();

                      upload.setImagePaths(imageProfile: image);
                    });
              },
            ),

            // * UPLOAD FOTO KTP
            BlocBuilder<UploadFileCubit, UploadFileState>(
              builder: (context, image) {
                return _buildUploadTile(
                    title: 'KTP',
                    image: image.imageKTP,
                    onTap: () async {
                      final String? image = await UtilImage.pickImage();

                      upload.setImagePaths(imageKTP: image);
                    });
              },
            ),

            // * UPLOAD FOTO SIM
            BlocBuilder<UploadFileCubit, UploadFileState>(
              builder: (context, image) {
                return _buildUploadTile(
                    title: 'SIM',
                    image: image.imageSIM,
                    onTap: () async {
                      final String? image = await UtilImage.pickImage();

                      upload.setImagePaths(imageSIM: image);
                    });
              },
            ),

            // * UPLOAD FOTO STNK
            BlocBuilder<UploadFileCubit, UploadFileState>(
              builder: (context, image) {
                return _buildUploadTile(
                    title: 'STNK',
                    image: image.imageSTNK,
                    onTap: () async {
                      final String? image = await UtilImage.pickImage();

                      upload.setImagePaths(imageSTNK: image);
                    });
              },
            ),
            const SizedBox(height: 32),

            // * BUTTON UPLOAD
            BlocConsumer<UploadFileCubit, UploadFileState>(
              listener: (context, state) {
                if (state is UploadFileSuccess && !_toastDisplayed) {
                  Fluttertoast.showToast(
                    msg: 'Berhasil mengunggah berkas',
                    toastLength: Toast.LENGTH_LONG,
                    timeInSecForIosWeb: 3,
                  );

                  _toastDisplayed = true;
                  context.goNamed(Routes.home);
                }

                if (state is UploadFileError) {
                  Fluttertoast.showToast(
                    msg: state.message,
                    toastLength: Toast.LENGTH_LONG,
                    timeInSecForIosWeb: 3,
                  );
                }
              },
              builder: (context, state) {
                bool isButtonDisabled = state.imageProfile == null ||
                    state.imageKTP == null ||
                    state.imageSIM == null ||
                    state.imageSTNK == null;

                return ButtonCustom(
                  label: state is UploadFileLoading
                      ? 'SEDANG MENGUNGGAH...'
                      : 'KIRIM',
                  isLoading: state is UploadFileLoading,
                  isDisabled: isButtonDisabled,
                  onTap: () {
                    context.read<UploadFileCubit>().uploadFile(
                          userId: auth.state.user.id,
                          vehicleType: vehicle.state!.name,
                          imageProfile: state.imageProfile!,
                          imageKTP: state.imageKTP!,
                          imageSIM: state.imageSIM!,
                          imageSTNK: state.imageSTNK!,
                        );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Row _buildRegisterAs() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.user.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    state.user.email,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  Text(
                    state.user.phoneNumber,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        // const Spacer(),
        Container(
          width: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BlocBuilder<VehicleCubit, Vehicle?>(
              builder: (context, state) {
                return Image.asset(
                  state!.image,
                  fit: BoxFit.fitWidth,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  ListTile _buildUploadTile(
      {required String title, String? image, void Function()? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: SizedBox(
        width: 100,
        height: 100,
        child: image != null
            ? Image.file(
                File(image),
                fit: BoxFit.cover,
              )
            : const Center(
                child: Icon(
                  Icons.image_outlined,
                  size: 80,
                ),
              ),
      ),
      subtitle: const Text(
        'Upload',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
      ),
      onTap: onTap,
    );
  }
}
