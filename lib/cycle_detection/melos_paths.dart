import 'dart:io';
import 'package:path/path.dart' as path;

final class MelosPaths {
  static Future<List<String>?> tryGet(String monorepoPath) async {
    final melos = Platform.isWindows ? 'melos.bat' : 'melos';

    final listResult = await Process.run(
      melos,
      ['list', '-p'],
      workingDirectory: monorepoPath,
    );

    if (listResult.exitCode != 0) {
      return null;
    }

    final output = listResult.stdout as String;
    final currentDir = Directory.current;

    return output
        .split('\n')
        .where((p) => p.trim().length > 0)
        .map((p) => path.relative(p, from: currentDir.absolute.path))
        .toList();
  }
}
