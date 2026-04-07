import 'package:dotenv_plus/dotenv_plus.dart';
import 'package:serinus/serinus.dart';

/// A service that provides access to environment variables.
class ConfigService extends Provider {
  /// The [DotEnv] instance used to access environment variables.
  final Config _config;

  Map<String, dynamic> get config => _config.values;

  ConfigService(this._config);

  /// Get the value of an environment variable or throw an exception if it is not set.
  ///
  /// Throws a [PreconditionFailedException] if the environment variable is not set.
  ///
  /// Example:
  ///
  /// ```dart
  /// final value = configService.getOrThrow('TEST');
  /// ```
  ///
  /// If the environment variable `TEST` is not set, this will throw a [PreconditionFailedException].
  T getOrThrow<T>(String key, {T? fallbackValue}) {
    return _config.getOrThrow<T>(key, fallbackValue: fallbackValue);
  }

  /// Get the value of an environment variable or return `null` if it is not set.
  ///
  /// Example:
  ///
  /// ```dart
  /// final value = configService.getOrNull('TEST');
  /// ```
  ///
  /// If the environment variable `TEST` is not set, this will return `null`.
  T? get<T>(String key) {
    return _config.get<T>(key);
  }

  Config section(String section) {
    return _config.section(section);
  }

}
