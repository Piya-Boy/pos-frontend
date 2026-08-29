import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/core/api/api_client.dart';

void main() {
  test('SubmitResult maps API SessionID to camelCase sessionId', () {
    final result = SubmitResult.fromJson({
      'SessionID': 'ses_001',
      'table': {'TableID': 'T01', 'Name': 'โต๊ะ 01'},
      'totals': {
        'subtotal': 85,
        'discount': 0,
        'serviceCharge': 0,
        'vat': 0,
        'total': 85,
        'promo': null,
      },
      'items': const [],
      'submittedAt': '2026-08-29T12:00:00Z',
    });

    expect(result.sessionId, 'ses_001');
    expect(result.toJson()['SessionID'], 'ses_001');
  });
}
