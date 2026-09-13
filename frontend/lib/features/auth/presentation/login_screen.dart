import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/cta_button.dart';
import '../../../shared/widgets/flat_illustration.dart';
import '../../../theme/app_colors.dart';
import '../state/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'admin@vier.cl');
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final ok = await ref
        .read(authNotifierProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text);
    if (mounted) setState(() => _loading = false);
    if (!ok && mounted) {
      final message = ref.read(authNotifierProvider).errorMessage ?? 'Error al iniciar sesión';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.fucsia),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Center(child: FlatIllustration(size: 180)),
                  const SizedBox(height: 24),
                  Text(
                    'Vier',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 30,
                          color: AppColors.violetDeep,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Levantamiento y captura de datos en terreno',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 36),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'Correo electrónico',
                            prefixIcon: Icon(Icons.mail_outline, color: AppColors.violetSoft),
                          ),
                          validator: (value) {
                            if (value == null || !value.contains('@')) {
                              return 'Ingresa un correo válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            hintText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.violetSoft),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return 'Mínimo 6 caracteres';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: 28),
                        CtaButton(
                          label: 'Ingresar',
                          icon: Icons.arrow_forward_rounded,
                          loading: _loading,
                          onPressed: _submit,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Acceso exclusivo para equipos de terreno',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
