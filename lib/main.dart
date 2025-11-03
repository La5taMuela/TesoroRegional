import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tesoro_regional/firebase_options.dart';
import 'package:tesoro_regional/core/di/service_locator.dart';
import 'package:tesoro_regional/app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Configurar el service locator (GetIt)
  ServiceLocator();
  try {
    print('🚀 Initializing services...');
    await ServiceLocator.init();

    print('✅ Services initialized successfully');

    runApp(
      const ProviderScope(
        child: TesoroRegionalApp(),
      ),
    );
  } catch (e, stackTrace) {
    print('❌ Failed to initialize app: $e');
    print('Stack trace: $stackTrace');

    // Run app with error handling
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Error al inicializar la aplicación',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
