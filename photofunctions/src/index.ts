import * as functions from "firebase-functions/v1";
import * as admin from "firebase-admin";

admin.initializeApp();

// Hàm theo dõi khi có người follow mới (v1)
export const onNewFollower = functions.firestore
  .document("follows/{followId}")
  .onCreate(async (snapshot) => {
    const followData = snapshot.data();
    if (!followData) return;

    const followedId = followData.followedId as string;
    const followerId = followData.followerId as string;

    const userDoc = await admin.firestore()
      .collection("users")
      .doc(followedId)
      .get();
    if (!userDoc.exists) return;

    const fcmToken = userDoc.data()?.fcmToken as string;
    if (!fcmToken) {
      console.log("No FCM token for user:", followedId);
      return;
    }

    const followerDoc = await admin.firestore()
      .collection("users")
      .doc(followerId)
      .get();

    const followerName = followerDoc.exists ?
      followerDoc.data()?.name || "Someone" :
      "Someone";

    const message = {
      notification: {
        title: "New Follower",
        body: `${followerName} has followed you!`,
      },
      token: fcmToken,
    };

    try {
      await admin.messaging().send(message);
      console.log("Sent to", followedId);
    } catch (error) {
      console.error("Error sending notification:", error);
    }
  });

// Hàm theo dõi khi có bình luận mới trên bài đăng (v1)
export const onNewComment = functions.firestore
  .document("posts/{postId}/comments/{commentId}")
  .onCreate(async (snapshot, context) => {
    const commentData = snapshot.data();
    if (!commentData) return;

    const postId = context.params.postId;
    const commenterId = commentData.userId as string;

    const postDoc = await admin.firestore()
      .collection("posts")
      .doc(postId)
      .get();
    if (!postDoc.exists) return;

    const postOwnerId = postDoc.data()?.userId as string;
    if (!postOwnerId) return;

    const userDoc = await admin.firestore()
      .collection("users")
      .doc(postOwnerId)
      .get();
    if (!userDoc.exists) return;

    const fcmToken = userDoc.data()?.fcmToken as string;
    if (!fcmToken) {
      console.log("No FCM token for user:", postOwnerId);
      return;
    }

    const commenterDoc = await admin.firestore()
      .collection("users")
      .doc(commenterId)
      .get();

    const commenterName = commenterDoc.exists ?
      commenterDoc.data()?.name || "Someone" :
      "Someone";

    const message = {
      notification: {
        title: "New Comment",
        body: `${commenterName} commented on your post!`,
      },
      token: fcmToken,
    };

    try {
      await admin.messaging().send(message);
      console.log("Sent to", postOwnerId);
    } catch (error) {
      console.error("Error sending notification:", error);
    }
  });

