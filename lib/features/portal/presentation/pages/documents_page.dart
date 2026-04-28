import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class DocumentsPage extends StatelessWidget {
  const DocumentsPage({super.key});

  static final _documents = [
    _DocumentItem(
      name: 'ПВТР от 07.03.2025 №07.03.2025-1',
      asset: 'assets/documents/ПВТР от 07.03.2025 №07.03.2025-1.docx',
      type: 'docx',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: _documents.map((doc) {
        return ListTile(
          leading: _FileIcon(type: doc.type),
          title: Text(doc.name),
          subtitle: Text('${doc.type.toUpperCase()} документ'),
          trailing: const Icon(Icons.open_in_new),
          onTap: () => _openDocument(context, doc),
        );
      }).toList(),
    );
  }

  Future<void> _openDocument(BuildContext context, _DocumentItem doc) async {
    try {
      final byteData = await DefaultAssetBundle.of(context).load(doc.asset);
      final tempDir = await getTemporaryDirectory();
      final fileName = doc.asset.split('/').last;
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      if (!context.mounted) return;
      await OpenFile.open(file.path);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка открытия файла: $e')),
      );
    }
  }
}

class _DocumentItem {
  const _DocumentItem({
    required this.name,
    required this.asset,
    required this.type,
  });

  final String name;
  final String asset;
  final String type;
}

class _FileIcon extends StatelessWidget {
  const _FileIcon({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final icon = switch (type) {
      'pdf' => Icons.picture_as_pdf,
      'txt' => Icons.description,
      'doc' => Icons.article,
      'docx' => Icons.article,
      _ => Icons.insert_drive_file,
    };
    final color = switch (type) {
      'pdf' => Colors.red,
      'txt' => Colors.grey,
      'doc' => Colors.blue,
      'docx' => Colors.blue,
      _ => Colors.grey,
    };
    return Icon(icon, color: color);
  }
}
