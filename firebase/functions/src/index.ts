import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
// import * as messaging from "./messaging";

admin.initializeApp();

// export const sendPushNotification = messaging.sendPushNotification

// Start writing Firebase Functions
// https://firebase.google.com/docs/functions/typescript


// export const sendPushNotification =
//   async (userId: string, title: string, body: string) => {
//     const db = admin.firestore();
//     const confidentialSnapshot = await db.collection("users").doc(userId)
//       .collection("confidential").doc(userId).get();
//     const tokens = confidentialSnapshot.data()?.tokens;

//     const ms = admin.messaging();
//     return ms.sendAll(tokens.map((token: string) => ({
//       token: token,
//       notification: {
//         title: title,
//         body: body,
//       },
//     })));
//   };

// export const subscribeTokenToTopic =
//   async (token: string | string[], topic: string) => {
//     const ms = admin.messaging();
//     await ms.subscribeToTopic(token, topic);
//   };

// export const sendPushNotificationToTopic =
//   async (topic: string, title: string, body: string) => {
//     const ms = admin.messaging();
//     await ms.sendToTopic(topic, {
//       notification: {
//         title: title,
//         body: body,
//       },
//     });
//   };

// export const subscribeTokenToTopicWhenTokenIsCreated =
//   functions.region("asia-northeast1")
//       .firestore
//       .document("users/{userId}/confidential/{confiedntialId}")
//       .onCreate((snapshot, context) => {
//         if (snapshot) {
//           const tokens = snapshot.data().tokens;
//           const topic = "newPost";
//           return subscribeTokenToTopic(tokens, topic);
//         } else {
//           return null;
//         }
//       });

export const subscribeTokenToTopicWhenTokenIsCreated =
  functions.region("asia-northeast1")
      .firestore
      .document("users/{userId}/confidential/{confiedntialId}")
      .onCreate((snapshot, context) => {
        if (snapshot) {
          const tokens = snapshot.data().tokens;
          const topic = "newPost";
          return admin.messaging().subscribeToTopic(tokens, topic);
        } else {
          return null;
        }
      });

// export const sendPushNotificationToTopicWhenPostIsCreated =
//   functions.region("asia-northeast1")
//       .firestore
//       .document("users/{userId}/posts/{postId}")
//       .onCreate(async (snapshot, context) => {
//         if (snapshot) {
//           const topic = "newPost";
//           const title = "New Post";
//           const body = "新着の投稿があります。";
//           return sendPushNotificationToTopic(topic, title, body);
//         } else {
//           return null;
//         }
//       });

export const sendPushNotificationToTopicWhenPostIsCreated =
  functions.region("asia-northeast1")
      .firestore
      .document("users/{userId}/posts/{postId}")
      .onCreate(async (snapshot, context) => {
        if (snapshot) {
          const topic = "newPost";
          const title = "New Post";
          const body = "新着の投稿があります。";
          return admin.messaging().sendToTopic(topic, {
            notification: {
              title: title,
              body: body,
            },
          });
        } else {
          return null;
        }
      });
