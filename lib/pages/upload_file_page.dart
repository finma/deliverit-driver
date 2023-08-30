import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/bloc/bloc.dart';
import '/cubit/cubit.dart';
import '/models/vehicle.dart';
import '/widgets/custom_button_widget.dart';

class UploadFilePage extends StatelessWidget {
  const UploadFilePage({super.key});

  @override
  Widget build(BuildContext context) {
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
            Row(
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
            ),
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
            _buildUploadTile(title: 'Foto Profile', onTap: () {}),
            _buildUploadTile(title: 'KTP', onTap: () {}),
            _buildUploadTile(title: 'SIM', onTap: () {}),
            _buildUploadTile(title: 'STNK', onTap: () {}),
            const SizedBox(height: 32),
            ButtonCustom(
              label: 'KIRIM',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  ListTile _buildUploadTile({required String title, void Function()? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: const SizedBox(
        width: 100,
        height: 100,
        child: Center(
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
