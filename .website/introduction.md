# Introduction

Serinus is purpose-built for Flutter and Dart developers who want to write their backend in the exact same language they use for their frontend. If you are looking to unify your tech stack, seamlessly share data models across environments, and build robust server-side applications without the cognitive load of context-switching, this framework is for you.

When it comes to your backend, reliability is everything. Serinus is designed from the ground up for production deployments and stability. Built directly on Dart's bare HttpServer for maximum performance, it still securely provides a way to use existing shelf middlewares and handlers, allowing you to leverage battle-tested community packages without compromise.

Furthermore, Serinus isn't just a standalone tool, it is backed by the Avesbox ecosystem, which aims to provide a complete, mature environment for building web applications in Dart.

## Installation

To get started, you can either scaffold the project with the Serinus CLI, or create a new Dart project and add the Serinus package to the `pubspec.yaml` file.

To scaffold the project with the Serinus CLI, run the following command. This command will create a new Dart project with the Serinus package already added to the `pubspec.yaml` file and the necessary files to get started.

```bash
dart pub global activate serinus_cli
serinus create my_project
```

You can now navigate to the project folder and run the following command to start the server.

```bash
dart pub get
serinus run --dev
```

This will start the server on `http://localhost:3000` in development mode allowing you to leverage on an hot-restarter to automatically restart the server when a file is changed.


