abstract class StoredProcedure {
  /// Returns the name of the stored procedure.
  String get name;

  /// Builds the parameters for the stored procedure.
  Map<String, dynamic> createParameters();
}
