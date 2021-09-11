const functions = require("firebase-functions");
const admin = require('firebase-admin');
admin.initializeApp();
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
exports.onCreateFollower = functions.firestore
  .document("/followers/{userId}/userFollowers/{followerId}")
  .onCreate(async (snap, context) => {
    console.log("Follower created", snap.id);
    const userId = context.params.userId;
    const followerId = context.params.followerId;

    // get followed user's posts ref
    const followedUserPostsRef = admin
      .firestore()
      .collection('posts')
      .doc(userId)
      .collection('userPosts');

    // get following user's timeline ref
    const timelinePostsRef = admin
      .firestore()
      .collection('timeline')
      .doc(followerId)
      .collection('timelinePosts');
    
      // get followed user's posts
      const querySnapshot = await followedUserPostsRef.get();

      // add each user post to following user's timeline
      querySnapshot.docs.forEach(doc => {
        if(doc.exists) {
          const postId = doc.id;
          const postData = doc.data();
          timelinePostsRef.doc(postId).set(postData);
        }
      });
  });

exports.onDeleteFollower = functions.firestore
  .document("/followers/{userId}/userFollowers/{followerId}")
  .onDelete(async (snap, context) => {
    console.log("Follower removed", snap.id);
    const userId = context.params.userId;
    const followerId = context.params.followerId;

    // get following user's timeline ref where the posts are from the user that we just unfollowed
    const timelinePostsRef = admin
      .firestore()
      .collection('timeline')
      .doc(followerId)
      .collection('timelinePosts')
      .where("ownerId", "==", userId);
    
    const querySnapshot = await timelinePostsRef.get();
    // delete the posts of the unfollowed user from our timeline
    querySnapshot.docs.forEach(doc => {
      if(doc.exists) {
        doc.ref.delete();
      }
    });
  });

  // when a post is created, add post to timeline of each follower (of post owner)
exports.onCreatePost = functions.firestore
  .document("/posts/{userId}/userPosts/{postId}")
  .onCreate(async (snap, context) => {
    const createdPost = snap.data();
    const userId = context.params.userId;
    const postId = context.params.postId;

    // get all followers of user who made the post
    const userFollowersRef = admin.firestore()
      .collection('followers')
      .doc(userId)
      .collection('userFollowers');
    const querySnapshot = await userFollowersRef.get();

    // add new post to each follower's timeline
    querySnapshot.docs.forEach(doc => {
      const followerId = doc.id;

      admin.firestore()
        .collection('timeline')
        .doc(followerId)
        .collection('timelinePosts')
        .doc(postId)
        .set(createdPost);
    });
});

exports.onUpdatePost = functions.firestore
  .document("/posts/{userId}/userPosts/{postId}")
  .onUpdate(async (change, context) => {
    const updatedPost = change.after.data();
    const userId = context.params.userId;
    const postId = context.params.postId;

    // get all followers of user who made the post
    const userFollowersRef = admin.firestore()
      .collection('followers')
      .doc(userId)
      .collection('userFollowers');
    const querySnapshot = await userFollowersRef.get();

    // update post to each follower's timeline
    querySnapshot.docs.forEach(doc => {
      const followerId = doc.id;

      admin.firestore()
        .collection('timeline')
        .doc(followerId)
        .collection('timelinePosts')
        .doc(postId)
        .get().then(doc => {
          if(doc.exists) {
            doc.ref.update(updatedPost);
          }
        });
    });
  });

exports.onDeletePost = functions.firestore
  .document("/posts/{userId}/userPosts/{postId}")
  .onDelete(async (snap, context) => {

    const userId = context.params.userId;
    const postId = context.params.postId;

    // get all followers of user who made the post
    const userFollowersRef = admin.firestore()
      .collection('followers')
      .doc(userId)
      .collection('userFollowers');
    const querySnapshot = await userFollowersRef.get();

    // delete post to each follower's timeline
    querySnapshot.docs.forEach(doc => {
      const followerId = doc.id;

      admin.firestore()
        .collection('timeline')
        .doc(followerId)
        .collection('timelinePosts')
        .doc(postId)
        .get().then(doc => {
          if(doc.exists) {
            doc.ref.delete();
          }
        });
    });
  });