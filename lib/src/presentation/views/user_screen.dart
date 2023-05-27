import 'dart:async';
import 'dart:developer' as dev;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_match/src/config/router/routes.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:pet_match/src/presentation/blocs/profile_bloc/profile_bloc.dart';
import 'package:pet_match/src/presentation/widgets/loading_indicator.dart';
import 'package:pet_match/src/utils/constant.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  late final ProfileBloc _bloc;
  late final StreamSubscription _listener;
  Profile? profile;
  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<ProfileBloc>(context)..add(GetCurrentProfile());
    _listener = _bloc.stream.listen((state) {
      if (state is ProfileLoggedOut) {
        Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.profiles.name, (route) => false);
      }
      if (state is CurrentProfileState) {
        setState(() {
          profile = state.profile;
        });
      }
    });
  }

  @override
  void dispose() {
    _listener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Builder(builder: (context) {
          if (profile == null) {
            return const LoadingIndicator();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 32),
                child: Text("Hồ sơ",
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20)
                    .copyWith(top: 20),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                decoration: BoxDecoration(
                  color: Resource.primaryTintColor,
                  borderRadius: Resource.defaultBorderRadius,
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => dev.log('view detail profile'),
                      borderRadius: BorderRadius.circular(8),
                      splashColor: Resource.primaryTintColor,
                      overlayColor: MaterialStateColor.resolveWith(
                          (states) => Resource.primaryTintColor),
                      child: Ink(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: CircleAvatar(
                                child: Container(
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: profile!.avatar!,
                                    fit: BoxFit.cover,
                                    height: 60,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profile!.name!,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Resource.primaryTextColor,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    const Text(
                                      'Nhấn vào để xem',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Icon(Icons.chevron_right_outlined)
                          ],
                        ),
                      ),
                    ),
                    Divider(color: Colors.black.withOpacity(0.5), height: 30),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      splashColor: Resource.primaryTintColor,
                      overlayColor: MaterialStateColor.resolveWith(
                          (states) => Resource.primaryTintColor),
                      onTap: () => _bloc.add(LogoutOfProfile()),
                      child: Ink(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.power_settings_new_rounded),
                            SizedBox(width: 10),
                            Expanded(child: Text('Đổi hồ sơ')),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ListTile(
                    leading: const Icon(Icons.logout_rounded),
                    title: const Text('Đăng xuất'),
                    onTap: () {
                      BlocProvider.of<AuthBloc>(context).add(SignOutRequest());
                      dev.log('log out');
                    },
                    dense: false,
                  ),
                ],
              )
            ],
          );
        }),
      ),
    );
  }
}
