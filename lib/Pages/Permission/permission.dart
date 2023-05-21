import 'package:appnewui/Pages/HomePageItems/Notifications/email_generator.dart';
import 'package:appnewui/constrants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'permissionCard.dart';
// import 'package:glbapp/Notifiaction_event/email_generator.dart';
import 'lib/Pages/HomePageItems/Notifications/email_generator.dart';

class Verify extends StatefulWidget {
  @override
  _VerifyState createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {
  late Query _ref;
  late var first;
  late var second;
  late final user;
  final String body =
      'Thank you for registering your event. Director/HOD office has viewed your request and granted Permission for so. ';

  DatabaseReference _database = FirebaseDatabase.instance.reference();
  DatabaseReference reference =
      FirebaseDatabase.instance.reference().child('/pending_events');
  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    assert(user != null);
    _ref = FirebaseDatabase.instance
        .reference()
        .child('/pending_events')
        .orderByChild('timestamp');
  }

  Widget _buildContactItem({required Map nextOrder}) {
    //Color typeColor = getTypeColor(contact['type']);

    return PermissionCard(
      AcceptPress: () async {
        nextOrder['verified'] = 1;

        Send(
          topic: nextOrder['topic'],
          date: nextOrder['date'],
          slot: nextOrder['date'],
          description: nextOrder['description'],
          body: body,
          email: nextOrder['emailId'],
        )
            .send()
            .then((value) => reference
                .child(nextOrder['key'])
                .remove()
                .whenComplete(() => Navigator.pop(context)))
            .then((value) => _database
                .child('/verified')
                .push()
                .set(nextOrder)
                .then((value) => print('hogya '))
                .catchError((onError) => print('nai hua ')))
            .then((value) => _database
                .child('time_slot_details')
                .push()
                .set({'date': nextOrder['date']}));
      },
      DeclinePress: () {
        nextOrder['declined'] = 1;
        _database
            .child('/declined')
            .push()
            .set(nextOrder)
            .then((value) => print('hogya '))
            .catchError((onError) => print('nai hua '));

        reference
            .child(nextOrder['key'])
            .remove()
            .whenComplete(() => Navigator.pop(context));
      },
      Title: nextOrder['topic'].toString(),
      Date: nextOrder['date'].toString(),
      Time: nextOrder['date'].toString(),
      Venue: nextOrder['venue'].toString(),
      uniqueId: nextOrder['uniqueId'].toString(),
      email: nextOrder['emailId'].toString(),
      Description: nextOrder['description'].toString(),
      name: nextOrder['name'],

      // color: secondaryYellow,
    );
  }

  _showDeleteDialog({required Map contact}) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Delete ${contact['name']}'),
            content: Text('Are you sure you want to delete?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel')),
              TextButton(
                  onPressed: () {
                    reference
                        .child(contact['key'])
                        .remove()
                        .whenComplete(() => Navigator.pop(context));
                  },
                  child: Text('Delete'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            centerTitle: true,
            backgroundColor: secondaryPurple,
            title: Text(
              'Permission',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(26),
            ))),
        body: Material(
          // height: double.infinity,
          child:
              //Column(
              // children: [
              //   Material(
              //     elevation: 5,
              //     borderRadius: BorderRadius.only(
              //         bottomLeft: Radius.circular(22),
              //         bottomRight: Radius.circular(22)),
              //     child: Container(
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           Text(
              //             "Permission Requests",
              //             style: TextStyle(
              //                 fontSize: 22, fontWeight: FontWeight.bold),
              //           ),
              //         ],
              //       ),
              //       height: size.height * .075,
              //       width: size.width,
              //       decoration: BoxDecoration(
              //           color: Color(0xffF1E6FF),
              //           borderRadius: BorderRadius.only(
              //               bottomLeft: Radius.circular(22),
              //               bottomRight: Radius.circular(22))),
              //     ),
              //   ),
              //   SizedBox(height: size.height * 0.01),
              FirebaseAnimatedList(
            query: _ref,
            itemBuilder: (BuildContext context, DataSnapshot snapshot,
                Animation<double> animation, int index) {
              Map contact = snapshot.value;
              contact['key'] = snapshot.key;

              return _buildContactItem(nextOrder: contact);
            },
          ),
          //],
          // ),
        ),
      ),
    );
  }
}
