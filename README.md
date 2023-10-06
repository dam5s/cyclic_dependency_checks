# Cyclic Dependency Checks

This is a small cyclic dependency checker for Dart projects.

## Setup

From inside one of your Dart projects

```
dart pub add cyclic_dependency_checks --git-url=https://github.com/dam5s/cyclic_dependency_checks.git --git-ref=release/0.2.0
```

## Running it

Again, from inside your Dart project

```
dart run cyclic_dependency_checks
```

## Command-Line flags

 * `--path` or `-p` for the path to the module that is checked, defaults to current working directory.
 * `--max-depth` or `-d` to limit the depth of the check, defaults to no max depth.
