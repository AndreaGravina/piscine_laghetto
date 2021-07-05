import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/file_provider.dart';

class ListItem extends StatelessWidget {
  const ListItem({required this.file, required this.image, Key? key})
      : super(key: key);

  final FileItem file;
  final Image image;

  static String formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    int i = (log(bytes) / log(1024)).floor();
    String byteSize = (bytes / pow(1024, i)).toStringAsFixed(0);
    var sizeString = '$byteSize ${suffixes[i]}';
    return sizeString;
  }

  String convertDateTimeDisplay(String date) {
    final DateFormat displayFormater = DateFormat('yyyy-MM-dd HH:mm:ss');
    final DateFormat serverFormater = DateFormat('dd/MM/yyyy');
    final DateTime displayDate = displayFormater.parse(date);
    final String formatted = serverFormater.format(displayDate);
    return formatted;
  }

  @override
  Widget build(BuildContext context) {

    String size;

    if (file.size == null)
      size = '-';
    else
      size = formatBytes(int.parse(file.size));

    var date = convertDateTimeDisplay(file.updateDate);

    return Container(
      height: 60,
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                fit: FlexFit.tight,
                flex: 9,
                child: Row(
                  children: [
                    Container(
                      height: 60,
                      padding: EdgeInsets.all(15),
                      child: image,
                    ),
                    Flexible(
                      fit: FlexFit.tight,
                        child: Text(
                          file.name,
                          overflow: TextOverflow.ellipsis,
                        )),
                  ],
                ),
              ),
              Flexible(fit: FlexFit.tight, flex: 5, child: Text(date)),
              Flexible(fit: FlexFit.tight, flex: 3, child: Text(size)),
            
            ],
          ),
          Expanded(
            child: Container(),
          ),
          Divider(
            endIndent: 0,
            height: 0,
            indent: 0,
            thickness: 0,
          )
        ],
      ),
    );
  }
}
