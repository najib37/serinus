import 'package:serinus/serinus.dart';
import 'package:serinus_config/src/config_service.dart';

class ConditionalModule extends Module {

  final Module module;

  bool Function(Map<String, dynamic> environment) condition;

  ConditionalModule._({required this.module, required this.condition});

  static Module registerWhen({
    required Module module,
    required bool Function(Map<String, dynamic> environment) condition,
  }) {
    return Module.composed(
      (context) async {
        final configService = context.use<ConfigService>();
        final result = condition(configService.config);
        if (!result) {
          return EmptyModule();
        }
        return module;
      },
      inject: [
        ConfigService
      ]
    );
  }

  static Module registerWhenEnv({
    required Module module,
    required String envVar,
  }) {
    return registerWhen(
      module: module,
      condition: (env) => env[envVar] == true,
    );
  }
  
}

class EmptyModule extends Module {
}