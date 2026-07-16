import 'package:flutter_test/flutter_test.dart';
import 'package:shojin_app/services/request_rate_limiter.dart';

void main() {
  test('serializes requests and spaces their start times', () async {
    final limiter = RequestRateLimiter(
      minimumInterval: const Duration(milliseconds: 30),
    );
    final stopwatch = Stopwatch()..start();
    final starts = <Duration>[];

    await Future.wait([
      limiter.schedule(() async {
        starts.add(stopwatch.elapsed);
      }),
      limiter.schedule(() async {
        starts.add(stopwatch.elapsed);
      }),
    ]);

    expect(starts, hasLength(2));
    expect(
      starts[1] - starts[0],
      greaterThanOrEqualTo(const Duration(milliseconds: 25)),
    );
  });
}
