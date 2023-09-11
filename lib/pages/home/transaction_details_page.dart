import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '/bloc/bloc.dart';
import '/config/app_asset.dart';
import '/config/app_color.dart';
import '/config/app_format.dart';
import '/config/app_symbol.dart';
import '/helper/assistant_method.dart';
import '/models/payload.dart';
import '/models/ride_details.dart';
import '/widgets/custom_button_widget.dart';

class TransactionDetailsPage extends StatelessWidget {
  final RideDetails rideDetails;

  const TransactionDetailsPage({super.key, required this.rideDetails});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthBloc>();

    final dateNow = DateTime.now();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              //* AVATAR
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

              //* TOTAL PAYMENT
              Align(
                alignment: Alignment.center,
                child: Text(
                  AppFormat.currency(rideDetails.totalPayment),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              //* DROPOFF ADDRESS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  rideDetails.dropoff.placeFormattedAddress!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(thickness: 1, height: 24),

              //* TRANSACTION DETAIL
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
                    _itemTransaction(
                        'Metode Pembayaran', rideDetails.paymentMethod),
                    const SizedBox(height: 16),
                    _itemTransaction('Transportasi', rideDetails.vehicle.name),
                    const SizedBox(height: 16),
                    _itemTransactionPayloads('Barang', rideDetails.payloads),
                    const SizedBox(height: 16),
                    _itemTransaction(
                        'Pengangkut', rideDetails.carrier.toString()),
                    const SizedBox(height: 16),
                    _itemTransaction('Status', 'Selesai'),
                    const SizedBox(height: 16),
                    _itemTransaction('Waktu', AppFormat.hm(dateNow.toString())),
                    const SizedBox(height: 16),
                    _itemTransaction(
                        'Tanggal', AppFormat.date(dateNow.toString())),
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
                child: _itemTransaction(
                    'Jumlah', AppFormat.currency(rideDetails.totalPayment)),
              ),
              const Divider(thickness: 1, height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _itemTransaction(
                    'Total', AppFormat.currency(rideDetails.totalPayment),
                    isBold: true),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                child: BlocConsumer<DriverBloc, DriverBlocState>(
                  listener: (context, state) {
                    if (state is DriverStateError) {
                      Fluttertoast.showToast(
                        msg: state.message,
                        timeInSecForIosWeb: 1,
                      );
                    } else if (state is DriverStateSuccess) {
                      Fluttertoast.showToast(
                        msg: 'Berhasil menyelesaikan pesanan',
                        timeInSecForIosWeb: 1,
                      );

                      AssistentMethod.enabledHomeLiveLocation(
                          auth.state.user.id);

                      context.pop();
                    }
                  },
                  builder: (context, state) {
                    return ButtonCustom(
                      label: 'Selesai',
                      isLoading: state is DriverStateLoading,
                      onTap: () => context.read<DriverBloc>().add(
                            DriverEventSetEarnings(
                              userId: auth.state.user.id,
                              earnings: rideDetails.totalPayment,
                            ),
                          ),
                    );
                  },
                ),
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

  Row _itemTransactionPayloads(
    String title,
    List<Payload> payloads,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: payloads.map((payload) {
            return Padding(
              padding: EdgeInsets.only(bottom: payloads.length == 1 ? 0 : 8),
              child: Row(
                children: [
                  Text(
                    payload.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${AppSymbol.multiplication}${payload.qty}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        )
      ],
    );
  }
}
