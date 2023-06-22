import 'package:flutter/material.dart';
import 'package:pet_match/src/presentation/views/chat_screen/styles.dart';

class ChatWidgets {
  static Widget card({title, time, subtitle, onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Card(
        elevation: 0,
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.all(5),
          leading: const Padding(
            padding: EdgeInsets.all(0.0),
            child: CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: Colors.white,
                )),
          ),
          title: Text(title),
          subtitle: subtitle != null ? Text(subtitle) : null,
          trailing: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(time),
          ),
        ),
      ),
    );
  }

  static Widget circleProfile({onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey,
              child: Icon(
                Icons.person,
                size: 40,
                color: Colors.white,
              ),
            ),
            SizedBox(
                width: 50,
                child: Center(
                    child: Text(
                  'John',
                  style:
                      TextStyle(height: 1.5, fontSize: 12, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                )))
          ],
        ),
      ),
    );
  }

  static Widget messagesCard(check, message, time, toggle, [clicked = false]) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(top: 10),
      child: GestureDetector(
        onTap: toggle,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (check) const Spacer(),
            // if (!check)
            //   const CircleAvatar(
            //     backgroundColor: Colors.grey,
            //     radius: 10,
            //     child: Icon(
            //       Icons.person,
            //       size: 13,
            //       color: Colors.white,
            //     ),
            //   ),
            Column(
              crossAxisAlignment:
                  check ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 250,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: Styles.messagesCardStyle(check),
                    child: Text(
                      '$message',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  key: const Key('time'),
                  duration: const Duration(milliseconds: 400),
                  child: clicked
                      ? Text(
                          time,
                          style: const TextStyle(color: Colors.black45),
                        )
                      : const SizedBox(
                          key: Key('time'),
                        ),
                )
              ],
            ),
            // if (check)
            //   const CircleAvatar(
            //     backgroundColor: Colors.grey,
            //     radius: 10,
            //     child: Icon(
            //       Icons.person,
            //       size: 13,
            //       color: Colors.white,
            //     ),
            //   ),
            if (!check) const Spacer(),
          ],
        ),
      ),
    );
  }

  static messageField({required Function(TextEditingController con) onSubmit}) {
    final con = TextEditingController();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: Styles.messageFieldCardStyle(),
      child: TextField(
        controller: con,
        decoration: Styles.messageTextFieldStyle(onSubmit: () {
          onSubmit(con);
        }),
      ),
    );
  }

  static drawer() {
    return Drawer(
      backgroundColor: Colors.indigo.shade400,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20),
          child: Theme(
            data: ThemeData.dark(),
            child: Column(
              children: const [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey,
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Divider(
                  color: Colors.white,
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile'),
                ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  static searchField({Function(String)? onChange}) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: Styles.messageFieldCardStyle(),
      child: TextField(
        onChanged: onChange,
        decoration: Styles.searchTextFieldStyle(),
      ),
    );
  }
}
