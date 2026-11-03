class CorrectAccountBalanceProcedure {
  static const String procedureName = 'correct_account_balance';
  static const String _accountIdParameterName = 'p_account_id';
  static const String _targetBalanceParameterName = 'p_target_balance';

  static Map<String, dynamic> createParams({
    required String accountId,
    required int targetBalanceInCents,
  }) =>
      {
        _accountIdParameterName: accountId,
        _targetBalanceParameterName: targetBalanceInCents,
      };
}
