import 'dart:io';

import 'package:cyclic_dependency_checks/cycle_detection/cycle_detector.dart';
import 'package:cyclic_dependency_checks/cycle_detection/module_dependency.dart';
import 'package:cyclic_dependency_checks/cycle_detection/module_dependency_graph.dart';

void main(List<String> args) async {
  await _run(path: args.firstOrNull ?? '.');
}

Future _run({required String path}) async {
  final stopwatch = Stopwatch()..start();
  final cycles = await CycleDetector().detect(path);
  stopwatch.stop();

  final formattedTime = stopwatch.elapsed.toString().substring(0, 11);

  if (cycles.isNotEmpty) {
    stderr.writeln('Detected cycles after ${formattedTime}');
    for (final cycle in cycles) {
      cycle.printError();
    }
    exit(1);
  }

  stdout.writeln('No import cycles were detected after ${formattedTime}');
}

extension ErrorPrinting on List<ModuleDependency> {
  void printError() {
    stderr.writeln(path().join(' -> '));
  }
}
