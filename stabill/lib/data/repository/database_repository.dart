import 'package:stabill/config/environment.dart';
import 'package:stabill/data/repository/abstract_database_repository.dart';
import 'package:stabill/data/repository/mock_database_repository.dart';
import 'package:stabill/data/repository/supabase_database_repository.dart';

class DatabaseRepository {
  static final AbstractDatabaseRepository instance = Environment.useDatabaseMock
      ? MockDatabaseRepository()
      : SupabaseDatabaseRepository();
}
