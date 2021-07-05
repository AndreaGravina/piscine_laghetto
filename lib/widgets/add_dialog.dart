import 'package:flutter/material.dart';
import 'package:piscine_laghetto/screens/new_repository_screen.dart';
import '../providers/file_provider.dart';

class AddDialog extends StatelessWidget {
 

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
                      Navigator.of(context).pushReplacementNamed(NewRepositoryScreen.routeName, arguments: {'type': FileItem.TYPE_FOLDER});
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_outline_outlined,
                          color: Colors.white,
                          size: 45,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Crea cartella',
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
                      primary: const Color(0xFFebebeb),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero)),
                  onPressed: () {
                      Navigator.of(context).pushReplacementNamed(NewRepositoryScreen.routeName, arguments: {'type': FileItem.TYPE_FILE});
                    },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.file_upload_outlined,
                        color: Colors.black,
                        size: 45,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Carica file',
                        style: TextStyle(color: Colors.black, fontSize: 18),
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
