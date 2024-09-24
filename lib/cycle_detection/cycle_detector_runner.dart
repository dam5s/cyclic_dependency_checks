import 'dart:io';

import 'package:args/args.dart';
import 'package:cyclic_dependency_checks/cycle_detection/melos_paths.dart';

import 'cycle_detector.dart';
import 'module_dependency_graph.dart';

class Printer {
  out(String text) => stdout.writeln(text);

  err(String text) => stderr.writeln(text);
}

class CycleDetectorRunner {
  final CycleDetector detector;
  final Printer printer;

  CycleDetectorRunner({
    CycleDetector? detector,
    Printer? printer,
  })  : detector = detector ?? CycleDetector(),
        printer = printer ?? Printer();

  Future<bool> run(List<String> args) async {
    final parser = ArgParser()
      ..addOption('path', abbr: 'p')
      ..addOption('mono-repo', abbr: 'm')
      ..addOption('max-depth', abbr: 'd')
      ..addMultiOption('exclude', abbr: 'x');

    final parsedArgs = parser.tryParse(args);
    if (parsedArgs == null) {
      return false;
    }

    final pathArg = parsedArgs['path'];
    final monorepoArg = parsedArgs['mono-repo'];
    final maxDepthArg = parsedArgs.tryGetInt('max-depth');
    final exclusions = parsedArgs['exclude'];

    final inferredPaths = await _tryGetPaths(pathArg, monorepoArg, exclusions);
    if (inferredPaths == null) {
      printer.err(
        'Failed to infer path from arguments, only one of path or monorepo can be specified',
      );
      return false;
    }

    var success = true;

    for (final path in inferredPaths) {
      final pathSuccess = await _runForPath(path, maxDepthArg);
      success = success && pathSuccess;
    }

    return success;
  }

  Future<List<String>?> _tryGetPaths(
    String? packagePath,
    String? monorepoPath,
    List<String> exclusions,
  ) async =>
      switch ((packagePath, monorepoPath)) {
        (null, null) => ['.'],
        (String p, null) => [p],
        (null, String p) => await MelosPaths.tryGet(p, exclusions),
        (_, _) => null,
      };

  Future<bool> _runForPath(String path, int? maxDepth) async {
    final stopwatch = Stopwatch()..start();
    final cycles = await detector.detect(path, maxDepth: maxDepth);
    stopwatch.stop();

    final formattedTime = stopwatch.elapsed.toString().substring(0, 11);

    if (cycles.isNotEmpty) {
      printer.err('[$path] Detected cycles after ${formattedTime}');

      for (final cycle in cycles) {
        printer.err(cycle.path().join(' -> '));
      }

      return false;
    }

    printer.out('[$path] No cycles detected after ${formattedTime}');

    return true;
  }
}

extension _SafeParse on ArgParser {
  ArgResults? tryParse(List<String> args, {Printer? printer}) {
    try {
      return parse(args);
    } catch (e) {
      printer?.err('Failed to parse arguments');
      printer?.err(usage);
      return null;
    }
  }
}

extension _TypeSafeArgs on ArgResults {
  int? tryGetInt(String name) {
    final value = this[name];

    if (value == null) {
      return null;
    }

    return int.tryParse(value);
  }
}
