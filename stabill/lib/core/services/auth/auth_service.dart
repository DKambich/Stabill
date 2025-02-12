import 'package:flutter/foundation.dart';
import 'package:stabill/core/services/auth/abstract_auth_service.dart';
import 'package:stabill/core/services/auth/mock_auth_service.dart';

class AuthService {
  // TODO: Instead of relying of kDebugMode, maybe have this be a config change to swap out locally?
  static final AbstractAuthService instance =
      kDebugMode ? MockAuthService() : MockAuthService();
}
