import 'package:stabill/data/stored_procedures/stored_procedure.dart';

class CreateAccountProcedure implements StoredProcedure {
  static const String procedureName = 'create_account';
  static final String _userIdParameterName = 'p_user_id';
  static final String _accountNameParameterName = 'p_account_name';
  static final String _startingBalanceParameterName = 'p_starting_balance';

  final String userId;
  final String accountName;
  final int startingBalance;

  CreateAccountProcedure(this.userId, this.accountName, this.startingBalance);

  @override
  String get name => procedureName;

  @override
  Map<String, dynamic> createParameters() {
    return {
      _userIdParameterName: userId,
      _accountNameParameterName: accountName,
      _startingBalanceParameterName: startingBalance,
    };
  }

  static Map<String, dynamic> createParams(
    String userId,
    String accountName,
    int startingBalance,
  ) {
    return {
      _userIdParameterName: userId,
      _accountNameParameterName: accountName,
      _startingBalanceParameterName: startingBalance,
    };
  }
}
