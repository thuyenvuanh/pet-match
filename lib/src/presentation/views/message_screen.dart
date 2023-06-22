import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pet_match/src/config/router/routes.dart';
import 'package:pet_match/src/domain/models/profile_model.dart';
import 'package:pet_match/src/injection_container.dart';
import 'package:pet_match/src/presentation/blocs/profile_bloc/profile_bloc.dart';
import 'package:pet_match/src/presentation/views/chat_screen/chat_screen.dart';
import 'package:pet_match/src/presentation/views/user_screen.dart';
import 'package:pet_match/src/presentation/widgets/loading_indicator.dart';
import 'package:pet_match/src/utils/error/exceptions.dart';
import 'package:pet_match/src/utils/extensions.dart';
import 'package:pet_match/src/utils/rest_helper.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({Key? key}) : super(key: key);

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final firestore = FirebaseFirestore.instance;
  late final ProfileBloc _bloc;
  late final StreamSubscription _listener;
  Profile? currentProfile;
  late final RestClient restClient;
  static const String _getProfileById = '/pet-match/api/v1/profiles/';

  Future<Profile?> getProfileById(String profileId) async {
    try {
      final path = _getProfileById + profileId;
      final res = await restClient.get(path, headers: {});
      Profile profile = Profile.fromJson(json.decode(res));
      return profile;
    } on NetworkException {
      dev.log("Cannot get profile with id: $profileId");
      rethrow;
    } on RequestException catch (ex) {
      dev.log('Request get failed with status code ${ex.error.statusCode}');
      if (ex.error.statusCode == 404) {
        dev.log('Profile not found');
        return null;
      }
    } on Exception catch (ex) {
      dev.log("Unknown exception thrown: ${ex.runtimeType}");
      return null;
    }
    return null;
  }

  @override
  void initState() {
    restClient = sl<RestClient>();
    _bloc = BlocProvider.of<ProfileBloc>(context)..add(GetCurrentProfile());
    _listener = _bloc.stream.listen((state) {
      if (state is CurrentProfileState) {
        setState(() {
          currentProfile = state.profile;
        });
      }
      if (state is ProfileLoggedIn) {
        setState(() {
          currentProfile = state.activeProfile;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _listener.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 32,
              left: 40,
              right: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Nhắn tin",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // RoundedIconButton(
                  //   child:
                  //       SvgPicture.asset('assets/images/svgs/sort-two.svg'),
                  //   onTap: () {},
                  // ),
                  SizedBox(),
                ],
              ),
            ),
            Positioned.fill(
              top: 90,
              child: SizedBox(
                height: context.screenSize.height,
                width: context.screenSize.width,
                child: StreamBuilder(
                    stream: firestore.collection('Rooms').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const LoadingIndicator();
                      }
                      List<QueryDocumentSnapshot> data = !snapshot.hasData
                          ? []
                          : snapshot.data!.docs
                              .where((element) => element['users']
                                  .toString()
                                  .contains(currentProfile!.id!))
                              .toList();
                      return data.isEmpty
                          ? const Center(
                              child: Text("Bạn chưa nhắn tin với ai."),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                List users = data[index]['users'];
                                var friend = users.where((element) =>
                                    element != currentProfile!.id!);
                                var user = friend.isNotEmpty
                                    ? friend.first
                                    : users.where((element) =>
                                        element == currentProfile!.id!);
                                return FutureBuilder(
                                    future: getProfileById(user),
                                    builder: (context, snap) {
                                      final latestMessageStream = data[index]
                                          .reference
                                          .collection('messages')
                                          .orderBy('datetime', descending: true)
                                          .limit(1)
                                          .snapshots();
                                      return CustomListTile(
                                        title: Text(
                                          snap.data?.name ?? "",
                                        ),
                                        leading: CircleAvatar(
                                          foregroundImage: snap.hasData &&
                                                  snap.data!.avatar != null
                                              ? NetworkImage(snap.data!.avatar!)
                                              : null,
                                        ),
                                        isThreeLine: true,
                                        subTitle: StreamBuilder(
                                            stream: latestMessageStream,
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                return Text(
                                                    '${snapshot.data?.docs.first.get('sent_by') == currentProfile!.id ? "Bạn:" : ""} ${snapshot.data?.docs.first.get('message')}');
                                              }
                                              return const Text("Loading");
                                            }),
                                        trailing: StreamBuilder(
                                            stream: latestMessageStream,
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                return Text(DateFormat.Hm()
                                                    .format(snapshot
                                                        .data?.docs.first
                                                        .get('datetime')
                                                        .toDate()));
                                              }
                                              return const SizedBox();
                                            }),
                                        onTap: currentProfile == null &&
                                                !snap.hasData
                                            ? null
                                            : () {
                                                //!MOCK DATA
                                                ChatScreenArguments args =
                                                    ChatScreenArguments(
                                                  myId: currentProfile!.id!,
                                                  friendId: snap.data!.id!,
                                                  friendName: snap.data!.name!,
                                                );
                                                Navigator.pushNamed(
                                                  context,
                                                  AppRoutes.chat.name,
                                                  arguments: args,
                                                );
                                              },
                                      );
                                    });
                              },
                            );
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
