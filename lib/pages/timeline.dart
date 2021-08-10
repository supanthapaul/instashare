import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instashare/widgets/header.dart';
import 'package:instashare/widgets/progress.dart';

final usersRef = FirebaseFirestore.instance.collection("users");

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  void initState() {
    super.initState();
  }

  createUser() async {
    await usersRef.add({
      "username": "Jeff",
      "postsCount": 0,
      "isAdmin": false,
    });
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          return Container(
            child: ListView(
              children: snapshot.data.docs
                  .map((doc) => Text(doc['username']))
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}
