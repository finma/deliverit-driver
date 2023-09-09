import 'package:deliverit_driver/config/app_asset.dart';
import 'package:deliverit_driver/config/app_color.dart';
import 'package:deliverit_driver/models/ride_details.dart';
import 'package:deliverit_driver/widgets/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TransactionDetailsPage extends StatelessWidget {
  final RideDetails? rideDetails;

  TransactionDetailsPage({super.key, this.rideDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      AppAsset.profile,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.center,
                child: Text(
                  'Rp 222.000',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Jl.Kona - Perum Cipta Graha Mandiri Blok C 108, Sukarindik, Kec.Bungursari, Tasikmalaya',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 24),
              const Divider(thickness: 1, height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rincian Transaksi',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _itemTransaction('Metode Pembayaran', 'Cash'),
                    const SizedBox(height: 16),
                    _itemTransaction('Transportasi', 'Pickup'),
                    const SizedBox(height: 16),
                    _itemTransaction('Barang', 'Lemari dan meja'),
                    const SizedBox(height: 16),
                    _itemTransaction('Pengangkut', '1'),
                    const SizedBox(height: 16),
                    _itemTransaction('Status', 'Selesai'),
                    const SizedBox(height: 16),
                    _itemTransaction('Waktu', '11.44'),
                    const SizedBox(height: 16),
                    _itemTransaction('Tanggal', '17 Agustus 2023'),
                    const SizedBox(height: 16),
                    _itemTransaction(
                      'ID Transaksi',
                      '0220517829008765KWP11',
                      isCanCopy: true,
                    ),
                    const SizedBox(height: 16),
                    _itemTransaction(
                      'Order ID',
                      'F-129213567988',
                      isCanCopy: true,
                    ),
                  ],
                ),
              ),
              const Divider(thickness: 1, height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _itemTransaction('Jumlah', 'Rp 222.000'),
              ),
              const Divider(thickness: 1, height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _itemTransaction('Total', 'Rp 222.000', isBold: true),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ButtonCustom(label: 'Selesai', onTap: () {}),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row _itemTransaction(
    String title,
    String value, {
    bool isBold = false,
    bool isCanCopy = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isCanCopy) const SizedBox(width: 8),
            if (isCanCopy)
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  Fluttertoast.showToast(
                    msg: 'Berhasil menyalin $title',
                    timeInSecForIosWeb: 1,
                  );
                },
                child:
                    const Icon(Icons.copy, size: 18, color: AppColor.primary),
              ),
          ],
        )
      ],
    );
  }
}
