import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/core/api/fake_api_client.dart';
import 'package:pos_frontend/models/staff_models.dart';
import 'package:pos_frontend/state/ops_controller.dart';

void main() {
  test('token rotation discards an in-flight dashboard response', () async {
    final api = _DeferredOpsApi();
    final controller = OpsController(api: api, token: 'old-token', view: 'ALL');

    final firstLoad = controller.load();
    controller.useToken('new-token');
    final secondLoad = controller.load();

    expect(api.calls, 2);
    api.responses[0].complete(_dashboard('old user'));
    await firstLoad;
    expect(controller.dashboard, isNull);

    api.responses[1].complete(_dashboard('new user'));
    await secondLoad;

    expect(controller.dashboard!.user.name, 'new user');
  });
}

class _DeferredOpsApi extends FakeApiClient {
  final List<Completer<OpsDashboard>> responses = [];
  int calls = 0;

  @override
  Future<OpsDashboard> opsDashboard({
    required String token,
    required String view,
  }) {
    calls++;
    final response = Completer<OpsDashboard>();
    responses.add(response);
    return response.future;
  }
}

OpsDashboard _dashboard(String name) => OpsDashboard(
  user: StaffSession(
    token: 'token',
    staffId: 'staff',
    name: name,
    role: 'ADMIN',
    issuedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    mustChangePin: false,
  ),
  view: 'ALL',
  items: const [],
  sessions: const [],
  calls: const [],
  summary: const OpsSummary(
    openTables: 0,
    newOrders: 0,
    preparing: 0,
    ready: 0,
    waitingCalls: 0,
  ),
);
