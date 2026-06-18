import 'dart:async';

/// Serializes requests and keeps at least [minimumInterval] between starts.
class RequestRateLimiter {
  RequestRateLimiter({required this.minimumInterval});

  final Duration minimumInterval;

  Future<void> _queue = Future<void>.value();
  DateTime? _lastStartedAt;

  Future<T> schedule<T>(Future<T> Function() request) {
    final completer = Completer<T>();

    _queue = _queue.then((_) async {
      final lastStartedAt = _lastStartedAt;
      if (lastStartedAt != null) {
        final elapsed = DateTime.now().difference(lastStartedAt);
        final remaining = minimumInterval - elapsed;
        if (remaining > Duration.zero) {
          await Future<void>.delayed(remaining);
        }
      }

      _lastStartedAt = DateTime.now();
      try {
        completer.complete(await request());
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });

    return completer.future;
  }
}
