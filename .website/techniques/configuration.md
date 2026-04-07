# Config

A lot of times, applications need to manage configuration variables, such as database connection strings, API keys, and other sensitive information. The `serinus_config` plugin provides a simple way to manage these configuration variables using environment variables.

::: info
This plugin uses the [dotenv_plus](https://pub.dev/packages/dotenv_plus) package to load the .env files.
:::

## Installation

The installation of the plugin is immediate and can be done using the following command:

```bash
dart pub add serinus_config
```

## Getting Started

Once the plugin is installed, you can import the `ConfigModule` in your root module.

```dart
import 'package:serinus_config/serinus_config.dart';
import 'package:serinus/serinus.dart';

class AppModule extends Module {

  AppModule() : super(
    imports: [
      ConfigModule(
        sources: [
          EnvFile('.env'),
        ]
      )
    ]
  );

}
```

The above code will load the `.env` file located in the root of your project and make the variables available throughout the application using the `ConfigService`.

To use the `ConfigService`, you need to inject it into your controller or service using the `context.use<ConfigService>()` method.

```dart
import 'package:serinus/serinus.dart';

class MyController extends Controller {

  MyController() : super('/') {
    on(Route.get('/'), _handleHelloWorld);
  }

  String _handleHelloWorld(RequestContext context) {
    final config = context.use<ConfigService>();
    final apiUrl = config.get('API_URL');
    return 'API URL is: $apiUrl';
  }

}

```

## Available Sources

Currently the `serinus_config` plugin supports the following sources:

- `EnvFile`: Loads configuration variables from a .env file. You can specify the path to the .env file as an argument.
- `SystemEnv`: Loads configuration variables from the environment variables of the operating system.
- `JsonFile`: Allows you to load configuration variables from a JSON file. You can specify the path to the JSON file as an argument.

You can use multiple sources at the same time, and the plugin will merge the configuration variables from all sources. If there are duplicate keys, the values from the last source will take precedence.

Also, you can create your own custom sources by implementing the `ConfigSource` interface.

```dart
import 'package:serinus_config/serinus_config.dart';
import 'package:serinus/serinus.dart';

class AppModule extends Module {
  AppModule() : super(
    imports: [
      ConfigModule(
        sources: [
          EnvFile('.env.production'),
          SystemEnv(),
        ]
      )
    ]
  );
}
```

## Use module globally

If you want to use the `ConfigModule` globally, you can set the `global` property to `true` when importing the module.

```dart
import 'package:serinus_config/serinus_config.dart';
import 'package:serinus/serinus.dart';

class AppModule extends Module {
  AppModule() : super(
    imports: [
      ConfigModule(
        sources: [
          EnvFile('.env'),
        ],
        isGlobal: true,
      )
    ]
  );
}
```

## Custom configuration classes

`dotenv_plus` allows you to define custom extensions to parse the configuration variables into custom classes. This can be useful to group related configuration variables together.

For example, you can define a `DatabaseConfig` class to group the database connection variables together.

```dart
import 'package:serinus_config/serinus_config.dart';
import 'package:serinus/serinus.dart';

class DatabaseConfig {
  final String host;
  final int port;
  final String username;
  final String password;

  DatabaseConfig({
    required this.host,
    required this.port,
    required this.username,
    required this.password,
  });
}

// Configuration initialization
class AppModule extends Module {
  AppModule() : super(
    imports: [
      ConfigModule(
        sources: [
          EnvFile('.env'),
        ],
        extensions: [
          return (ConfigBuilder builder) {
            builder.map<DatabaseConfig>('database', (ctx) {
              return DatabaseConfig(
                host: ctx.get<String>('DB_HOST'),
                port: ctx.get<int>('DB_PORT'),
                username: ctx.get<String>('DB_USERNAME'),
                password: ctx.get<String>('DB_PASSWORD'),
              );
            });
          };
        ]
      )
    ]
  );
}
```

Now we can call the `get` method with the `DatabaseConfig` type to get the configuration variables as an instance of the `DatabaseConfig` class.

```dart
final config = context.use<ConfigService>();
final databaseConfig = config.get<DatabaseConfig>('database');
print(databaseConfig.host); // prints the value of DB_HOST
```

## Namespaces

The `serinus_config` plugin also supports namespaces, which allow you to group related configuration variables together under a common prefix. This can be useful to avoid naming conflicts and to organize your configuration variables better.

To use namespaces, you can specify the `useSectionKeys` property when importing the `ConfigModule`.

```dart
import 'package:serinus_config/serinus_config.dart';
import 'package:serinus/serinus.dart';

class AppModule extends Module {
  AppModule() : super(
    imports: [
      ConfigModule(
        sources: [
          EnvFile('.env'),
        ],
        useSectionKeys: true,
      )
    ]
  );
}
```

By default the section keys are separated by a dot (`.`), but you can change the separator by specifying the `sectionSeparator` property.

```dart
import 'package:serinus_config/serinus_config.dart';
import 'package:serinus/serinus.dart';

class AppModule extends Module {
    AppModule() : super(
      imports: [
        ConfigModule(
          sources: [
            EnvFile('.env'),
          ],
          useSectionKeys: true,
          sectionSeparator: '_',
        )
      ]
    );
  }
```

With the above configuration, if you have a variable named `DATABASE_HOST` in your .env file, you can access it using the `database.host` key.

```dart
final config = context.use<ConfigService>();
final databaseHost = config.get<String>('database.host');
print(databaseHost); // prints the value of DATABASE_HOST
```

Also you can lookup at a specific section of the configuration using the `section` method.

```dart
final config = context.use<ConfigService>();
final databaseConfig = config.section('database'); // This returns a Config object that contains only the variables that start with 'database.'
final host = databaseConfig.get<String>('host');
print(host); // prints the value of DATABASE_HOST
```

## Schema validation

It is standard practice to validate the configuration variables before using them in the application and throw an error if any required variable is missing or if any variable has an invalid value. You can use the `schema` property of the `ConfigModule` to validate the configuration variables against a schema.

In this example we will use the `acanthis` package to define a schema for our configuration variables.

```dart
import 'package:serinus_config/serinus_config.dart';
import 'package:acanthis/acanthis.dart';
import 'package:serinus/serinus.dart';

class AppModule extends Module {
  AppModule() : super(
    imports: [
      ConfigModule(
        sources: [
          EnvFile('.env'),
        ],
        schema: (Map<String, dynamic> config) {
          final schema = object({
            'API_URL': string().notEmpty(),
            'DB_HOST': string().notEmpty(),
            'DB_PORT': integer(),
            'DB_USERNAME': string().notEmpty(),
            'DB_PASSWORD': string().notEmpty(),
          }).passthrough();
          final result = schema.parse(config);
          return result.value;
        },
      )
    ]
  );
}
```

## Conditional module configuration

You can register Modules conditionally based on the value of a configuration variable. This can be useful to load different modules based on the environment (e.g., development, production, etc.).

```dart
import 'package:serinus_config/serinus_config.dart';
import 'package:serinus/serinus.dart';

class AppModule extends Module {

  AppModule() : super(
    imports: [
      ConfigModule(
        sources: [
          EnvFile('.env'),
        ]
      ),
      ConditionalModule.registerWhenEnv(
        module: FooModule(),
        envVar: 'FOO_ENABLED',
      )
    ]
  );

}
```

In the above example, the `FooModule` will be registered only if the `FOO_ENABLED` environment variable is set to `true`. You can also specify a custom condition yourself, a function receiving the configuration values and that must return a boolean.

```dart
import 'package:serinus_config/serinus_config.dart';
import 'package:serinus/serinus.dart';

class AppModule extends Module {
  AppModule() : super(
    imports: [
      ConfigModule(
        sources: [
          EnvFile('.env'),
        ]
      ),
      ConditionalModule.registerWhen(
        module: FooModule(),
        condition: (config) => config.get<bool>('FOO_ENABLED') == true,
      )
    ]
  );

}
```

## Interpolation

You can also use interpolation to reference other configuration variables in your configuration values. This can be useful to avoid duplication and to create more complex configuration values.

```txt
APP_URL=http://localhost:3000
API_URL=${APP_URL}/api
```

In the above example, the `API_URL` variable will be resolved to `http://localhost:3000/api` by referencing the `APP_URL` variable.

To enable this feature, you need to set the `useInterpolation` property to `true` when importing the `ConfigModule`.

```dart
import 'package:serinus_config/serinus_config.dart';
import 'package:serinus/serinus.dart';

class AppModule extends Module {
    AppModule() : super(
      imports: [
        ConfigModule(
          sources: [
            EnvFile('.env'),
          ],
          useInterpolation: true,
        )
      ]
    );
  }
```

## Using in the main function

You can also use the `ConfigService` in the main function before the application is initialized. This can be useful to perform some setup based on the configuration variables.

First of all you need to import the ConfigModule with the `isGlobal` property set to `true` in your root module.

```dart
import 'package:serinus_config/serinus_config.dart';
import 'package:serinus/serinus.dart';

class AppModule extends Module {
  AppModule() : super(
    imports: [
      ConfigModule(
        sources: [
          EnvFile('.env'),
        ],
        isGlobal: true,
      )
    ]
  );
}
```

Also in the main function you need to call the `initialize` method of the application to load the module scopes and make the `ConfigService` available.

```dart
import 'package:serinus_config/serinus_config.dart';
import 'package:serinus/serinus.dart';

import 'app_module.dart';

void main() async {
  final app = await serinus.createApplication(
    entrypoint: AppModule(),
  );
  await app.initialize();
  final config = app.useService<ConfigService>();
  final apiUrl = config.get('API_URL');
  print('API URL is: $apiUrl');
  await app.serve();
}
```
