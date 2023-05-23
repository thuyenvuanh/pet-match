import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_match/src/config/router/routes.dart';
import 'package:pet_match/src/presentation/blocs/profile_bloc/profile_bloc.dart';
import 'package:pet_match/src/utils/constant.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  late final ProfileBloc _bloc;
  late final StreamSubscription _listener;
  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<ProfileBloc>(context);
    _listener = _bloc.stream.listen((state) {
      if (state is ProfileLoggedOut) {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.profiles.name, (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: Resource.defaultBorderRadius,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircleAvatar(
                    foregroundImage: NetworkImage(
                        'https://firebasestorage.googleapis.com/v0/b/petmatch-6e802.appspot.com/o/48TBAFDw4zW6jKs5OBKD0wV5g7J3%2Fprofiles%2FIMG_0955.jpg?alt=media&token=6e3b92d8-04cd-47f1-af46-43c452dad5fb'),
                    child: SizedBox.expand(),
                  ),
                ),
                SizedBox(width: 20),
                Text('Mahiru'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: ListTile(
              leading: Icon(Icons.power_settings_new_rounded),
              title: const Text('Switch profile'),
              onTap: () {
                _bloc.add(LogoutOfProfile());
              },
            ),
          )
        ],
      ),
    );
  }
}
