import 'dart:io';

import 'package:args/args.dart';

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
      ..addOption('max-depth', abbr: 'd');

    final parsedArgs = parser.tryParse(args);
    if (parsedArgs == null) {
      return false;
    }

    final path = parsedArgs.getString('path', fallback: '.');
    final maxDepth = parsedArgs.tryGetInt('max-depth');

    final stopwatch = Stopwatch()..start();
    final cycles = await detector.detect(path, maxDepth: maxDepth);

    stopwatch.stop();

    final formattedTime = stopwatch.elapsed.toString().substring(0, 11);

    if (cycles.isNotEmpty) {
      printer.err('Detected cycles after ${formattedTime}');

      for (final cycle in cycles) {
        printer.err(cycle.path().join(' -> '));
      }

      return false;
    }

    printer.out('No import cycles were detected after ${formattedTime}');

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
  String getString(String name, {required String fallback}) {
    return this[name] ?? fallback;
  }

  int? tryGetInt(String name) {
    final value = this[name];

    if (value == null) {
      return null;
    }

    return int.tryParse(value);
  }
}
