/// The worker owns its engine and does not publish Flutter UI notifications.
class ValueNotifier<T> {
  T value;
  ValueNotifier(this.value);
}

const kDebugMode = !bool.fromEnvironment('dart.vm.product');
