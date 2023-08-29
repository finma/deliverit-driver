import 'package:flutter/material.dart';

import '/bloc/bloc.dart';
import '/config/app_asset.dart';
import '/config/app_color.dart';
import '/cubit/state_cubit.dart';
import '/data/vehicle.dart';
import '/models/vehicle.dart';
import '/widgets/custom_button_widget.dart';

class SelectMitraPage extends StatelessWidget {
  SelectMitraPage({super.key});

  final List<Vehicle> vehicles = DataVehicle.all;
  final StateCubit<int> selectVehicle = StateCubit(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(AppAsset.logoDeliveritText2, width: 90),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selamat datang, di aplikasi DeliverIt Driver!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Silahkan pilih mitra yang ingin anda gunakan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Divider(thickness: 1.5, height: 40),
            _buildListVehicles(context),
            const SizedBox(height: 32),
            ButtonCustom(
              label: 'LANJUTKAN',
              onTap: () {},
            )
          ],
        ),
      ),
    );
  }

  SizedBox _buildListVehicles(BuildContext context) {
    return SizedBox(
      // padding: const EdgeInsets.all(16),
      child: ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemCount: vehicles.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final vehicle = vehicles[index];

          // * LIST ITEM
          return Material(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: () {
                selectVehicle.setSelectedValue(vehicle.id);
              },
              borderRadius: BorderRadius.circular(24),
              child: BlocBuilder<StateCubit<int>, int>(
                bloc: selectVehicle,
                builder: (context, value) {
                  return Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: value == vehicle.id
                                ? AppColor.primary
                                : Colors.transparent,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  vehicle.image,
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '${vehicle.name} Mitra',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // * CHIP
                      if (value == vehicle.id)
                        const Positioned(
                          top: 2,
                          right: 8,
                          child: Chip(
                            backgroundColor: AppColor.primary,
                            elevation: 0,
                            visualDensity: VisualDensity.compact,
                            label: Text(
                              'dipilih',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
