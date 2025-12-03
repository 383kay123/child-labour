import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final loginController = LoginController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: loginController,
      child: Consumer<LoginController>(
        builder: (context, controller, _) => _buildLoginScreen(context, controller),
      ),
    );
  }

  Widget _buildLoginScreen(BuildContext context, LoginController controller) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: loginController.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  SizedBox(height: size.height * 0.05),
                  Text(
                    'Welcome Back!',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: size.height * 0.08),

                  // Email Field
                  TextFormField(
                    controller: controller.phoneNumberController,
                    onChanged: (_) {
                      if (controller.hasError) {
                        controller.clearError();
                      }
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      prefixIcon: Icon(Icons.phone, color: theme.primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.primaryColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: theme.primaryColor, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Error Message
                  if (controller.hasError)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[800]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              controller.errorMessage ?? 'An error occurred',
                              style: TextStyle(color: Colors.red[800]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Password Field
                  TextFormField(
                    controller: controller.passwordController,
                    onChanged: (_) {
                      if (controller.hasError) {
                        controller.clearError();
                      }
                    },
                    obscureText: controller.obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon:
                          Icon(Icons.lock_outline, color: theme.primaryColor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            controller.obscurePassword =
                                !controller.obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.primaryColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: theme.primaryColor, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: theme.primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: controller.isLoading
                        ? null
                        : () async {
                            final result = await controller.handleLogin(context);
                            if (!result) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(controller.errorMessage ?? 'An error occurred'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: controller.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  // const SizedBox(height: 24),
                  //
                  // // Divider with "or" text
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: Divider(
                  //         color: Colors.grey.shade300,
                  //         thickness: 1,
                  //       ),
                  //     ),
                  //     Padding(
                  //       padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  //       child: Text(
                  //         'or continue with',
                  //         style: TextStyle(
                  //           color: Colors.grey.shade600,
                  //           fontSize: 14,
                  //         ),
                  //       ),
                  //     ),
                  //     Expanded(
                  //       child: Divider(
                  //         color: Colors.grey.shade300,
                  //         thickness: 1,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 24),
                  //
                  // // Social Login Buttons
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //   children: [
                  //     _buildSocialButton(
                  //       icon: 'assets/images/google.png', // Replace with your asset
                  //       onPressed: () {
                  //         // TODO: Implement Google Sign In
                  //       },
                  //     ),
                  //     _buildSocialButton(
                  //       icon: 'assets/images/facebook.png', // Replace with your asset
                  //       onPressed: () {
                  //         // TODO: Implement Facebook Sign In
                  //       },
                  //     ),
                  //     _buildSocialButton(
                  //       icon: 'assets/images/apple.png', // Replace with your asset
                  //       onPressed: () {
                  //         // TODO: Implement Apple Sign In
                  //       },
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 32),
                  //
                  // // Sign Up Link
                  // Center(
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       Text(
                  //         'Don\'t have an account? ',
                  //         style: TextStyle(color: Colors.grey.shade600),
                  //       ),
                  //       TextButton(
                  //         onPressed: () {
                  //           // TODO: Navigate to sign up screen
                  //         },
                  //         style: TextButton.styleFrom(
                  //           padding: EdgeInsets.zero,
                  //           minimumSize: const Size(50, 30),
                  //           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  //         ),
                  //         child: Text(
                  //           'Sign Up',
                  //           style: TextStyle(
                  //             color: theme.primaryColor,
                  //             fontWeight: FontWeight.w600,
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Image.asset(
          icon,
          width: 24,
          height: 24,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
        ),
      ),
    );
  }
}
