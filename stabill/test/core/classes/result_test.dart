import 'package:flutter_test/flutter_test.dart';
import 'package:stabill/core/classes/result.dart';

void main() {
  group('Result', () {
    test('supports successful void results', () {
      final result = Result<void>.success(null);

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.error, isNull);
    });

    test('reports failed void results', () {
      final error = StateError('delete failed');
      final result = Result<void>.failure(error);

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.error, same(error));
    });
  });
}
