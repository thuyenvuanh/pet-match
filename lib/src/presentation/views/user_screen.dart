import 'dart:async';
import 'dart:developer' as dev;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet_match/main.dart';
import 'package:pet_match/src/config/router/routes.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/injection_container.dart';
import 'package:pet_match/src/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:pet_match/src/presentation/blocs/profile_bloc/profile_bloc.dart';
import 'package:pet_match/src/presentation/views/profile_detail/profile_detail.dart';
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
    _bloc = BlocProvider.of<ProfileBloc>(context);
    _listener = _bloc.stream.listen((state) {
      if (state is ProfileLoggedOut) {
        Navigator.pushNamed(context, AppRoutes.profiles.name)
            .then((dynamic value) {
          if (value[0] != null) {
            setState(() {
              profile = value[0] as Profile;
              _bloc.add(LoginToProfile(profile!));
            });
          }
        });
      }
      if (state is ProfileLoggedIn) {
        setState(() {
          profile = state.activeProfile;
        });
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
            return const LoadingIndicator(
                loadingText: 'Đang lấy dữ liệu người dùng. Vui lòng chờ...');
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 32, left: 40),
                child: Text(
                  "Hồ sơ",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20)
                    .copyWith(top: 20),
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: const Color(0xFF8cd2b6).withOpacity(0.3),
                  borderRadius: Resource.defaultBorderRadius,
                ),
                child: Column(
                  children: [
                    InkWell(
                      borderRadius: Resource.defaultBorderRadius,
                      onTap: () {
                        final args = ProfileDetailScreenArguments(
                          profile: profile!,
                          isMe: true,
                          isLiked: false,
                        );
                        Navigator.pushNamed(
                          context,
                          AppRoutes.profileDetails.name,
                          arguments: args,
                        );
                      },
                      splashColor: const Color(0xFF8cd2b6).withOpacity(0.3),
                      overlayColor: MaterialStateColor.resolveWith(
                          (states) => const Color(0xFF8cd2b6).withOpacity(0.3)),
                      child: Ink(
                        padding: const EdgeInsets.all(28),
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
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  CustomListTile(
                    leading: const Icon(Icons.workspace_premium_rounded),
                    title: const Text('Đăng kí gói'),
                    onTap: () {
                      Navigator.pushNamed(
                          context, AppRoutes.premiumRegister.name);
                    },
                  ),
                  Divider(color: Colors.black.withOpacity(0.1), height: 30),
                  CustomListTile(
                    leading: const Icon(Icons.swap_horizontal_circle_rounded),
                    title: const Text("Chuyển hồ sơ"),
                    onTap: () => _bloc.add(LogoutOfProfile()),
                  ),
                  CustomListTile(
                    leading: const Icon(
                      Icons.logout_rounded,
                      color: Colors.red,
                    ),
                    title: const Text(
                      'Đăng xuất',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      BlocProvider.of<AuthBloc>(context).add(SignOutRequest());
                      // MyInheritedWidget.of(context)
                      //     ?.authBloc
                      //     .add(SignOutRequest());
                    },
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

class CustomListTile extends StatelessWidget {
  const CustomListTile(
      {super.key,
      this.onTap,
      this.title,
      this.leading,
      this.isThreeLine = false,
      this.subTitle,
      this.trailing});

  final Function()? onTap;
  final Widget? title;
  final Widget? leading;
  final bool isThreeLine;
  final Widget? subTitle;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: Resource.defaultBorderRadius,
          splashColor: const Color(0x448BD2B6),
          overlayColor: MaterialStateColor.resolveWith(
            (states) => const Color(0x448BD2B6),
          ),
          onTap: onTap,
          child: ListTile(
            trailing: trailing,
            isThreeLine: isThreeLine,
            subtitle: subTitle,
            minLeadingWidth: 0,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            leading: leading,
            title: title,
          ),
        ),
      ),
    );
  }
}
