import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/services/validation_service.dart';
import '../../../shared/utils/input_validators.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_text_form_field.dart';
import 'login_screen.dart';

class RegisterScreen extends StatelessWidget {
  static const String name = 'register';

  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
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
                        const Text(
                          'Regístrate para continuar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _RegisterForm(),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap:
                                  () => context.pushReplacementNamed(
                                    LoginScreen.name,
                                  ),
                              child: const Text(
                                "¿Ya tienes cuenta?",
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

class _RegisterForm extends StatefulWidget {
  const _RegisterForm();

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final formKeyRegister = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final telefonoController = TextEditingController();
  final departamentoController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    telefonoController.dispose();
    departamentoController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!formKeyRegister.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.register(
      email: emailController.text.trim(),
      password: passwordController.text,
      nombre: nameController.text.trim(),
      telefono:
          telefonoController.text.trim().isNotEmpty
              ? telefonoController.text.trim()
              : null,
      departamento:
          departamentoController.text.trim().isNotEmpty
              ? departamentoController.text.trim()
              : null,
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
      key: formKeyRegister,
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
            labelText: 'Nombre',
            keyboardType: TextInputType.name,
            controller: nameController,
            validator: ValidationService.validateName,
          ),
          const SizedBox(height: 16),
          CustomTextFormField(
            labelText: 'Correo electrónico',
            keyboardType: TextInputType.emailAddress,
            controller: emailController,
            validator: ValidationService.validateEmail,
          ),
          const SizedBox(height: 16),
          CustomTextFormField(
            labelText: 'Teléfono (opcional)',
            keyboardType: TextInputType.phone,
            controller: telefonoController,
            inputFormatters: InputFormatters.phone(),
            validator: (value) => value?.trim().isNotEmpty == true
                ? InputValidators.phone(value)
                : null,
          ),
          const SizedBox(height: 16),
          CustomTextFormField(
            labelText: 'Departamento (opcional)',
            keyboardType: TextInputType.text,
            controller: departamentoController,
            validator:
                (value) => ValidationService.validateMaxLength(
                  value,
                  100,
                  'Departamento',
                ),
          ),
          const SizedBox(height: 16),
          CustomTextFormField(
            obscureText: true,
            labelText: 'Contraseña',
            keyboardType: TextInputType.visiblePassword,
            controller: passwordController,
            validator: ValidationService.validatePassword,
          ),
          const SizedBox(height: 24),
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
              onPressed: authProvider.isLoading ? null : _handleRegister,
              child: Text(
                authProvider.isLoading ? 'Espere...' : 'Crear cuenta',
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
