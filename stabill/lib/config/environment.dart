class Environment {
  static const bool useAuthMock =
      bool.fromEnvironment('USE_AUTH_MOCK', defaultValue: false);

  static const bool useDatabaseMock =
      bool.fromEnvironment('USE_DATABASE_MOCK', defaultValue: false);
}
