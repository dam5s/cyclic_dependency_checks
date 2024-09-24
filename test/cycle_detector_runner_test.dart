import 'package:cyclic_dependency_checks/cycle_detection/cycle_detector.dart';
import 'package:cyclic_dependency_checks/cycle_detection/cycle_detector_runner.dart';
import 'package:cyclic_dependency_checks/cycle_detection/module_dependency.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;

class TestCycleDetector extends CycleDetector {
  List<List<ModuleDependency>> stubbedCycles = [];
  List<String> recordedPackagePaths = [];
  List<int?> recordedMaxDepths = [];

  @override
  Future<List<List<ModuleDependency>>> detect(String packagePath, {int? maxDepth}) async {
    recordedPackagePaths.add(packagePath);
    recordedMaxDepths.add(maxDepth);
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
    expect(detector.recordedPackagePaths, equals(['.']));
    expect(detector.recordedMaxDepths, equals([null]));
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

  group('specifying the path', () {
    test('with full length args', () async {
      final printer = RecordingPrinter();
      final detector = TestCycleDetector();
      final runner = CycleDetectorRunner(detector: detector, printer: printer);

      await runner.run(['--path', '/some/path', '--max-depth', '10']);

      expect(detector.recordedPackagePaths, equals(['/some/path']));
      expect(detector.recordedMaxDepths, equals([10]));
    });

    test('with short name args', () async {
      final printer = RecordingPrinter();
      final detector = TestCycleDetector();
      final runner = CycleDetectorRunner(detector: detector, printer: printer);

      await runner.run(['-p', '/some/path', '-d', '10']);

      expect(detector.recordedPackagePaths, equals(['/some/path']));
      expect(detector.recordedMaxDepths, equals([10]));
    });
  });

  group('specifying the path to a melos mono repo', () {
    test('with long argument', () async {
      final printer = RecordingPrinter();
      final detector = TestCycleDetector();
      final runner = CycleDetectorRunner(detector: detector, printer: printer);

      await runner.run([
        '--mono-repo',
        'test_resources/example_melos_codebase',
        '--max-depth',
        '5',
      ]);

      expect(detector.recordedPackagePaths, [
        path.join('test_resources', 'example_melos_codebase', 'project_a'),
        path.join('test_resources', 'example_melos_codebase', 'project_b'),
      ]);
      expect(detector.recordedMaxDepths, [5, 5]);
    });

    test('with short argument', () async {
      final printer = RecordingPrinter();
      final detector = TestCycleDetector();
      final runner = CycleDetectorRunner(detector: detector, printer: printer);

      await runner.run(['-m', 'test_resources/example_melos_codebase', '-d', '5']);

      expect(detector.recordedPackagePaths, [
        path.join('test_resources', 'example_melos_codebase', 'project_a'),
        path.join('test_resources', 'example_melos_codebase', 'project_b'),
      ]);
      expect(detector.recordedMaxDepths, [5, 5]);
    });

    test('excluding a specific subproject', () async {
      final printer = RecordingPrinter();
      final detector = TestCycleDetector();
      final runner = CycleDetectorRunner(detector: detector, printer: printer);

      final projectPath = 'test_resources/example_melos_codebase';
      await runner.run(['-m', projectPath, '-x', 'project_a', '-x', 'project_c']);

      expect(detector.recordedPackagePaths, [
        path.join('test_resources', 'example_melos_codebase', 'project_b'),
      ]);
    });
  });

  test('with invalid arguments', () async {
    final printer = RecordingPrinter();
    final detector = TestCycleDetector();
    final runner = CycleDetectorRunner(detector: detector, printer: printer);

    final success = await runner.run(['--oops']);

    expect(success, equals(false));
    expect(detector.recordedPackagePaths, []);
    expect(detector.recordedMaxDepths, []);
  });
}
