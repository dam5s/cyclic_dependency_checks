import 'dart:io';

import 'package:cyclic_dependency_checks/cycle_detection/cycle_detector_runner.dart';

void main(List<String> args) async {
  final success = await CycleDetectorRunner().run(args);

  if (!success) {
    exit(1);
  }
}
