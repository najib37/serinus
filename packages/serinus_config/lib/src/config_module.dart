import 'package:dotenv_plus/dotenv_plus.dart';
import 'package:serinus/serinus.dart';
import 'package:serinus_config/src/config_service.dart';

/// A module that provides a [ConfigService] that can be used to access environment variables.
class ConfigModule extends Module {

  final List<ConfigSource> sources;

  final bool useInterpolation;

  final bool useSectionKeys;

  final List<ConfigExtension> extensions;

  final String sectionSeparator;

  final ConfigValidationSchema? schema;

  /// Create a new instance of [ConfigModule].
  ///
  /// Optionally, you can pass a [ConfigModuleOptions] object to configure the module.
  ConfigModule({
    this.sources = const [],
    this.extensions = const [],
    this.useInterpolation = false,
    this.useSectionKeys = false,
    this.sectionSeparator = '.',
    this.schema,
    super.isGlobal = false,
  }) : assert(sources.isNotEmpty, 'At least one source must be provided');

  @override
  Future<DynamicModule> registerAsync(ApplicationConfig config) async {
    final config = await Config.load(
      sources: sources,
      useInterpolation: useInterpolation,
      useSectionKeys: useSectionKeys,
      sectionSeparator: sectionSeparator,
      extensions: extensions,
      schema: schema,
    );
    final registry = ConfigRegistry();
    for (final source in config.extensions) {
      registry.register(source);
    }
    providers = [
      ConfigService(config),
    ];
    return DynamicModule(
      providers: providers,
      exports: [if (!isGlobal) ...(providers.map((e) => e.runtimeType))],
    );
  }
}

class ConfigRegistry {

  final Map<Type, Object> _registry = {};

  void register(Object instance) {
    _registry[instance.runtimeType] = instance;
  }

  Object get(Type type) {
    final instance = _registry[type];
    if (instance == null) {
      throw ArgumentError('No instance of type $type found in registry');
    }
    return instance;
  }

  static final ConfigRegistry _instance = ConfigRegistry._internal();

  factory ConfigRegistry() {
    return _instance;
  }

  ConfigRegistry._internal();

}

class ConfigFeatureModule extends Module {

  final List<Type> dependencies;

  ConfigFeatureModule(this.dependencies);

  @override
  Future<DynamicModule> registerAsync(ApplicationConfig config) async {
    final registry = ConfigRegistry();
    final providers = <Provider>[];
    final exports = <Type>[];

    for (final dependency in dependencies) {
      final instance = registry.get(dependency);
      providers.add(Provider.forValue(instance, asType: dependency));
      exports.add(Export(instance.runtimeType));
    }

    return DynamicModule(
      providers: providers,
      exports: exports,
    );
  }
}