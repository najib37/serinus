# Changelog

## 3.0.0

- Improved `ConfigModule` to support multiple configuration sources, including environment variables and .env files. The `ConfigModule` now accepts a list of `ConfigSource` instances, allowing for greater flexibility in how configuration is loaded. This change also includes updates to the documentation and examples to reflect the new usage of the `ConfigModule`.
- Added ConditionalModule to allow for conditional module registration based on environment variables. This feature enables developers to register modules only when certain conditions are met, such as when a specific environment variable is set to a particular value. This can be useful for enabling or disabling features based on the deployment environment (e.g., development, staging, production).

## 2.0.0

- Updated `serinus_config` to be compatible with `serinus` version `2.x.x`.

## 1.0.6

- Updated `serinus_config` to be compatible with `serinus` version `1.x.x`.

## 1.0.5

- Updated `serinus_config` to be compatible with `serinus` version `0.6.1`.

## 1.0.4

## 1.0.3

- Updated `serinus_config` to be compatible with `serinus` version `0.6`.

## 1.0.2

- Update dependencies.

## 1.0.1

- Update dependencies.

## 0.1.0

- Initial version.
