# Quick Start

In this guide you'll go from zero to a running Serinus application, then extend it with typed request bodies and validation. By the end you'll have a working Todo API and a clear picture of how the framework fits together.

## Prerequisites

Make sure you have Dart **3.9.0 or higher** installed. If not, follow the [official instructions](https://dart.dev/get-dart).

## Scaffold the project

Install the Serinus CLI and create a new project:

```bash
dart pub global activate serinus_cli
serinus create my_project
cd my_project
dart pub get
```

This creates the following structure:

```
my_project
├── bin
│   └── my_project.dart       # Entry point
├── lib
│   ├── app_controller.dart   # Route handlers
│   ├── app_module.dart       # Module wiring
│   ├── app_provider.dart     # Business logic
│   ├── todo.dart             # Todo model
│   └── my_project.dart       # App bootstrap
└── pubspec.yaml
```

## Run the application

```bash
serinus run --dev
```

Your server is now running at `http://localhost:3000`. The `--dev` flag enables hot restart which reloads the server automatically whenever you save a file.

Try it:

```bash
curl http://localhost:3000
```

That's Serinus running. Now let's look at how the pieces connect.

## How it's structured

Open `lib/my_project.dart`:

```dart
import 'package:serinus/serinus.dart';

Future<void> bootstrap() async {
  final app = await serinus.createApplication(
    entrypoint: AppModule(),
  );
  await app.serve();
}
```

Every Serinus application starts with a root **Module**. Modules group related controllers and providers together, similar to how NestJS or Angular organise code. The `AppModule` you see here is the entry point of that tree.

Open `lib/app_controller.dart` and you'll see routes defined with `on()`:

```dart
class AppController extends Controller {
  AppController() : super('/') {
    on(Route.get('/'), _handleRequest);
  }

  Future<String> _handleRequest(RequestContext context) async {
    return 'Hello, World!';
  }
}
```

Controllers declare a **path prefix** in their constructor (`'/'` here), then register individual routes with `on()`. The return value of the handler is automatically serialised and sent as the response.

## Add typed request bodies

Now let's build something real. We'll add a `POST /` route that creates a Todo from a request body with full type safety and validation.

### Step 1 - Define your models

Open `lib/todo.dart` and update it with both a `Todo` response model and a `TodoDto` input model:

```dart
class Todo with JsonObject {
  final String title;
  bool isDone;

  Todo({required this.title, this.isDone = false});

  @override
  Map<String, dynamic> toJson() => {
    'title': title,
    'isDone': isDone,
  };
}

class TodoDto {
  final String title;

  const TodoDto({required this.title});

  factory TodoDto.fromJson(Map<String, dynamic> json) {
    return TodoDto(title: json['title']);
  }
}
```

`Todo` uses the `JsonObject` mixin so Serinus knows how to serialise it into a response. `TodoDto` has a `fromJson` factory so Serinus knows how to deserialise incoming request bodies into it.

### Step 2 - Generate the ModelProvider

Serinus uses a `ModelProvider` to wire up serialisation. The CLI generates it for you:

```bash
serinus generate models
```

This creates `lib/model_provider.dart`:

```dart
import 'package:serinus/serinus.dart';
import 'todo.dart';

class MyProjectModelProvider extends ModelProvider {
  @override
  Map<String, Function> get toJsonModels => {
    'Todo': (model) => (model as Todo).toJson(),
  };

  @override
  Map<String, Function> get fromJsonModels => {
    'TodoDto': (json) => TodoDto.fromJson(json),
  };
}
```

Register it in `lib/my_project.dart`:

```dart
import 'package:serinus/serinus.dart';
import 'app_module.dart';
import 'model_provider.dart';

Future<void> bootstrap() async {
  final app = await serinus.createApplication(
    entrypoint: AppModule(),
    host: '0.0.0.0',
    port: 3000,
    modelProvider: MyProjectModelProvider(),
  );
  await app.serve();
}
```

### Step 3 - Add a validation Pipe

Pipes run before your handler and can validate or transform incoming data. Create `lib/todo_pipe.dart`:

```dart
import 'package:serinus/serinus.dart';
import 'todo.dart';

class TodoPipe extends Pipe {
  @override
  Future<void> transform(ExecutionContext context) async {
    if (context.argumentsHost is! HttpArgumentsHost) return;

    final body = context.switchToHttp().body;

    if (body is TodoDto) {
      if (body.title.isEmpty) {
        throw BadRequestException('Title cannot be empty');
      }
      return;
    }

    throw BadRequestException('Invalid request body');
  }
}
```

### Step 4 - Wire it into the controller

Update `lib/app_controller.dart` to add the typed POST route:

```dart
import 'package:serinus/serinus.dart';
import 'app_provider.dart';
import 'todo.dart';
import 'todo_pipe.dart';

class AppController extends Controller {
  AppController() : super('/') {
    on(Route.get('/'), _getTodos);

    on<Todo, TodoDto>(
      Route.post('/', pipes: {TodoPipe()}),
      _createTodo,
    );
  }

  Future<List<Todo>> _getTodos(RequestContext context) async {
    return context.use<AppProvider>().todos;
  }

  Future<Todo> _createTodo(RequestContext<TodoDto> context) async {
    context.use<AppProvider>().addTodo(context.body.title);
    return context.use<AppProvider>().todos.last;
  }
}
```

Notice `on<Todo, TodoDto>`, the two type parameters tell Serinus that this route expects a `TodoDto` body and returns a `Todo`. Inside `_createTodo`, `context.body` is already typed as `TodoDto`. No casting, no `Map<String, dynamic>` fishing.

### Try it

```bash
# Create a todo
curl -X POST http://localhost:3000 \
  -H "Content-Type: application/json" \
  -d '{"title": "Buy milk"}'

# Get all todos
curl http://localhost:3000
```

## What you've learned

In this guide you've seen the four building blocks of every Serinus application:

- **Modules**: organise your application into cohesive slices
- **Controllers**: define routes and handle requests
- **Providers**: hold business logic, injected via `context.use<T>()`
- **Pipes**: validate or transform data before it reaches a handler

From here, explore the [Controllers](/controllers) and [Pipes](/pipes) docs to go deeper, or jump straight to [Authentication](/security/authentication) if you're building something that needs protected routes.
