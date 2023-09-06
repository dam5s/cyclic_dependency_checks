import 'dart:io';

class Path {
  static final String separator = Platform.isWindows ? '\\' : '/';

  static String join(List<String> paths) => paths.join(separator);
}
