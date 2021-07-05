import 'package:flutter/material.dart';
import 'package:piscine_laghetto/providers/users_provider.dart';
import 'package:piscine_laghetto/widgets/user_info_item.dart';

class UserInfoView extends StatelessWidget {
  const UserInfoView({required this.user, Key? key}) : super(key: key);

  final UserClass user;

  @override
  Widget build(BuildContext context) {
    bool isAdmin = user.roleidfk == UserClass.ROLE_ADMIN;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        UserInfoItem(
          title: 'Nome',
          data: user.name,
        ),
        Divider(
          height: 0,
        ),
        UserInfoItem(
          title: 'Cognome',
          data: user.surname,
        ),
        Divider(
          height: 0,
        ),
        UserInfoItem(
          title: 'E-Mail',
          data: user.email,
        ),
        Divider(
          height: 0,
        ),
        UserInfoItem(
          title: 'Username',
          data: user.username,
        ),
        Divider(
          height: 0,
        ),
        if (!isAdmin)
          UserInfoItem(
            title: 'Gruppi',
            data: user.groups,
          ),
        if (!isAdmin)
          Divider(
            height: 0,
          ),
        if (!isAdmin)
          UserInfoItem(
              title: 'Azienda',
              data: user.businessName != null ? user.businessName : ''),
        if (!isAdmin)
          Divider(
            height: 0,
          ),
        if (!isAdmin)
          UserInfoItem(
              title: 'Partita Iva',
              data: user.vatNumber != null ? user.vatNumber : ''),
        if (!isAdmin)
          Divider(
            height: 0,
          ),
        if (isAdmin)
          UserInfoItem(title: 'Data creazione', data: user.creationDate),
        if (isAdmin)
          Divider(
            height: 0,
          ),
        if (isAdmin)
          UserInfoItem(title: 'Status', data: user.status == 1 ? 'Attivo' : 'Non Attivo'),
        if (isAdmin)
          Divider(
            height: 0,
          ),
      ],
    );
  }
}
