import 'package:deliverit_driver/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/config/app_asset.dart';
import '/widgets/custom_button_widget.dart';

class InitialPage extends StatelessWidget {
  const InitialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    SizedBox(
                      width: 150,
                      height: 80,
                      child: Image.asset(
                        AppAsset.logoDeliveritText2,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Image
              Image.asset(
                AppAsset.fotoPayload,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 24),

              const Text(
                'Hallo Mitra Driver! Udah Siap Jalan?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Yuk, Masuk untuk mulai terima orderan!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 24),

              ButtonCustom(
                label: 'MASUK',
                onTap: () => context.goNamed(Routes.signin),
              ),
              const SizedBox(height: 16),

              ButtonCustom(
                label: 'DAFTAR JADI MITRA',
                type: ButtonType.outline,
                onTap: () {},
              ),
              const SizedBox(height: 24),

              const Text(
                'Klik daftar jadi mitra untuk mulai daftar, lanjutkan atau cek status pendaftaran',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
