import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';



class FileViewerScreen extends StatefulWidget {
  const FileViewerScreen({super.key});

  @override
  _FileViewerScreenState createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen> {
  List<FileSystemEntity> files = [];
  bool isLoading = false;
  String currentPath = '';

  @override
  void initState() {
    super.initState();
    _checkPermissionAndLoadFiles();
  }

  Future<void> _checkPermissionAndLoadFiles() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
    }
    _loadFiles();
  }

  Future<Directory?> _getDirectory() async {
    try {
      if (Platform.isIOS) {
        // Для iOS используем getApplicationDocumentsDirectory
        final directory = await getApplicationDocumentsDirectory();
        return directory;
      } else if (Platform.isAndroid) {
        // Для Android используем путь к Downloads
        return Directory('/data/user/0/com.alippe.alippepro_v1/app_flutter/');
      }
    } catch (e) {
      print('Error getting directory: $e');
    }
    return null;
  }

  Future<void> _loadFiles() async {
    setState(() {
      isLoading = true;
    });

    try {
      final directory = await _getDirectory();
      
      if (directory != null && await directory.exists()) {
        currentPath = directory.path;
        final entities = await directory.list().toList();
        setState(() {
          files = entities.where((entity) {
            final extension = entity.path.toLowerCase();
            return extension.endsWith('.pdf') || 
                   extension.endsWith('.doc') || 
                   extension.endsWith('.docx');
          }).toList();
          
          // Сортируем файлы по имени
          files.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
        });
      } else {
        print('Директория не существует');
      }
    } catch (e) {
      print('Error loading files: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _openFile(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось открыть файл: ${result.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при открытии файла: $e')),
      );
    }
  }

  String _getFileSize(File file) {
    try {
      int bytes = file.lengthSync();
      if (bytes <= 0) return "0 B";
      const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
      var i = (log(bytes) / log(1024)).floor();
      return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Файлдар'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFiles,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Текущая папка: $currentPath',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : files.isEmpty
                    ? const Center(child: Text('Файлы не найдены'))
                    : ListView.builder(
                        itemCount: files.length,
                        itemBuilder: (context, index) {
                          final file = files[index];
                          final fileName = file.path.split('/').last;
                          final fileExtension = fileName.split('.').last.toLowerCase();
                          
                          IconData iconData;
                          Color iconColor;
                          if (fileExtension == 'pdf') {
                            iconData = Icons.picture_as_pdf;
                            iconColor = Colors.red;
                          } else if (fileExtension == 'doc' || fileExtension == 'docx') {
                            iconData = Icons.description;
                            iconColor = Colors.blue;
                          } else {
                            iconData = Icons.insert_drive_file;
                            iconColor = Colors.grey;
                          }

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: ListTile(
                              leading: Icon(iconData, color: iconColor, size: 36),
                              title: Text(fileName),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(fileExtension.toUpperCase()),
                                  Text(_getFileSize(File(file.path))),
                                ],
                              ),
                              onTap: () => _openFile(file.path),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}