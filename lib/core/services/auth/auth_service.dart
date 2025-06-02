abstract class AuthService {
  bool get isAuthenticated;
  bool get isOnboardingComplete;
  Future<void> signOut();
}

class AuthServiceImpl implements AuthService {
  final storage;
  final network;

  AuthServiceImpl({required this.storage, required this.network});

  @override
  bool get isAuthenticated => true; // Simplified for now

  @override
  bool get isOnboardingComplete => true; // Simplified for now

  @override
  Future<void> signOut() async {
    // Implementation
  }
}
