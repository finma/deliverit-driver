import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '/bloc/bloc.dart';
import '/config/app_asset.dart';
import '/routes/router.dart';
import '/widgets/custom_button_widget.dart';
import '/widgets/custom_datepicker_widget.dart';
import '/widgets/custom_text_form_field_widget.dart';

// ignore: must_be_immutable
class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});

  // controller
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  late bool _toastDisplayed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraint) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraint.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    //* LOGO
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
                    const SizedBox(height: 40),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          //* NAME
                          CustomTextFormField(
                            controller: nameController,
                            hintText: 'Nama lengkap',
                            iconAsset: AppAsset.iconProfile,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama lengkap tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          //* EMAIL ADDRESS
                          CustomTextFormField(
                            controller: emailController,
                            hintText: 'Alamat email',
                            iconAsset: AppAsset.iconMail,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email tidak boleh kosong';
                              }

                              if (!EmailValidator.validate(value)) {
                                return 'Masukkan email yang valid';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          //* PHONE NUMBER
                          CustomTextFormField(
                            controller: phoneNumberController,
                            hintText: 'Nomor telepon',
                            iconAsset: AppAsset.iconCall,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nomor telepon tidak boleh kosong';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          //* HOME ADDRESS
                          CustomTextFormField(
                            controller: addressController,
                            hintText: 'Alamat rumah',
                            iconAsset: AppAsset.iconHome,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Alamat rumah tidak boleh kosong';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          //* birthDate
                          CustomDateTimePickerFormField(
                            controller: birthDateController,
                            hintText: 'Tanggal Lahir',
                            iconAsset: AppAsset.iconTag,
                            validator: (selectedDate) {
                              if (selectedDate == null) {
                                return 'Tanggal lahir harus diisi';
                              }
                              // Add any additional validation you need for the birthDate
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          //* PASSWORD
                          CustomTextFormField(
                            controller: passwordController,
                            hintText: 'Kata sandi',
                            iconAsset: AppAsset.iconLock,
                            keyboardType: TextInputType.visiblePassword,
                            isPassword: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Kata sandi tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          //* CONFIRM PASSWORD
                          CustomTextFormField(
                            controller: confirmPasswordController,
                            hintText: 'Konfirmasi kata sandi',
                            iconAsset: AppAsset.iconLock,
                            keyboardType: TextInputType.visiblePassword,
                            isPassword: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Konfirmasi kata sandi tidak boleh kosong';
                              }

                              if (value != passwordController.text) {
                                return 'Kata sandi tidak cocok';
                              }

                              return null;
                            },
                          ),
                          const SizedBox(height: 52),
                        ],
                      ),
                    ),

                    BlocConsumer<AuthBloc, AuthState>(
                      listener: (context, state) {
                        if (state is AuthStateError) {
                          Fluttertoast.showToast(
                            msg: state.message,
                            toastLength: Toast.LENGTH_LONG,
                            timeInSecForIosWeb: 2,
                          );
                        }

                        if (state is AuthStateAuthenticated &&
                            !_toastDisplayed) {
                          Fluttertoast.showToast(
                            msg: 'Registrasi berhasil',
                            toastLength: Toast.LENGTH_LONG,
                            timeInSecForIosWeb: 2,
                          );

                          // TODO: OTP not implemented yet, so go to home page
                          // context.goNamed(Routes.otp);
                          _toastDisplayed = true;
                          context.goNamed(Routes.home);
                        }
                      },
                      builder: (context, state) {
                        final bool isLoading = state is AuthStateLoading;

                        return ButtonCustom(
                          label: 'SIMPAN',
                          isLoading: isLoading,
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              debugPrint('name: ${nameController.text}');
                              debugPrint('email: ${emailController.text}');
                              debugPrint(
                                  'phoneNumber: ${phoneNumberController.text}');
                              debugPrint('address: ${addressController.text}');
                              debugPrint(
                                  'birtday: ${birthDateController.text}');
                              debugPrint(
                                  'password: ${passwordController.text}');

                              context.read<AuthBloc>().add(
                                    AuthEventRegister(
                                      name: nameController.text.trim(),
                                      email: emailController.text.trim(),
                                      phoneNumber:
                                          phoneNumberController.text.trim(),
                                      address: addressController.text.trim(),
                                      birthDate:
                                          birthDateController.text.trim(),
                                      password: passwordController.text.trim(),
                                    ),
                                  );
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
