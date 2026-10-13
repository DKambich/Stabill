import 'dart:async';

import 'package:rxdart/rxdart.dart';

/// A utility class that wraps a stream with caching, lazy subscription, and listener-counted unsubscription.
///
/// This class is useful for sharing a single data stream across multiple listeners efficiently.
/// It only subscribes to the underlying stream when at least one listener is present, and automatically
/// cancels the subscription when all listeners have unsubscribed. It also caches the most recent value
/// so new listeners immediately receive the latest data.
///
/// Features:
/// - **Lazy Subscription:** The underlying stream is only subscribed to when there is at least one listener.
/// - **Listener Counting:** Tracks the number of active listeners and cancels the subscription when there are none.
/// - **Caching:** Uses a [BehaviorSubject] to cache the latest value for instant replay to new listeners.
/// - **Manual Disposal:** Provides a [dispose] method to clean up resources.
///
/// Example usage:
/// ```dart
/// final subject = LazySubject<int>(() => someStream());
/// subject.stream.listen((value) => print(value));
/// print(subject.value); // Get the last cached value
/// await subject.dispose(); // Clean up
/// ```
class LazySubject<T> {
  /// The subject that caches the latest value and emits to listeners.
  final BehaviorSubject<T> _subject;

  /// Factory function to create the underlying stream.
  final Stream<T> Function() _streamFactory;

  /// The subscription to the underlying stream, if active.
  StreamSubscription<T>? _subscription;

  /// The number of active listeners on this subject.
  int _listenerCount = 0;

  /// Internal controller to track listen/cancel events and broadcast to multiple listeners.
  late final StreamController<T> _controller = StreamController<T>.broadcast(
    onListen: () {
      // Increment listener count and start the underlying stream if this is the first listener.
      _listenerCount++;
      if (_listenerCount == 1) {
        _subscription ??= _streamFactory().listen(
          (value) => _subject.add(value),
          onError: (error, stack) => _subject.addError(error, stack),
        );
      }
    },
    onCancel: () async {
      // Decrement listener count and cancel the subscription if there are no more listeners.
      _listenerCount--;
      if (_listenerCount <= 0) {
        await _subscription?.cancel();
        _subscription = null;
      }
    },
  );

  /// Creates a [LazySubject] with the given [streamFactory].
  ///
  /// Optionally, provide a [seedValue] to initialize the subject with a starting value.
  LazySubject(this._streamFactory, {T? seedValue})
      : _subject = seedValue != null
            ? BehaviorSubject<T>.seeded(seedValue)
            : BehaviorSubject<T>();

  /// The stream exposed to subscribers.
  ///
  /// When the first listener subscribes, the underlying stream is started. When all listeners
  /// unsubscribe, the subscription is cancelled. All values are cached and replayed to new listeners.
  Stream<T> get stream {
    // Forward values from the subject to the controller (only once, for all listeners)
    _subject.stream.listen(
      (value) {
        if (!_controller.isClosed) _controller.add(value);
      },
      onError: (error, stack) {
        if (!_controller.isClosed) _controller.addError(error, stack);
      },
      cancelOnError: false,
    );
    return _controller.stream;
  }

  /// Returns the last cached value emitted by the stream, or null if none.
  T? get value => _subject.valueOrNull;

  /// Disposes the subject, controller, and any active subscription.
  ///
  /// Call this when the subject is no longer needed to free resources.
  Future<void> dispose() async {
    await _subscription?.cancel();
    await _subject.close();
    await _controller.close();
  }
}
