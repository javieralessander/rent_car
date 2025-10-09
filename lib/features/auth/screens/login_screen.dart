import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/config/app_theme.dart';
import '../../../core/services/validation_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_form_field.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  static const String name = 'login';
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo con imagen
          Image.asset(
            'assets/images/login_background.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
          ),
          Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  color: Colors.white.withOpacity(0.95),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset('assets/svgs/sicom.svg', height: 120),
                        // const SizedBox(height: 28),
                        const Text(
                          'Inicia sesión para continuar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _LoginForm(),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap:
                                  () => context.pushNamed(RegisterScreen.name),
                              child: const Text(
                                "Crear cuenta",
                                style: TextStyle(color: AppColors.info),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.push('/forgot-password'),
                              child: const Text(
                                "¿Necesitas ayuda?",
                                style: TextStyle(color: AppColors.info),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final formKeyLogin = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!formKeyLogin.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.login(
      email: emailController.text.trim(),
      password: passwordController.text,
      rememberMe: _rememberMe,
    );

    if (success && mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: formKeyLogin,
      child: Column(
        children: [
          // Mensaje de error
          if (authProvider.errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      authProvider.errorMessage!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          CustomTextFormField(
            labelText: 'Correo electrónico',
            keyboardType: TextInputType.emailAddress,
            controller: emailController,
            validator: ValidationService.validateEmail,
          ),
          const SizedBox(height: 16),
          CustomTextFormField(
            obscureText: true,
            labelText: 'Contraseña',
            keyboardType: TextInputType.visiblePassword,
            controller: passwordController,
            validator: ValidationService.validatePassword,
          ),
          const SizedBox(height: 16),
          // Checkbox recordarme
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const Text('Recordarme', style: TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                backgroundColor: AppColors.info,
              ),
              onPressed: authProvider.isLoading ? null : _handleLogin,
              child: Text(
                authProvider.isLoading ? 'Espere...' : 'Iniciar sesión',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
