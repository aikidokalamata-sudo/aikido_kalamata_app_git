/**
 * Cloud Functions for Firebase για την εφαρμογή Aikido Kalamata.
 * Υβριδική προσέγγιση για ειδοποιήσεις:
 * 1. Χρησιμοποιεί Topic ('admin_inbox') για ειδοποιήσεις προς τους Admins.
 * 2. Χρησιμοποιεί FCM Token για στοχευμένες ειδοποιήσεις προς τα Μέλη.
 *
 * Για deploy: `firebase deploy --only functions`
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * Function #1: Ειδοποίηση στον Admin μέσω Topic.
 * Trigger: Δημιουργία νέου εγγράφου στη συλλογή 'inbox'.
 */
exports.notifyAdminViaTopic = functions
  .region("europe-west1")
  .firestore.document("inbox/{messageId}")
  .onCreate(async (snap, context) => {
    const messageData = snap.data();
    const senderEmail = messageData.senderEmail || "Ένας χρήστης";

    // Το topic στο οποίο έχουν κάνει subscribe οι admins από την εφαρμογή.
    const topic = "admin_inbox";

    const payload = {
      notification: {
        title: "📬 Νέο Μήνυμα στα Εισερχόμενα",
        body: `Έχετε ένα νέο μήνυμα από: ${senderEmail}`,
        sound: "default",
        badge: "1",
      },
    };

    console.log(`Sending notification to topic: ${topic}`);
    try {
      await admin.messaging().sendToTopic(topic, payload);
      console.log(`Successfully sent notification to topic: ${topic}`);
    } catch (error) {
      console.error(`Error sending notification to topic ${topic}:`, error);
    }
    return null;
  });

/**
 * Function #2: Ειδοποίηση σε Μέλος μέσω Token.
 * Trigger: Δημιουργία εγγράφου στην υπο-συλλογή 'messages' ενός μέλους.
 */
exports.notifyMemberViaToken = functions
  .region("europe-west1")
  .firestore.document("members/{memberId}/messages/{messageId}")
  .onCreate(async (snap, context) => {
    const memberId = context.params.memberId;
    console.log(`New message for member ${memberId}. Fetching member token.`);

    // 1. Βρίσκουμε το έγγραφο του μέλους για να πάρουμε το FCM token του.
    const memberDoc = await admin.firestore().collection("members").doc(memberId).get();

    if (!memberDoc.exists || !memberDoc.data().fcmToken) {
      console.log(`Member ${memberId} not found or has no FCM token.`);
      return null;
    }
    const token = memberDoc.data().fcmToken;

    const payload = {
      notification: {
        title: "✉️ Νέο Μήνυμα από το Dojo",
        body: "Έχετε ένα νέο μήνυμα στο προφίλ σας!",
        sound: "default",
        badge: "1",
      },
    };

    // 2. Στέλνουμε την ειδοποίηση στη συγκεκριμένη συσκευή του μέλους.
    console.log(`Sending notification to member ${memberId}.`);
    try {
      await admin.messaging().sendToDevice(token, payload);
      console.log(`Successfully sent notification to member ${memberId}.`);
    } catch (error) {
      console.error(`Error sending notification to member ${memberId}:`, error);
    }
    return null;
  });