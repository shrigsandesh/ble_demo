class Locator {
  static final _map = <Type, dynamic>{};

  static void register<T>(T instance) {
    _map[T] = instance;
  }

  static T get<T>() => _map[T] as T;
}
