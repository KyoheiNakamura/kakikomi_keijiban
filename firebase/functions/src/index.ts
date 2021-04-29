import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

// export const sendPushNotification = messaging.sendPushNotification

// Start writing Firebase Functions
// https://firebase.google.com/docs/functions/typescript

// deviceごとに通知を受け取るか否かを設定できるようにしよう。
// ↑トークンの情報がいるっぽい: users/{userId}/topics/{topicId}の型を
// Map{key: token, value: topic}とかにすると良き？？
export const subscribeTokenToTopicWhenTokenIsCreated =
  functions.region("asia-northeast1")
      .firestore
      .document("users/{userId}/tokens/{tokenId}")
      .onCreate(async (snapshot, context) => {
        if (snapshot) {
          const token = snapshot.data().id;
          const topic = "newPost";
          await admin.messaging().subscribeToTopic(token, topic);
          const userDoc = await admin.firestore()
              .collection("users")
              .doc(context.params.userId)
              .get();
          const existingTopics = userDoc.data()?.topics;
          return admin.firestore()
              .collection("users")
              .doc(context.params.userId)
              .update({
                topics: existingTopics != null ?
                  existingTopics.includes(topic) ?
                    existingTopics :
                    existingTopics.concat([topic]) :
                  [topic],
              });
        } else {
          return null;
        }
      });

// 新規の投稿が作られたタイミングで、newPostトピックにサブスクリプションしてる
// tokenたちに通知を送ってる
export const sendPushNotificationToTopicWhenPostIsCreated =
  functions.region("asia-northeast1")
      .firestore
      .document("users/{userId}/posts/{postId}")
      .onCreate(async (snapshot, context) => {
        if (snapshot) {
          const topic = "newPost";
          // const title = "New Post!";
          const title = "新着の投稿があります";
          // const body = "新着の投稿があります😍";
          const body = snapshot.data().title;
          const page = "HomePostsPage";
          return admin.messaging().sendToTopic(topic, {
            notification: {
              title: title,
              body: body,
            },
            data: {
              page: page,
            },
          });
        } else {
          return null;
        }
      });

// deviceごとに通知を受け取るか否かを設定できるようにしよう。
// ↑トークンの情報がいるっぽい: users/{userId}/notifications/{notificationId}の型を
// Map{key: token, value: topic}とかにすると良き？？
export const sendPushNotificationWhenReplyIsCreated =
  functions.region("asia-northeast1")
      .firestore
      .document("users/{userId}/posts/{postId}/replies/{replyId}")
      .onCreate(async (snapshot, context) => {
        if (snapshot) {
          const userId = context.params.userId;
          const userDoc = await admin.firestore()
              .collection("users")
              .doc(userId)
              .get();
          const notification = "replyToMyPost";
          const isNotificationAllowed =
            userDoc.data()?.notifications.includes(notification);
          if (isNotificationAllowed) {
            // const title = "New Reply To Your Post!";
            const title = "投稿に返信がされました";
            // const body = "あなたの投稿に返信があります😘";
            const body = snapshot.data().body;
            const tokensSnapshot = await admin.firestore()
                .collection("users")
                .doc(userId)
                .collection("tokens")
                .get();
            const tokens = tokensSnapshot.docs.map((doc) => doc.id);
            const page = "MyPostsPage";
            return admin.messaging()
                .sendAll(tokens.map((token: string) => ({
                  token: token,
                  notification: {
                    title: title,
                    body: body,
                  },
                  data: {
                    page: page,
                  },
                })));
          } else {
            return null;
          }
        } else {
          return null;
        }
      });

export const sendPushNotificationWhenReplyToReplyIsCreated =
  functions.region("asia-northeast1")
      .firestore
      .document("users/{uId}/posts/{pId}/replies/{rId}/repliesToReply/{rtrId}")
      .onCreate(async (snapshot, context) => {
        if (snapshot) {
          const userId = context.params.uId;
          const postId = context.params.pId;
          const replyId = context.params.rId;
          const replyDoc = await admin.firestore()
              .collection("users")
              .doc(userId)
              .collection("posts")
              .doc(postId)
              .collection("replies")
              .doc(replyId)
              .get();
          const replierId = replyDoc.data()?.replierId;
          const userDoc = await admin.firestore()
              .collection("users")
              .doc(replierId)
              .get();
          // replyToReplyの場合でもreplyToMyPostと同じ通知設定にした。
          // 実際返信は返信だし。
          const notification = "replyToMyPost";
          const isNotificationAllowed =
            userDoc.data()?.notifications.includes(notification);
          if (isNotificationAllowed) {
            // const title = "New Reply To Your Reply!";
            const title = "返信に返信がされました";
            // const body = "あなたの返信に返信があります🤩";
            const body = snapshot.data().body;
            const tokensSnapshot = await admin.firestore()
                .collection("users")
                .doc(replierId)
                .collection("tokens")
                .get();
            const tokens = tokensSnapshot.docs.map((doc) => doc.id);
            const page = "MyRepliesPage";
            return admin.messaging()
                .sendAll(tokens.map((token: string) => ({
                  token: token,
                  notification: {
                    title: title,
                    body: body,
                  },
                  data: {
                    page: page,
                  },
                })));
          } else {
            return null;
          }
        } else {
          return null;
        }
      });

export const sendMailWhenContactIsSubmitted = functions
    .region("asia-northeast1")
    .https.onCall(async (data, context) => {
      const {email, category, content} = data;
      if (!email) {
        throw new functions.https.HttpsError(
            "invalid-argument",
            "email is required"
        );
      }

      type FormPayload = {
        email: string;
        category: string;
        content: string;
      };

      const adminMailBody = (params: FormPayload) => {
        return `以下内容でお問い合わせフォームよりお問い合わせを受けつけました。

メールアドレス:
   ${params.email}

お問い合わせのカテゴリー:
   ${params.category}

内容:
   ${params.content}
`;
      };

      const thanksMailBody = (params: FormPayload) => {
        return `お問い合わせありがとうございます。
以下内容でお問い合わせを受け付けました。

メールアドレス:
   ${params.email}

お問い合わせのカテゴリー:
   ${params.category}

内容:
   ${params.content}

後ほど担当者よりご連絡を差し上げます。
よろしくお願いいたします。
`;
      };

      const adminMailData = {
        to: functions.config().mail.admin_address,
        message: {
          subject: "kakikomi-keijibanへのお問い合わせ",
          text: adminMailBody({email, category, content}),
        },
        userId: context.auth?.uid,
      };

      const thanksMailData = {
        to: email,
        message: {
          subject: "kakikomi-keijibanへのお問い合わせありがとうございます",
          text: thanksMailBody({email, category, content}),
        },
        userId: context.auth?.uid,
      };

      await admin.firestore().collection("mail").add(adminMailData);
      return admin.firestore().collection("mail").add(thanksMailData);
    });

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
