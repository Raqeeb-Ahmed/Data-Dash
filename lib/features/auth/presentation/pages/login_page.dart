import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/animated_world_map_background.dart';
import '../providers/auth_providers.dart';
import '../../domain/entities/user_entity.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@gmail.com');
  final _passwordController = TextEditingController(text: '123456');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    print('Attempting login...');
    if (_formKey.currentState!.validate()) {
      final success = await ref
          .read(authControllerProvider.notifier)
          .login(_emailController.text, _passwordController.text);
      if (success && mounted) {
        final user = ref.read(authControllerProvider).value;
        if (user != null && user.role == 'admin') {
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/employee-dashboard');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<UserEntity?>>(authControllerProvider, (
      previous,
      next,
    ) {
      next.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.redAccent,
            ),
          );
        },
      );
    });

    final authState = ref.watch(authControllerProvider);

    const primaryTextColor = Colors.white;
    const secondaryTextColor = Color(0x99FFFFFF);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedWorldMapBackground(
        // watermarkText: 'OS TRAVEL',
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding * 1.5),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo or Icon placeholder
                    Icon(Icons.trending_up, size: 80, color: AppColors.primary),
                    const SizedBox(height: 24),

                    // App Title
                    Text(
                      AppConstants.appName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 0, 0, 0),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'Welcome back. Login to view dashboard data.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color.fromARGB(153, 0, 0, 0),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Email Field
                    CustomTextField(
                      controller: _emailController,
                      hintText: 'Enter your email',
                      labelText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    CustomTextField(
                      controller: _passwordController,
                      hintText: 'Enter your password',
                      labelText: 'Password',
                      isPassword: true,
                      prefixIcon: Icons.lock_outline,
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 8),

                    // Forgot Password
                    // Align(
                    //   alignment: Alignment.centerRight,
                    //   child: TextButton(
                    //     onPressed: () {},
                    //     child: const Text(
                    //       'Forgot Password?',
                    //       style: TextStyle(
                    //         color: AppColors.primary,
                    //         fontWeight: FontWeight.w600,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 24),

                    // Login Button
                    CustomButton(
                      text: 'Login',
                      onPressed: _handleLogin,
                      isLoading: authState.isLoading,
                    ),
                    const SizedBox(height: 12),

                    // Quick Login Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Quick Login: ',
                          style: TextStyle(
                            color: const Color.fromARGB(153, 0, 0, 0),
                            fontSize: 12,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _emailController.text = 'adminos@os.com';
                              _passwordController.text = 'ospk123';
                            });
                          },
                          child: const Text(
                            'Admin',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '|',
                          style: TextStyle(
                            color: const Color.fromARGB(153, 0, 0, 0),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _emailController.text = 'aftab@os.com';
                              _passwordController.text = 'Aftabk2323';
                            });
                          },
                          child: const Text(
                            'Employee',
                            style: TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Sign Up Redirect
                    //   Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       Text(
                    //         "Don't have an account? ",
                    //         style: TextStyle(color: secondaryTextColor),
                    //       ),
                    //       GestureDetector(
                    //         onTap: () {},
                    //         child: const Text(
                    //           'Sign Up',
                    //           style: TextStyle(
                    //             color: AppColors.primary,
                    //             fontWeight: FontWeight.bold,
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
