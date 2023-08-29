import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';

import '/bloc/auth/auth_bloc.dart';
import '/config/app_asset.dart';
import '/config/app_color.dart';
import '/cubit/switch_cubit.dart';
import '/routes/router.dart';
import '/widgets/custom_button_widget.dart';
import '/widgets/custom_text_form_field_widget.dart';

// ignore: must_be_immutable
class SignInPage extends StatelessWidget {
  SignInPage({super.key});

  // controller
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // state cubit
  final SwitchCubit _switchCubit = SwitchCubit(false);

  final _formKey = GlobalKey<FormState>();

  late bool _toastDisplayed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, constraint) {
        return SingleChildScrollView(
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
                    const SizedBox(height: 80),

                    //* FORM LOGIN
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          //* EMAIL ADDRESS
                          CustomTextFormField(
                            controller: emailController,
                            hintText: 'Alamat email',
                            iconAsset: AppAsset.iconMail,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Alamat email tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          //* PASSWORD
                          CustomTextFormField(
                            controller: passwordController,
                            hintText: 'Kata sandi',
                            iconAsset: AppAsset.iconLock,
                            isPassword: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Kata sandi tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Row(
                          children: [
                            BlocBuilder<SwitchCubit, bool>(
                              bloc: _switchCubit,
                              builder: (context, state) {
                                return Switch.adaptive(
                                  value: state,
                                  activeColor: AppColor.primary,
                                  onChanged: (value) {
                                    _switchCubit.toggleSwitch();
                                  },
                                );
                              },
                            ),
                            const Text('Ingatkan saya'),
                          ],
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            // TODO: Lupa kata sandi
                          },
                          child: const Text('Lupa kata sandi?'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    BlocConsumer<AuthBloc, AuthState>(
                      listener: (context, state) {
                        // Go to home page when login success
                        if (state is AuthStateAuthenticated &&
                            !_toastDisplayed) {
                          Fluttertoast.showToast(
                            msg: 'Berhasil masuk',
                            toastLength: Toast.LENGTH_LONG,
                            timeInSecForIosWeb: 3,
                          );

                          _toastDisplayed = true;
                          context.goNamed(Routes.home);
                        }

                        if (state is AuthStateError) {
                          // debugPrint('Error: ${state.message}');
                          Fluttertoast.showToast(
                            msg: state.message,
                            toastLength: Toast.LENGTH_LONG,
                            timeInSecForIosWeb: 3,
                          );
                        }
                      },
                      builder: (context, state) {
                        final isLoading = state is AuthStateLoading;

                        return ButtonCustom(
                          label: 'MASUK',
                          isLoading: isLoading,
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthBloc>().add(
                                    AuthEventLogin(
                                      email: emailController.text,
                                      password: passwordController.text,
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
