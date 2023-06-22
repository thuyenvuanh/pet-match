import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_match/src/presentation/views/chat_screen/styles.dart';
import 'package:pet_match/src/presentation/views/chat_screen/widgets.dart';
import 'package:pet_match/src/presentation/widgets/loading_indicator.dart';
import 'package:pet_match/src/presentation/widgets/rounded_back_button.dart';
import 'package:pet_match/src/utils/constant.dart';

class ChatScreenArguments {
  final String myId;
  final String friendId;
  final String friendName;
  final String? initialMessage;

  ChatScreenArguments({
    required this.myId,
    required this.friendId,
    required this.friendName,
    this.initialMessage,
  });
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.args});

  final ChatScreenArguments args;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _firestore = FirebaseFirestore.instance;

  var roomId;
  var clickedId;

  void toggle(id) {
    setState(() {
      if (clickedId == id) clickedId = null;
      clickedId = id;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.args.initialMessage != null) {
      Map<String, dynamic> data = {
        "message": widget.args.initialMessage!.trim(),
        "sent_by": widget.args.myId,
        "datetime": DateTime.now(),
      };
      final roomRef = _firestore.collection('Rooms');
      if (roomId != null) {
        roomRef.doc(roomId).collection('messages').add(data);
      } else {
        roomRef.add({
          'users': [widget.args.myId, widget.args.friendId],
        }).then((value) async {
          value.collection('messages').add(data);
        });
        setState(() {
          roomId = roomRef.id;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Resource.lightBackground,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              bottom: 90,
              top: 56,
              child: StreamBuilder(
                stream: _firestore.collection('Rooms').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.docs.isNotEmpty) {
                      List<QueryDocumentSnapshot> allData = snapshot.data!.docs
                          .where((element) =>
                              element['users'].contains(widget.args.friendId) &&
                              element['users'].contains(widget.args.myId))
                          .toList();
                      QueryDocumentSnapshot? data =
                          allData.isNotEmpty ? allData.first : null;
                      if (data != null) {
                        roomId = data.id;
                      }
                      return data == null
                          ? const SizedBox()
                          : StreamBuilder(
                              stream: data.reference
                                  .collection('messages')
                                  .orderBy('datetime', descending: true)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                return !snapshot.hasData
                                    ? const SizedBox()
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: snapshot.data!.docs.length,
                                        reverse: true,
                                        itemBuilder: (context, i) {
                                          return ChatWidgets.messagesCard(
                                            snapshot.data!.docs[i]['sent_by'] !=
                                                widget.args.friendId,
                                            snapshot.data!.docs[i]['message'],
                                            DateFormat.Hm().format(
                                              snapshot.data!.docs[i]['datetime']
                                                  .toDate(),
                                            ),
                                            () => toggle(
                                                snapshot.data!.docs[i].id),
                                            snapshot.data!.docs[i].id ==
                                                    clickedId ||
                                                (i == 0 && clickedId == null),
                                          );
                                        },
                                      );
                              });
                    } else {
                      return Center(
                        child: Text(
                          "Hai bạn chưa nhắn tin với nhau.",
                          style: Styles.h1(),
                        ),
                      );
                    }
                  } else {
                    return const LoadingIndicator();
                  }
                },
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Resource.lightBackground,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    BackButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Text(
                      widget.args.friendName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.white,
                child: ChatWidgets.messageField(onSubmit: (controller) {
                  Map<String, dynamic> data = {
                    "message": controller.text.trim(),
                    "sent_by": widget.args.myId,
                    "datetime": DateTime.now(),
                  };
                  final roomRef = _firestore.collection('Rooms');
                  if (roomId != null) {
                    roomRef.doc(roomId).collection('messages').add(data);
                  } else {
                    roomRef.add({
                      'users': [widget.args.myId, widget.args.friendId],
                    }).then((value) async {
                      value.collection('messages').add(data);
                    });
                  }
                  toggle(null);
                  controller.clear();
                }),
              ),
            )
          ],
        ),
      ),
    );
  }
}
