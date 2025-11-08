import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tesoro_regional/core/services/auth/firebase_auth_service.dart';
import 'package:tesoro_regional/core/di/service_locator.dart';
import 'package:tesoro_regional/features/auth/presentation/providers/auth_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final FirebaseAuthService _authService = getIt<FirebaseAuthService>();
  bool _isLoading = false;
  bool _isLoginMode = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _nameError;
  String? _lastNameError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _emailError = 'Ingresa tu correo electrónico';
      } else if (!value.contains('@') || !value.contains('.')) {
        _emailError = 'Ingresa un correo válido (debe contener @ y .)';
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = 'Ingresa tu contraseña';
      } else if (value.length < 6) {
        _passwordError = 'La contraseña debe tener al menos 6 caracteres';
      } else {
        _passwordError = null;
      }
    });
  }

  void _validateConfirmPassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _confirmPasswordError = 'Confirma tu contraseña';
      } else if (value != _passwordController.text) {
        _confirmPasswordError = 'Las contraseñas no coinciden';
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  void _validateName(String value) {
    setState(() {
      if (value.isEmpty) {
        _nameError = 'Ingresa tu nombre';
      } else {
        _nameError = null;
      }
    });
  }

  void _validateLastName(String value) {
    setState(() {
      if (value.isEmpty) {
        _lastNameError = 'Ingresa tu apellido';
      } else {
        _lastNameError = null;
      }
    });
  }

  Future<void> _signInWithEmail() async {
    _validateEmail(_emailController.text);
    _validatePassword(_passwordController.text);

    if (_emailError != null || _passwordError != null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(firebaseAuthServiceProvider);

      final user = await authService.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (user != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('¡Bienvenido de vuelta!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            action: SnackBarAction(
              label: 'Cerrar',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 300));

        if (mounted) {
          try {
            final isAdmin = await ref.read(isAdminProvider.future);
            if (mounted) {
              if (isAdmin) {
                context.go('/admin');
              } else {
                context.go('/');
              }
            }
          } catch (e) {
            if (mounted) {
              context.go('/');
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().replaceAll('Exception: ', '');

        if (errorMessage == 'ACCOUNT_NOT_FOUND') {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Correo no registrado'),
                ],
              ),
              content: const Text(
                'El correo electrónico no está registrado en nuestro sistema.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _isLoginMode = false;
                    });
                  },
                  child: const Text('¿Deseas crear una cuenta?'),
                ),
              ],
            ),
          );
        } else if (errorMessage == 'INVALID_CREDENTIALS') {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Credenciales incorrectas'),
                ],
              ),
              content: const Text(
                'Verifica tu email y contraseña. Asegúrate de que ambos sean correctos.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Reintentar'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showPasswordResetDialog();
                  },
                  child: const Text('¿Olvidaste tu contraseña?'),
                ),
              ],
            ),
          );
        } else {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Error al iniciar sesión'),
                ],
              ),
              content: Text(
                'Error al iniciar sesión. Intenta nuevamente.\n\nDetalle: $errorMessage',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Reintentar'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showPasswordResetDialog();
                  },
                  child: const Text('¿Olvidaste tu contraseña?'),
                ),
              ],
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signUpWithEmail() async {
    _validateName(_nameController.text);
    _validateLastName(_lastNameController.text);
    _validateEmail(_emailController.text);
    _validatePassword(_passwordController.text);
    _validateConfirmPassword(_confirmPasswordController.text);

    if (_nameError != null ||
        _lastNameError != null ||
        _emailError != null ||
        _passwordError != null ||
        _confirmPasswordError != null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      final user = await authService.signUpWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
        _lastNameController.text.trim(),
      );

      if (user != null && mounted) {
        await _showSuccessAnimation('¡Cuenta creada exitosamente!');

        if (mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.mark_email_read_outlined, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Verifica tu correo'),
                ],
              ),
              content: Text(
                'Hemos enviado un correo de verificación a ${user.email}. '
                    'Por favor, verifica tu correo antes de continuar.',
              ),
              actions: [
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _navigateBasedOnRole();
                  },
                  child: const Text('Entendido'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showSuccessAnimation(String message) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 50,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _showPasswordResetDialog() async {
    final resetEmailController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Restablecer contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final email = resetEmailController.text.trim();
              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ingresa tu correo electrónico'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              try {
                final authService = ref.read(firebaseAuthServiceProvider);
                await authService.sendPasswordResetEmail(email);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Correo de restablecimiento enviado'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll('Exception: ', '')),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateBasedOnRole() async {
    try {
      final isAdmin = await ref.read(isAdminProvider.future);
      if (mounted) {
        if (isAdmin) {
          context.go('/admin');
        } else {
          context.go('/');
        }
      }
    } catch (e) {
      if (mounted) {
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final shouldGoHome = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('¿Salir del inicio de sesión?'),
            content: const Text('¿Deseas volver al inicio sin iniciar sesión?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Volver al inicio'),
              ),
            ],
          ),
        );

        if (shouldGoHome == true && mounted) {
          context.go('/');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF8F3),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () {
              context.go('/');
            },
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.explore,
                      size: 60,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    'Tesoro Regional',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Descubre y colecciona el patrimonio cultural',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 48),

                  Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _isLoginMode ? 'Iniciar Sesión' : 'Crear Cuenta',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 24),

                          if (!_isLoginMode) ...[
                            TextField(
                              controller: _nameController,
                              onChanged: _validateName,
                              decoration: InputDecoration(
                                labelText: 'Nombre',
                                prefixIcon: const Icon(Icons.person_outline),
                                errorText: _nameError,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _lastNameController,
                              onChanged: _validateLastName,
                              decoration: InputDecoration(
                                labelText: 'Apellido',
                                prefixIcon: const Icon(Icons.person_outline),
                                errorText: _lastNameError,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            onChanged: _validateEmail,
                            decoration: InputDecoration(
                              labelText: 'Correo electrónico',
                              prefixIcon: const Icon(Icons.email_outlined),
                              errorText: _emailError,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            onChanged: _validatePassword,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: const Icon(Icons.lock_outline),
                              errorText: _passwordError,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),

                          if (!_isLoginMode) ...[
                            const SizedBox(height: 16),
                            TextField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              onChanged: _validateConfirmPassword,
                              decoration: InputDecoration(
                                labelText: 'Confirmar contraseña',
                                prefixIcon: const Icon(Icons.lock_outline),
                                errorText: _confirmPasswordError,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword = !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : (_isLoginMode ? _signInWithEmail : _signUpWithEmail),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            )
                                : Text(
                              _isLoginMode ? 'Iniciar Sesión' : 'Crear Cuenta',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLoginMode = !_isLoginMode;
                                _formKey.currentState?.reset();
                                _emailError = null;
                                _passwordError = null;
                                _confirmPasswordError = null;
                                _nameError = null;
                                _lastNameError = null;
                              });
                            },
                            child: Text(
                              _isLoginMode
                                  ? '¿No tienes cuenta? Regístrate aquí'
                                  : '¿Ya tienes cuenta? Inicia sesión',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          if (_isLoginMode)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _showPasswordResetDialog,
                                child: Text(
                                  '¿Olvidaste tu contraseña?',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    'Al continuar, aceptas nuestros términos y condiciones',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: () {
                      context.go('/');
                    },
                    child: Text(
                      'Continuar sin cuenta',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
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
