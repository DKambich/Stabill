class Environment {
  static const bool useAuthMock =
      bool.fromEnvironment('USE_AUTH_MOCK', defaultValue: false);
}
