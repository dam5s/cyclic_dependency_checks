# Cyclic Dependency Checks

This is a small cyclic dependency checker for Dart projects.

## Background

Code organization is one of the most common problems we see in frontend applications
(or even backend applications). Ever since the advent of Ruby on Rails, engineers started organizing code by "function
in the framework", for example a `Controller` goes into the `controllers` folder.
The problem with this approach is that it makes the codebase harder to manage / re-structure / re-architecture 
over time.

If you ever need to extract a specific feature set, you will have to go all over the codebase to extract it.
It might not even be possible because of tight coupling.

**Tight coupling is introduced by cyclic dependencies.**

This tool assumes that your code is organized by features
instead of "which part of the framework does this match?".
Our [flutter-starter](https://github.com/initialcapacity/flutter-starter) shows an example of code organization 
and usage of this tool.

## Setup

From inside one of your Dart projects

```
dart pub add cyclic_dependency_checks --git-url=https://github.com/dam5s/cyclic_dependency_checks.git --git-ref=release/0.2.0
```

`release/0.2.0` here is a tag from [one of the releases](https://github.com/dam5s/cyclic_dependency_checks/releases). 

## Running it

Again, from inside your Dart project

```
dart run cyclic_dependency_checks
```

## Command-Line flags

 * `--path` or `-p` for the path to the module that is checked, path should be a folder containing a `pubspec.yaml`,
   defaults to current working directory.
 * `--mono-repo` or `-m` as an alternative to path, use the path to your Melos based mono-repo
   to run against all its components.
 * `--exclude` or `-x` can be used multiple times or as coma separated values to exclude specified projects from the mono-repo.
 * `--max-depth` or `-d` to limit the depth of the check, defaults to no max depth.
