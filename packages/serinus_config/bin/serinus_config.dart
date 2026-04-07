import 'package:serinus/serinus.dart';
import 'package:serinus_config/serinus_config.dart';
import 'package:serinus_config/src/conditional_module.dart';

class MainController extends Controller {
  MainController() : super('/') {
    on(Route.get('/'), (RequestContext context) async {
      return context.use<TestProvider>().value;
    });
  }
}

class TestProvider extends Provider {
  final String value;

  TestProvider(this.value);
}

class TestModule extends Module {
  TestModule()
    : super(
        providers: [TestProvider('Hello, world!')],
        exports: [TestProvider],
      );
}

class MainModule extends Module {
  MainModule()
    : super(
        imports: [
          ConfigModule(sources: [EnvFile('.env')], isGlobal: true),
          ConditionalModule.registerWhen(
            module: TestModule(),
            condition: (env) => env['TEST'] == true,
          ),
        ],
        controllers: [MainController()],
      );
}

void main() async {
  final app = await serinus.createApplication(entrypoint: MainModule());
  await app.initialize();
  final service = app.useService<ConfigService>();
  print('Config: ${service.config}');
  await app.serve();
}
