import 'package:flutter/material.dart';
import 'package:piscine_laghetto/widgets/list_stats_item.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/file_provider.dart';
import './grid_item.dart';
import './list_item.dart';

class FileView extends StatefulWidget {
  FileView(
      {required this.listView,
      required this.stats,
      this.statsFileList = const [],
      Key? key})
      : super(key: key);

  final bool listView;
  final bool stats;
  final List<FileItem> statsFileList;

  @override
  _FileViewState createState() => _FileViewState();
}

class _FileViewState extends State<FileView> {
  late ScrollController controller;

  Image pickIconFile(dynamic extension) {
    switch (extension) {
      case null:
        return Image.asset(
          'images/folder.png',
          fit: BoxFit.contain,
        );
      case 'css':
        return Image.asset(
          'images/css.png',
          fit: BoxFit.contain,
        );
      case 'csv':
        return Image.asset(
          'images/csv.png',
          fit: BoxFit.contain,
        );
      case 'doc':
        return Image.asset(
          'images/doc.png',
          fit: BoxFit.contain,
        );
      case 'html':
        return Image.asset(
          'images/html.png',
          fit: BoxFit.contain,
        );
      case 'javascript':
        return Image.asset(
          'images/javascript.png',
          fit: BoxFit.contain,
        );
      case 'jpeg':
        return Image.asset(
          'images/jpeg.png',
          fit: BoxFit.contain,
        );
      case 'jpg':
        return Image.asset(
          'images/jpg.png',
          fit: BoxFit.contain,
        );
      case 'mp4':
        return Image.asset(
          'images/mp4.png',
          fit: BoxFit.contain,
        );
      case 'pdf':
        return Image.asset(
          'images/pdf.png',
          fit: BoxFit.contain,
        );
      case 'png':
        return Image.asset(
          'images/png.png',
          fit: BoxFit.contain,
        );
      case 'ppt':
        return Image.asset(
          'images/ppt.png',
          fit: BoxFit.contain,
        );
      case 'pptx':
        return Image.asset(
          'images/pptx.png',
          fit: BoxFit.contain,
        );
      case 'rar':
        return Image.asset(
          'images/rar.png',
          fit: BoxFit.contain,
        );
      case 'svg':
        return Image.asset(
          'images/svg.png',
          fit: BoxFit.contain,
        );
      case 'txt':
        return Image.asset(
          'images/txt.png',
          fit: BoxFit.contain,
        );
      case 'xls':
        return Image.asset(
          'images/xls.png',
          fit: BoxFit.contain,
        );
      case 'xlsx':
        return Image.asset(
          'images/xlsx.png',
          fit: BoxFit.contain,
        );
      case 'xml':
        return Image.asset(
          'images/xml.png',
          fit: BoxFit.contain,
        );
      case 'zip':
        return Image.asset(
          'images/zip.png',
          fit: BoxFit.contain,
        );
      default:
        return Image.asset(
          'images/document.png',
          fit: BoxFit.contain,
        );
    }
  }

  @override
  void initState() {
    super.initState();
    controller = ScrollController()..addListener(() => scrollCheck());
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  void scrollCheck() {
    if (controller.position.maxScrollExtent == controller.offset) {
      Provider.of<FileProvider>(context, listen: false).getMoreFiles();
    }
  }

  void onRepositoryTap(FileItem file) async {
    if (file.extension == null)
      Provider.of<FileProvider>(context, listen: false)
          .getFiles(folderidfk: file.repoid)
          .then((value) {
        controller.jumpTo(controller.position.minScrollExtent);
      });
    else {
      await launch(file.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    var files = Provider.of<FileProvider>(context).fileList;
    if (files.length == 0) {
      return Center(heightFactor: 15, child: Text('Nessun Elemento trovato', style: TextStyle(color: Colors.grey, fontSize: 18),));
    } else {
      if (widget.listView) {
        if (!widget.stats)
          return ListView.builder(
              padding: EdgeInsets.zero,
              physics: AlwaysScrollableScrollPhysics(),
              controller: controller,
              itemCount: files.length + 1,
              itemBuilder: (ctx, index) {
                if (index == files.length)
                  return Container(
                    height: 60,
                  );
                else
                  return InkWell(
                      onTap: () {
                        onRepositoryTap(files[index]);
                      },
                      child: ListStatsItem(
                          file: files[index],
                          image: pickIconFile(files[index].extension)));
              });
        else
          return ListView.builder(
              padding: EdgeInsets.zero,
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: widget.statsFileList.length,
              itemBuilder: (ctx, index) {
                return ListItem(
                    file: widget.statsFileList[index],
                    image: pickIconFile(widget.statsFileList[index].extension));
              });
      } else
        return GridView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            controller: controller,
            padding: EdgeInsets.all(25),
            itemCount: files.length,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200, mainAxisSpacing: 15),
            itemBuilder: (ctx, index) {
              return GestureDetector(
                onTap: () => onRepositoryTap(files[index]),
                child: GridItem(
                  file: files[index],
                  image: pickIconFile(files[index].extension),
                ),
              );
            });
    }
  }
}
