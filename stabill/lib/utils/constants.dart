class Environment {
  static const bool useAuthMock =
      bool.fromEnvironment('USE_AUTH_MOCK', defaultValue: false);
}

class SupabaseConfig {
  static const String supabaseUrl = 'https://vyuqaamvpzcuyawldpcz.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ5dXFhYW12cHpjdXlhd2xkcGN6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg3MjcwNDEsImV4cCI6MjA1NDMwMzA0MX0.-adtduCYp-9AzaZ1Kj5mC71hJSO7Myi6QS-rL-tPy48';
}
