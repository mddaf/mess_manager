const { onRequest } = require("firebase-functions/v2/https");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const express = require("express");
const cors = require("cors");

const nodemailer = require("nodemailer");

admin.initializeApp();
const db = admin.firestore();

const app = express();
app.use(cors({ origin: true }));
app.use(express.json());

// Express Middleware: Auth verification
async function authenticateToken(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({ error: "Unauthorized: Missing Bearer token" });
  }

  const token = authHeader.split("Bearer ")[1];
  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    req.user = decodedToken;
    next();
  } catch (error) {
    return res.status(403).json({ error: "Forbidden: Invalid token" });
  }
}

// REST Endpoint: POST /api/settle
app.post("/settle", authenticateToken, async (req, res) => {
  const { messId, month } = req.body;
  if (!messId || !month) {
    return res.status(400).json({ error: "Missing messId or month" });
  }

  try {
    const result = await db.runTransaction(async (transaction) => {
      const start = `${month}-01`;
      const end = `${month}-31`;

      // 1. Groceries sum
      const grocerySnap = await db
        .collection("messes")
        .doc(messId)
        .collection("groceryEntries")
        .where("date", ">=", start)
        .where("date", "<=", end)
        .get();

      let totalGroceryCost = 0.0;
      grocerySnap.forEach((doc) => {
        totalGroceryCost += Number(doc.data().amount || 0);
      });

      // 2. Meals sum per member
      const mealSnap = await db
        .collection("messes")
        .doc(messId)
        .collection("mealEntries")
        .where("date", ">=", start)
        .where("date", "<=", end)
        .get();

      const memberMeals = {};
      let totalMeals = 0.0;

      mealSnap.forEach((doc) => {
        const data = doc.data();
        const mId = data.memberId;
        finalDayMeals = Number(data.breakfast || 0) + Number(data.lunch || 0) + Number(data.dinner || 0);
        memberMeals[mId] = (memberMeals[mId] || 0) + finalDayMeals;
        totalMeals += finalDayMeals;
      });

      const mealRate = totalMeals > 0 ? totalGroceryCost / totalMeals : 0.0;

      // 3. Deposits sum per member
      const depositSnap = await db
        .collection("messes")
        .doc(messId)
        .collection("deposits")
        .where("date", ">=", start)
        .where("date", "<=", end)
        .get();

      const memberDeposits = {};
      depositSnap.forEach((doc) => {
        const data = doc.data();
        const mId = data.memberId;
        memberDeposits[mId] = (memberDeposits[mId] || 0) + Number(data.amount || 0);
      });

      // 4. Calculate member balances
      const membersSnap = await db
        .collection("messes")
        .doc(messId)
        .collection("members")
        .get();

      const memberBalances = [];
      membersSnap.forEach((doc) => {
        const mId = doc.id;
        const mName = doc.data().name || "Member";
        const mealsCount = memberMeals[mId] || 0.0;
        const cost = mealsCount * mealRate;
        const deposit = memberDeposits[mId] || Number(doc.data().totalDeposit || 0);
        const balance = deposit - cost;

        memberBalances.push({
          memberId: mId,
          memberName: mName,
          totalMeals: mealsCount,
          totalCost: cost,
          totalDeposit: deposit,
          balance: balance,
        });
      });

      const settlement = {
        id: month,
        month: month,
        totalGroceryCost: totalGroceryCost,
        totalMeals: totalMeals,
        mealRate: mealRate,
        memberBalances: memberBalances,
        status: "pending",
        calculatedAt: admin.firestore.Timestamp.now(),
      };

      const settlementRef = db
        .collection("messes")
        .doc(messId)
        .collection("settlements")
        .doc(month);

      transaction.set(settlementRef, settlement);
      return settlement;
    });

    res.status(200).json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// REST Endpoint: GET /api/meal-rate/:messId/:month
app.get("/meal-rate/:messId/:month", authenticateToken, async (req, res) => {
  const { messId, month } = req.params;
  const start = `${month}-01`;
  const end = `${month}-31`;

  try {
    const grocerySnap = await db
      .collection("messes")
      .doc(messId)
      .collection("groceryEntries")
      .where("date", ">=", start)
      .where("date", "<=", end)
      .get();

    let totalGroceryCost = 0.0;
    grocerySnap.forEach((doc) => {
      totalGroceryCost += Number(doc.data().amount || 0);
    });

    const mealSnap = await db
      .collection("messes")
      .doc(messId)
      .collection("mealEntries")
      .where("date", ">=", start)
      .where("date", "<=", end)
      .get();

    let totalMeals = 0.0;
    mealSnap.forEach((doc) => {
      const data = doc.data();
      totalMeals += Number(data.breakfast || 0) + Number(data.lunch || 0) + Number(data.dinner || 0);
    });

    const mealRate = totalMeals > 0 ? totalGroceryCost / totalMeals : 0.0;
    res.status(200).json({ messId, month, totalGroceryCost, totalMeals, mealRate });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// REST Endpoint: GET /api/report/:messId/:month
app.get("/report/:messId/:month", authenticateToken, async (req, res) => {
  const { messId, month } = req.params;
  try {
    const doc = await db
      .collection("messes")
      .doc(messId)
      .collection("settlements")
      .doc(month)
      .get();

    if (!doc.exists) {
      return res.status(404).json({ error: "Report not found" });
    }
    res.status(200).json(doc.data());
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post("/clearAllData", async (req, res) => {
  try {
    // Delete all Auth Users
    let pageToken;
    let totalAuthDeleted = 0;
    do {
      const listUsersResult = await admin.auth().listUsers(1000, pageToken);
      const uids = listUsersResult.users.map((u) => u.uid);
      if (uids.length > 0) {
        const deleteRes = await admin.auth().deleteUsers(uids);
        totalAuthDeleted += deleteRes.successCount;
      }
      pageToken = listUsersResult.pageToken;
    } while (pageToken);

    // Delete Firestore collections
    const collections = ["messes", "users", "mealEntries", "groceryEntries", "settlements", "deposits"];
    for (const col of collections) {
      const snap = await db.collection(col).get();
      const batch = db.batch();
      snap.docs.forEach((doc) => batch.delete(doc.ref));
      await batch.commit();
    }

    res.status(200).json({
      message: `Successfully deleted ${totalAuthDeleted} Auth users and cleared all Firestore collections.`,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// REST Endpoint: POST /api/send-invite-email
app.post("/send-invite-email", authenticateToken, async (req, res) => {
  const { targetEmail, messName, inviteCode, inviteLink, senderName } = req.body;
  if (!targetEmail || !inviteCode || !inviteLink) {
    return res.status(400).json({ error: "Missing required fields" });
  }

  try {
    // Configure Nodemailer transporter (supports SMTP env vars or fallback)
    const transporter = nodemailer.createTransport({
      host: process.env.SMTP_HOST || "smtp.gmail.com",
      port: Number(process.env.SMTP_PORT) || 587,
      secure: false,
      auth: {
        user: process.env.SMTP_USER || "messmanager.app@gmail.com",
        pass: process.env.SMTP_PASS || "",
      },
    });

    const mailOptions = {
      from: `"Mess Manager App" <${process.env.SMTP_USER || "noreply@meal-manager-844f5.firebaseapp.com"}>`,
      to: targetEmail,
      subject: `🎉 Invite to join ${messName || "Mess"} on Mess Manager`,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 540px; margin: auto; padding: 24px; border: 1px solid #e0e0e0; border-radius: 12px;">
          <h2 style="color: #FF5722; text-align: center;">Mess Manager Invite</h2>
          <p>Hi there!</p>
          <p><strong>${senderName || "A mess member"}</strong> has invited you to join <strong>${messName || "their mess"}</strong> on Mess Manager.</p>
          <div style="background-color: #FFF3E0; padding: 16px; border-radius: 8px; text-align: center; margin: 20px 0;">
            <p style="margin: 0; font-size: 14px; color: #E65100;">Your Invite Code:</p>
            <h1 style="margin: 4px 0; letter-spacing: 4px; color: #D84315;">${inviteCode}</h1>
            <p style="margin: 0; font-size: 12px; color: #EF6C00;">(Bound to ${targetEmail})</p>
          </div>
          <p style="text-align: center; margin: 24px 0;">
            <a href="${inviteLink}" style="background-color: #FF5722; color: white; text-decoration: none; padding: 14px 28px; border-radius: 8px; font-weight: bold; display: inline-block;">Click Here to Join Mess</a>
          </p>
          <p style="font-size: 12px; color: #757575; text-align: center;">If you didn't expect this invite, you can safely ignore this email.</p>
        </div>
      `,
    };

    if (process.env.SMTP_PASS) {
      await transporter.sendMail(mailOptions);
    }
    
    res.status(200).json({ success: true, message: "Invite recorded and email processed." });
  } catch (error) {
    // Return success response so app flow isn't interrupted even if SMTP fails
    res.status(200).json({ success: false, warning: error.message });
  }
});

exports.api = onRequest({ cors: true }, app);

// Daily Cron: Scheduled meal cutoff push reminders
exports.scheduledReminder = onSchedule("0 21 * * *", async (event) => {
  const tomorrow = new Date();
  tomorrow.setDate(tomorrow.getDate() + 1);
  const dateStr = tomorrow.toISOString().split("T")[0];

  const usersSnap = await db.collection("users").get();
  const tokens = [];

  usersSnap.forEach((doc) => {
    const data = doc.data();
    if (data.fcmTokens && data.fcmTokens.length > 0) {
      tokens.push(...data.fcmTokens);
    }
  });

  if (tokens.length > 0) {
    await admin.messaging().sendEachForMulticast({
      tokens: tokens,
      notification: {
        title: "Mess Manager ⏰",
        body: `Don't forget to mark tomorrow's (${dateStr}) meals before 10 PM!`,
      },
    });
  }
});
