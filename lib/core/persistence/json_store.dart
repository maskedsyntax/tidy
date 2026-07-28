import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Atomic JSON file store under the app support directory.
class JsonStore {
  JsonStore({this.fileName = 'data.json'});

  final String fileName;
  File? _file;

  Future<File> _resolve() async {
    if (_file != null) return _file!;
    final dir = await getApplicationSupportDirectory();
    final tidyDir = Directory('${dir.path}/tidy');
    if (!await tidyDir.exists()) {
      await tidyDir.create(recursive: true);
    }
    _file = File('${tidyDir.path}/$fileName');
    return _file!;
  }

  Future<Map<String, dynamic>?> read() async {
    try {
      final file = await _resolve();
      if (!await file.exists()) return null;
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> write(Map<String, dynamic> data) async {
    final file = await _resolve();
    final tmp = File('${file.path}.tmp');
    final encoded = const JsonEncoder.withIndent('  ').convert(data);
    await tmp.writeAsString(encoded, flush: true);
    if (await file.exists()) {
      await file.delete();
    }
    await tmp.rename(file.path);
  }

  Future<void> clear() async {
    final file = await _resolve();
    if (await file.exists()) {
      await file.delete();
    }
  }
}
