import 'package:stabill/config/environment.dart';
import 'package:stabill/core/services/auth/abstract_auth_service.dart';
import 'package:stabill/core/services/auth/mock_auth_service.dart';
import 'package:stabill/core/services/auth/supabase_auth_service.dart';

class AuthService {
  static final AbstractAuthService instance =
      Environment.useAuthMock ? MockAuthService() : SupabaseAuthService();
}
