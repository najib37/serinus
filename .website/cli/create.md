# Create

The `create` command is used to create a new Serinus project.

## Usage

To create a new Serinus project, run the following command:

```bash
serinus create <project-name>
```

This command will create a new directory with the name `<project-name>` and will generate the necessary files to start a new Serinus project.

If you want to use a different name for the project, you can use the `--project-name` flag:

```bash
serinus create . --project-name <project-name>
```

This command will try to create in the current directory the necessary files to start a new Serinus project with the name `<project-name>`.

## Templates

By default, the `create` command will use the `base_application` template to generate the project files. However, you can specify a different template using the `--template` flag:

```bash
serinus create <project-name> --template <template-name>
```

Currently the CLI supports the following templates:

- `base_application`: A basic Serinus application template with a simple structure and minimal dependencies. This is the default template used when no template is specified.
- `saas`: A more complete Serinus application template that includes additional features and dependencies, such as authentication, database integration, and more complex project structure.
- `base_plugin`: A basic Serinus plugin template with a simple structure and minimal dependencies. This template is intended for creating Serinus plugins rather than full applications. 