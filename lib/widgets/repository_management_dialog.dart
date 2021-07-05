import 'package:flutter/material.dart';
import 'package:piscine_laghetto/screens/edit_repository_screen.dart';
import '../providers/file_provider.dart';
import './delete_dialog.dart';

class FolderManagementDialog extends StatelessWidget {
  FolderManagementDialog({required this.repository});

  final FileItem repository;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
      contentPadding: EdgeInsets.all(0),
      content: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: Container(
          height: 140,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: const Color(0xFF0375fe),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero)),
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(
                      EditRepositoryScreen.routeName,
                      arguments: {
                        'repository': repository,
                      },
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.mode_edit_outlined,
                        color: Colors.white,
                        size: 45,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Modifica',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      )
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    showDialog(
                        context: context,
                        builder: (context) => DeleteDialog(
                              id: repository.repoid,
                              type: 'Repository',
                            ));
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 45,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Elimina',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
