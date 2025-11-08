import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminCreateUserPage extends ConsumerStatefulWidget {
  const AdminCreateUserPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminCreateUserPage> createState() => _AdminCreateUserPageState();
}

class _AdminCreateUserPageState extends ConsumerState<AdminCreateUserPage> {
  late TextEditingController _emailController;
  late TextEditingController _nameController;
  late TextEditingController _passwordController;
  String _selectedRole = 'usuario';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _nameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _createUser() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create Firebase auth user
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Save to correct collection based on role
      final firestore = FirebaseFirestore.instance;
      final collection = _getCollectionByRole(_selectedRole);

      await firestore.collection(collection).add({
        'email': _emailController.text,
        'name': _nameController.text,
        'uid': userCredential.user?.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'role': _selectedRole,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_selectedRole.toUpperCase()} creado exitosamente')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getCollectionByRole(String role) {
    switch (role) {
      case 'admin':
        return 'admins';
      case 'pyme':
        return 'pymes';
      case 'empresa':
        return 'empresas';
      default:
        return 'users';
    }
  }

  @override
  Widget build(BuildContext context) {
    const brownColor = Color(0xFF8B4513);
    const darkBrown = Color(0xFF654321);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Usuario', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: brownColor,
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[50],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Crear Nuevo Usuario',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: darkBrown,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  labelStyle: const TextStyle(color: brownColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: brownColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: brownColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: brownColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: brownColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: brownColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle: const TextStyle(color: brownColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: brownColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: brownColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Tipo de Cuenta',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: darkBrown,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: brownColor.withOpacity(0.3), width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('Usuario'),
                      value: 'usuario',
                      groupValue: _selectedRole,
                      activeColor: brownColor,
                      onChanged: (value) => setState(() => _selectedRole = value!),
                    ),
                    Divider(color: brownColor.withOpacity(0.2)),
                    RadioListTile<String>(
                      title: const Text('Admin'),
                      value: 'admin',
                      groupValue: _selectedRole,
                      activeColor: brownColor,
                      onChanged: (value) => setState(() => _selectedRole = value!),
                    ),
                    Divider(color: brownColor.withOpacity(0.2)),
                    RadioListTile<String>(
                      title: const Text('PYME'),
                      value: 'pyme',
                      groupValue: _selectedRole,
                      activeColor: brownColor,
                      onChanged: (value) => setState(() => _selectedRole = value!),
                    ),
                    Divider(color: brownColor.withOpacity(0.2)),
                    RadioListTile<String>(
                      title: const Text('Empresa'),
                      value: 'empresa',
                      groupValue: _selectedRole,
                      activeColor: brownColor,
                      onChanged: (value) => setState(() => _selectedRole = value!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brownColor,
                    disabledBackgroundColor: brownColor.withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                      : const Text(
                    'Crear Usuario',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
