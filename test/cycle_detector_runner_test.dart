import 'package:cyclic_dependency_checks/cycle_detection/cycle_detector.dart';
import 'package:cyclic_dependency_checks/cycle_detection/cycle_detector_runner.dart';
import 'package:cyclic_dependency_checks/cycle_detection/module_dependency.dart';
import 'package:test/test.dart';

class TestCycleDetector extends CycleDetector {
  List<List<ModuleDependency>> stubbedCycles = [];
  String? recordedPackagePath;
  int? recordedMaxDepth;

  @override
  Future<List<List<ModuleDependency>>> detect(String packagePath, {int? maxDepth}) async {
    recordedPackagePath = packagePath;
    recordedMaxDepth = maxDepth;
    return stubbedCycles;
  }
}

class RecordingPrinter extends Printer {
  final List<String> outLog = [];
  final List<String> errLog = [];

  out(String text) => outLog.add(text);

  err(String text) => errLog.add(text);
}

void main() {
  test('with no arguments, on success', () async {
    final printer = RecordingPrinter();
    final detector = TestCycleDetector();
    final runner = CycleDetectorRunner(detector: detector, printer: printer);

    final success = await runner.run([]);

    expect(success, isTrue);
    expect(printer.errLog, isEmpty);
    expect(detector.recordedPackagePath, equals('.'));
    expect(detector.recordedMaxDepth, isNull);
  });

  test('with no arguments, on error', () async {
    final printer = RecordingPrinter();
    final detector = TestCycleDetector()
      ..stubbedCycles.add([
        ModuleDependency(from: Module('a'), to: Module('b')),
        ModuleDependency(from: Module('b'), to: Module('a')),
      ]);
    final runner = CycleDetectorRunner(detector: detector, printer: printer);

    final success = await runner.run([]);

    expect(success, isFalse);
    expect(printer.errLog, contains('module:a -> module:b -> module:a'));
  });

  test('with full length args', () async {
    final printer = RecordingPrinter();
    final detector = TestCycleDetector();
    final runner = CycleDetectorRunner(detector: detector, printer: printer);

    await runner.run([
      '--path', '/some/path',
      '--max-depth', '10',
    ]);

    expect(detector.recordedPackagePath, equals('/some/path'));
    expect(detector.recordedMaxDepth, equals(10));
  });

  test('with short name args', () async {
    final printer = RecordingPrinter();
    final detector = TestCycleDetector();
    final runner = CycleDetectorRunner(detector: detector, printer: printer);

    await runner.run([
      '-p', '/some/path',
      '-d', '10',
    ]);

    expect(detector.recordedPackagePath, equals('/some/path'));
    expect(detector.recordedMaxDepth, equals(10));
  });

  test('with invalid arguments', () async {
    final printer = RecordingPrinter();
    final detector = TestCycleDetector();
    final runner = CycleDetectorRunner(detector: detector, printer: printer);

    final success = await runner.run([
      '--oops'
    ]);

    expect(success, equals(false));
    expect(detector.recordedPackagePath, isNull);
    expect(detector.recordedMaxDepth, isNull);
  });
}
