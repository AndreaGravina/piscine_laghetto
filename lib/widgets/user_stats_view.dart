import 'package:flutter/material.dart';
import 'package:piscine_laghetto/providers/file_provider.dart';
import 'package:piscine_laghetto/providers/users_provider.dart';
import 'package:piscine_laghetto/widgets/file_view.dart';
import 'package:piscine_laghetto/widgets/user_stats_item.dart';

class UserStatsView extends StatelessWidget {
  const UserStatsView({required this.user, required this.fileList, Key? key}) : super(key: key);

  final UserClass user;
  final List<FileItem> fileList;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Flexible(
                flex: 4,
                fit: FlexFit.tight,
                child: UserStatsItem(
                    title: 'N. accessi', data: user.countLogin.toString()),
              ),
              Flexible(
                flex: 6,
                fit: FlexFit.tight,
                child: UserStatsItem(
                    title: 'Data ultimo accesso', data: user.lastAccess.toString()),
              ),
            ],
          ),
        ),
        Divider(
          height: 0,
        ),
        Container(
          height: 65,
          child: Row(
            children: [
              Flexible(fit: FlexFit.tight, flex: 1, child: Container()),
              Flexible(
                  fit: FlexFit.tight,
                  flex: 9,
                  child: Container(child: Text('File Scaricati'))),
              Flexible(
                  fit: FlexFit.tight,
                  flex: 5,
                  child: Container(child: Text('Data'))),
              Flexible(
                  fit: FlexFit.tight,
                  flex: 3,
                  child: Container(child: Text('Peso'))),
            ],
          ),
        ),
        Divider(
          height: 0,
        ),
        Expanded(
            child: FileView(
          listView: true,
          stats: true,
          statsFileList: fileList,
        ))
      ],
    );
  }
}
