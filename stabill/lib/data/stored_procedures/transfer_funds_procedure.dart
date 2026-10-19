class TransferFundsProcedure {
  static const String procedureName = 'transfer_funds';
  static const String _fromAccountIdParameterName = 'p_from_account_id';
  static const String _toAccountIdParameterName = 'p_to_account_id';
  static const String _amountParameterName = 'p_amount';

  static Map<String, dynamic> createParams({
    required String fromAccountId,
    required String toAccountId,
    required int amountInCents,
  }) {
    return {
      _fromAccountIdParameterName: fromAccountId,
      _toAccountIdParameterName: toAccountId,
      _amountParameterName: amountInCents,
    };
  }
}
