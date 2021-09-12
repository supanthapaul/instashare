import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instashare/models/user.dart';
import 'package:instashare/pages/home.dart';
import 'package:instashare/pages/search.dart';
import 'package:instashare/widgets/header.dart';
import 'package:instashare/widgets/post.dart';
import 'package:instashare/widgets/progress.dart';

final usersRef = FirebaseFirestore.instance.collection("users");

class Timeline extends StatefulWidget {
  final User currentUser;

  Timeline({this.currentUser});
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<Post> posts;
  List<String> followingList;

  @override
  void initState() {
    super.initState();
    getFollowing();
    getTimeline();
  }

  getTimeline() async {
    QuerySnapshot snapshot = await timelineRef
        .doc(widget.currentUser.id)
        .collection('timelinePosts')
        .orderBy('timestamp', descending: true)
        .get();

    List<Post> posts =
        snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    setState(() {
      this.posts = posts;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(currentUser.id)
        .collection('userFollowing')
        .get();

    setState(() {
      followingList = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  buildTimeline() {
    if (posts == null) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return buildUsersToFollow();
    } else {
      return ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return posts[index];
        },
      );
    }
  }

  buildUsersToFollow() {
    return StreamBuilder<QuerySnapshot>(
        stream: usersRef
            .orderBy('timestamp', descending: true)
            .limit(30)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<UserResult> userResults = [];
          snapshot.data.docs.forEach((doc) {
            User user = User.fromDocument(doc);

            final bool isAuthUser = currentUser.id == user.id;
            final bool isFollowingUser = followingList.contains(user.id);
            if (isAuthUser || isFollowingUser) return;

            userResults.add(UserResult(user));
          });
          return Container(
            color: Theme.of(context).accentColor.withOpacity(0.2),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_add,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        "Users To Follow",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 24,
                        ),
                      )
                    ],
                  ),
                ),
                Column(
                  children: userResults,
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: RefreshIndicator(
        child: buildTimeline(),
        onRefresh: () => getTimeline(),
      ),
    );
  }
}
