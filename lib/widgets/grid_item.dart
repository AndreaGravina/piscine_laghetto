import 'package:flutter/material.dart';
import '../providers/file_provider.dart';
import 'repository_management_dialog.dart';
import '../global_class.dart' as Globals;

class GridItem extends StatelessWidget {
  const GridItem({required this.file, required this.image, Key? key})
      : super(key: key);

  final FileItem file;
  final Image image;

  @override
  Widget build(BuildContext context) {
    var isAdmin = Globals.isAdmin;

    return Container(
      child: Column(
        children: [
          Container(width: 100, height: 80, child: image),
          Container(
            margin: EdgeInsets.only(top: isAdmin ? 5 : 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if(isAdmin)
                Flexible(
                  fit: FlexFit.tight,
                  flex: 1,
                  child: Container(),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  flex: 9,
                  child: Text(file.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .headline4!
                          .apply(color: Colors.black)),
                ),
                if(isAdmin)
                Flexible(
                  fit: FlexFit.tight,
                  flex: 2,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    splashRadius: 18,
                    icon: Icon(Icons.more_vert),
                    iconSize: 18,
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) => FolderManagementDialog(repository: file,));
                    },
                  ),
                ),
                if(isAdmin)
                Flexible(
                  fit: FlexFit.tight,
                  flex: 1,
                  child: Container(),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
