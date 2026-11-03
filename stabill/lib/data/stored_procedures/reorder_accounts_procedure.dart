import 'package:stabill/data/stored_procedures/stored_procedure.dart';

class ReorderAccountsProcedure implements StoredProcedure {
  static const String procedureName = 'reorder_accounts';
  static const String _accountIdsParameterName = 'p_account_ids';

  final List<String> accountIds;

  ReorderAccountsProcedure(this.accountIds);

  @override
  String get name => procedureName;

  @override
  Map<String, dynamic> createParameters() => createParams(accountIds);

  static Map<String, dynamic> createParams(List<String> accountIds) => {
        _accountIdsParameterName: accountIds,
      };
}