const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Initialize Firebase Admin SDK
admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

// ============================================================================
// CONSTANTS
// ============================================================================

// Density thresholds in people per square meter
const DENSITY_WARNING = 3.0;
const DENSITY_CRITICAL = 4.5;

// Role-to-topic mapping for FCM subscriptions
const ROLE_TOPICS = {
  fan: ["general_announcements"],
  organizer: ["organizer", "general_announcements"],
  security: ["security_alerts", "general_announcements"],
  emergency: ["emergency_alerts", "security_alerts", "general_announcements"],
};

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/**
 * Point-in-polygon test using the ray-casting algorithm.
 * Each boundary point is an object with { lat, lng }.
 * @param {number} lat - Latitude of the point to test.
 * @param {number} lng - Longitude of the point to test.
 * @param {Array<{lat: number, lng: number}>} polygon - Array of boundary vertices.
 * @returns {boolean} True if point is inside the polygon.
 */
function pointInPolygon(lat, lng, polygon) {
  let inside = false;
  const n = polygon.length;
  for (let i = 0, j = n - 1; i < n; j = i++) {
    const xi = polygon[i].lat;
    const yi = polygon[i].lng;
    const xj = polygon[j].lat;
    const yj = polygon[j].lng;

    const intersect =
      yi > lng !== yj > lng &&
      lat < ((xj - xi) * (lng - yi)) / (yj - yi) + xi;

    if (intersect) inside = !inside;
  }
  return inside;
}

/**
 * Calculate the approximate area of a polygon in square meters.
 * Uses the Shoelace formula with a rough lat/lng to meters conversion.
 * @param {Array<{lat: number, lng: number}>} polygon - Array of boundary vertices.
 * @returns {number} Approximate area in square meters.
 */
function polygonAreaSqMeters(polygon) {
  if (!polygon || polygon.length < 3) return 0;

  // Convert lat/lng degrees to approximate meters (at mid-latitude)
  const midLat = polygon.reduce((s, p) => s + p.lat, 0) / polygon.length;
  const latToM = 111320; // meters per degree latitude
  const lngToM = 111320 * Math.cos((midLat * Math.PI) / 180);

  let area = 0;
  const n = polygon.length;
  for (let i = 0; i < n; i++) {
    const j = (i + 1) % n;
    const xi = polygon[i].lat * latToM;
    const yi = polygon[i].lng * lngToM;
    const xj = polygon[j].lat * latToM;
    const yj = polygon[j].lng * lngToM;
    area += xi * yj - xj * yi;
  }
  return Math.abs(area) / 2;
}

/**
 * Determine density status string from people per square meter.
 * Aligns with the Flutter CrowdDensity model thresholds.
 * @param {number} density - People per square meter.
 * @returns {string} Status string: safe, moderate, high, or critical.
 */
function getStatusFromDensity(density) {
  if (density >= 4.6) return "critical";
  if (density >= 3.1) return "high";
  if (density >= 1.6) return "moderate";
  return "safe";
}

/**
 * Get a human-readable title for an incident type.
 * @param {string} type - The incident type key.
 * @param {string} severity - The incident severity.
 * @returns {string} Display title.
 */
function getIncidentTitle(type, severity) {
  const typeLabels = {
    medical: "Medical Emergency",
    security: "Security Incident",
    overcrowding: "Overcrowding Alert",
    facility: "Facility Issue",
    other: "Incident Report",
  };
  const label = typeLabels[type] || "Incident";
  const severityTag = severity === "critical" ? " - CRITICAL" : "";
  return `${label}${severityTag}`;
}

/**
 * Send an FCM notification to a single topic.
 * @param {string} topic - The FCM topic name.
 * @param {string} title - Notification title.
 * @param {string} body - Notification body.
 * @param {Object} data - Extra data payload.
 * @param {string} severity - Severity level for priority tuning.
 */
async function sendToTopic(topic, title, body, data = {}, severity = "info") {
  try {
    await messaging.send({
      topic: topic,
      notification: { title, body },
      data: {
        ...data,
        click_action: "FLUTTER_NOTIFICATION_CLICK",
      },
      android: {
        priority: severity === "critical" ? "high" : "normal",
        notification: {
          channelId: severity === "critical" ? "alerts_critical" : "alerts",
          sound: severity === "critical" ? "alarm" : "default",
        },
      },
      apns: {
        payload: {
          aps: {
            sound: severity === "critical" ? "alarm.wav" : "default",
            badge: 1,
          },
        },
      },
    });
    functions.logger.info(`FCM sent to topic '${topic}': ${title}`);
  } catch (error) {
    functions.logger.error(`FCM error for topic '${topic}':`, error);
  }
}

/**
 * Create in-app notification documents for users matching the given roles.
 * @param {string} title - Notification title.
 * @param {string} body - Notification body.
 * @param {string} type - Notification type (alert, incident, etc.).
 * @param {string} referenceId - ID of the related document.
 * @param {string[]} targetRoles - Array of role strings to notify.
 */
async function createNotificationDocuments(title, body, type, referenceId, targetRoles) {
  if (!targetRoles || targetRoles.length === 0) return;

  // Firestore 'in' queries support a maximum of 30 values
  const usersSnapshot = await db
    .collection("users")
    .where("role", "in", targetRoles.slice(0, 30))
    .get();

  if (usersSnapshot.empty) return;

  const batch = db.batch();
  usersSnapshot.forEach((userDoc) => {
    const notifRef = db.collection("notifications").doc();
    batch.set(notifRef, {
      userId: userDoc.id,
      title,
      body,
      type,
      referenceId,
      isRead: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });
  await batch.commit();
  functions.logger.info(`Created ${usersSnapshot.size} notification docs for roles [${targetRoles}]`);
}

/**
 * Delete documents in batches to avoid memory issues.
 * @param {FirebaseFirestore.Query} query - The Firestore query whose results will be deleted.
 * @param {number} batchSize - Number of documents per batch.
 * @returns {number} Total documents deleted.
 */
async function deleteQueryBatched(query, batchSize = 400) {
  let totalDeleted = 0;
  let snapshot = await query.limit(batchSize).get();

  while (!snapshot.empty) {
    const batch = db.batch();
    snapshot.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();
    totalDeleted += snapshot.size;
    snapshot = await query.limit(batchSize).get();
  }
  return totalDeleted;
}

// ============================================================================
// (a) onCrowdDensityWrite
// Firestore trigger on crowd_density/{docId} write.
// Checks if density exceeds thresholds and auto-creates alerts + FCM.
// ============================================================================
exports.onCrowdDensityWrite = functions.firestore
  .document("crowd_density/{docId}")
  .onWrite(async (change, context) => {
    const data = change.after.data();
    if (!data) return null; // document deleted

    const densityPerSqMeter = typeof data.densityPerSqMeter === "number"
      ? data.densityPerSqMeter
      : 0;
    const zoneName = data.zoneName || "Unknown Zone";
    const zoneId = data.zoneId || context.params.docId;
    const eventId = data.eventId || null;

    // Determine severity
    let severity = null;
    if (densityPerSqMeter >= DENSITY_CRITICAL) {
      severity = "critical";
    } else if (densityPerSqMeter >= DENSITY_WARNING) {
      severity = "warning";
    }

    if (!severity) return null; // density is below alert thresholds

    // Avoid duplicate alerts: check if an active alert already exists for this
    // zone within the last 30 minutes.
    const thirtyMinutesAgo = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() - 30 * 60 * 1000),
    );

    const existingQuery = db
      .collection("alerts")
      .where("zoneId", "==", zoneId)
      .where("type", "==", "congestion")
      .where("createdAt", ">=", thirtyMinutesAgo);

    const existing = await existingQuery.get();
    if (!existing.empty) {
      functions.logger.info(
        `Active congestion alert already exists for zone '${zoneName}', skipping.`,
      );
      return null;
    }

    // Build alert message
    const densityRounded = densityPerSqMeter.toFixed(1);
    const message =
      severity === "critical"
        ? `CRITICAL: ${zoneName} density is ${densityRounded} p/m2. Immediate crowd control required.`
        : `Warning: ${zoneName} density is ${densityRounded} p/m2. Consider redirecting foot traffic.`;

    const targetRoles =
      severity === "critical"
        ? ["fan", "organizer", "security", "emergency"]
        : ["organizer", "security"];

    // Create alert document
    const alertRef = await db.collection("alerts").add({
      type: "congestion",
      message,
      severity,
      eventId,
      zoneId,
      zoneName,
      targetRoles,
      isActive: true,
      createdBy: "system",
      createdByName: "Auto-Alert System",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      expiresAt: admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + 2 * 60 * 60 * 1000), // 2 hours from now
      ),
    });

    functions.logger.info(
      `Auto-alert ${alertRef.id} created for zone '${zoneName}' (${severity}, ${densityRounded} p/m2).`,
    );

    // Send FCM to security and emergency topics
    const fcmTitle = severity === "critical" ? "CRITICAL DENSITY ALERT" : "Crowd Density Warning";

    await Promise.all([
      sendToTopic("security_alerts", fcmTitle, message, {
        type: "crowd_density",
        alertId: alertRef.id,
        severity,
        zoneId,
      }, severity),
      sendToTopic("emergency_alerts", fcmTitle, message, {
        type: "crowd_density",
        alertId: alertRef.id,
        severity,
        zoneId,
      }, severity),
    ]);

    return alertRef.id;
  });

// ============================================================================
// (b) onIncidentCreate
// Firestore trigger on incidents/{incidentId} create.
// Sends FCM notifications and creates notification documents.
// ============================================================================
exports.onIncidentCreate = functions.firestore
  .document("incidents/{incidentId}")
  .onCreate(async (snapshot, context) => {
    const incident = snapshot.data();
    const incidentId = context.params.incidentId;

    const type = incident.type || "other";
    const severity = incident.severity || "low";
    const description = incident.description || "";
    const body = description.length > 120
      ? description.substring(0, 120) + "..."
      : description;

    const title = getIncidentTitle(type, severity);

    const fcmData = {
      type: "incident",
      incidentId,
      incidentType: type,
      severity,
    };

    // Always notify organizer topic for every incident
    const promises = [
      sendToTopic("organizer", title, body, fcmData, severity),
    ];

    // High or critical severity: also notify emergency_alerts and incidents_critical
    if (severity === "high" || severity === "critical") {
      promises.push(
        sendToTopic("emergency_alerts", title, body, fcmData, severity),
        sendToTopic("incidents_critical", title, body, fcmData, severity),
      );
    }

    await Promise.all(promises);

    // Create in-app notification documents
    const notifyRoles = ["organizer"];
    if (severity === "high" || severity === "critical") {
      notifyRoles.push("emergency", "security");
    }

    await createNotificationDocuments(title, body, "incident", incidentId, notifyRoles);

    functions.logger.info(
      `Incident ${incidentId} processed (type=${type}, severity=${severity}).`,
    );
    return null;
  });

// ============================================================================
// (c) onAlertCreate
// Firestore trigger on alerts/{alertId} create.
// Sends FCM push notifications based on targetRoles and creates notification
// documents for matching users.
// ============================================================================
exports.onAlertCreate = functions.firestore
  .document("alerts/{alertId}")
  .onCreate(async (snapshot, context) => {
    const alert = snapshot.data();
    const alertId = context.params.alertId;

    const message = alert.message || "";
    const severity = alert.severity || "info";
    const targetRoles = Array.isArray(alert.targetRoles) ? alert.targetRoles : [];

    if (targetRoles.length === 0) {
      functions.logger.warn(`Alert ${alertId} has no targetRoles, skipping FCM.`);
      return null;
    }

    const title =
      severity === "critical"
        ? "CRITICAL ALERT"
        : severity === "warning"
          ? "Warning Alert"
          : "Alert";

    const fcmData = {
      type: "alert",
      alertId,
      severity,
      alertType: alert.type || "general",
    };

    // Send FCM to each target role as a topic
    const topicPromises = targetRoles.map((role) =>
      sendToTopic(role, title, message, fcmData, severity),
    );
    await Promise.all(topicPromises);

    // Create in-app notification documents for users matching targetRoles
    await createNotificationDocuments(title, message, "alert", alertId, targetRoles);

    functions.logger.info(
      `Alert ${alertId} broadcasted to roles [${targetRoles}] (severity=${severity}).`,
    );
    return null;
  });

// ============================================================================
// (d) aggregateLocationData
// Scheduled function that runs every 30 seconds (during events) to aggregate
// location data into crowd_density documents per zone.
// ============================================================================
exports.aggregateLocationData = functions.pubsub
  .schedule("every 1 minutes") // Firebase minimum is 1 minute; we target ~30s with two invocations
  .onRun(async (_context) => {
    const now = Date.now();
    const thirtySecondsAgo = admin.firestore.Timestamp.fromDate(
      new Date(now - 30 * 1000),
    );
    const fiveMinutesAgo = admin.firestore.Timestamp.fromDate(
      new Date(now - 5 * 60 * 1000),
    );

    // ----- Step 1: Read recent location history (last 30 seconds) -----
    const locationsSnapshot = await db
      .collection("location_history")
      .where("timestamp", ">=", thirtySecondsAgo)
      .get();

    if (locationsSnapshot.empty) {
      functions.logger.info("No recent location entries found.");
      // Still perform cleanup even if there is no new data
      await cleanupOldLocationHistory(fiveMinutesAgo);
      return null;
    }

    const locations = locationsSnapshot.docs.map((doc) => doc.data());

    // ----- Step 2: Load all zones -----
    const zonesSnapshot = await db.collection("zones").get();
    if (zonesSnapshot.empty) {
      functions.logger.warn("No zones defined. Cannot aggregate density.");
      await cleanupOldLocationHistory(fiveMinutesAgo);
      return null;
    }

    const zones = zonesSnapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    // ----- Step 3: Group locations by zone using point-in-polygon -----
    const zoneCounts = {}; // zoneId -> count of people
    for (const zone of zones) {
      zoneCounts[zone.id] = 0;
    }

    for (const loc of locations) {
      const lat = typeof loc.latitude === "number" ? loc.latitude : 0;
      const lng = typeof loc.longitude === "number" ? loc.longitude : 0;

      for (const zone of zones) {
        const boundaries = zone.boundaries;
        if (!Array.isArray(boundaries) || boundaries.length < 3) continue;

        if (pointInPolygon(lat, lng, boundaries)) {
          zoneCounts[zone.id] = (zoneCounts[zone.id] || 0) + 1;
          break; // A person can only be in one zone
        }
      }
    }

    // ----- Step 4: Calculate density per zone and write to crowd_density -----
    const batch = db.batch();

    for (const zone of zones) {
      const count = zoneCounts[zone.id] || 0;
      const capacity = zone.capacity || 1;
      const boundaries = zone.boundaries;

      // Calculate area; fall back to capacity * 0.5 m2 if boundaries are insufficient
      let areaSqM = polygonAreaSqMeters(boundaries || []);
      if (areaSqM < 1) {
        areaSqM = capacity * 0.5;
      }

      const densityPerSqMeter = areaSqM > 0 ? count / areaSqM : 0;
      const status = getStatusFromDensity(densityPerSqMeter);

      const densityRef = db.collection("crowd_density").doc(zone.id);
      batch.set(
        densityRef,
        {
          zoneId: zone.id,
          zoneName: zone.name || "Unknown",
          eventId: zone.eventId || null,
          currentPopulation: count,
          capacity,
          densityPerSqMeter: parseFloat(densityPerSqMeter.toFixed(4)),
          status,
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    }

    await batch.commit();
    functions.logger.info(
      `Aggregated density for ${zones.length} zones from ${locations.length} location entries.`,
    );

    // ----- Step 5: Clean up old location_history entries (> 5 minutes) -----
    await cleanupOldLocationHistory(fiveMinutesAgo);

    return null;
  });

/**
 * Delete location_history documents older than the given timestamp.
 * @param {admin.firestore.Timestamp} cutoff - Entries older than this are deleted.
 */
async function cleanupOldLocationHistory(cutoff) {
  const oldEntriesQuery = db
    .collection("location_history")
    .where("timestamp", "<", cutoff);

  const deleted = await deleteQueryBatched(oldEntriesQuery);
  if (deleted > 0) {
    functions.logger.info(`Cleaned up ${deleted} old location_history entries.`);
  }
}

// ============================================================================
// (e) cleanupOldData
// Scheduled function that runs daily to perform housekeeping:
//  - Delete location_history older than 30 days
//  - Delete expired alerts
//  - Archive resolved incidents older than 30 days
// ============================================================================
exports.cleanupOldData = functions.pubsub
  .schedule("every 24 hours")
  .onRun(async (_context) => {
    const now = Date.now();
    const thirtyDaysAgo = admin.firestore.Timestamp.fromDate(
      new Date(now - 30 * 24 * 60 * 60 * 1000),
    );
    const nowTimestamp = admin.firestore.Timestamp.now();

    // ----- 1. Delete old location_history (> 30 days) -----
    const oldLocationQuery = db
      .collection("location_history")
      .where("timestamp", "<", thirtyDaysAgo);

    const locationsDeleted = await deleteQueryBatched(oldLocationQuery);
    functions.logger.info(`Deleted ${locationsDeleted} location_history entries older than 30 days.`);

    // ----- 2. Delete expired alerts -----
    const expiredAlertsQuery = db
      .collection("alerts")
      .where("expiresAt", "<=", nowTimestamp);

    const expiredSnapshot = await expiredAlertsQuery.get();
    let alertsDeleted = 0;

    if (!expiredSnapshot.empty) {
      const batch = db.batch();
      expiredSnapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
        alertsDeleted++;
      });
      await batch.commit();
    }
    functions.logger.info(`Deleted ${alertsDeleted} expired alerts.`);

    // ----- 3. Archive resolved incidents older than 30 days -----
    const oldIncidentsQuery = db
      .collection("incidents")
      .where("status", "==", "resolved")
      .where("updatedAt", "<=", thirtyDaysAgo);

    const oldIncidentsSnapshot = await oldIncidentsQuery.get();
    let archivedCount = 0;

    if (!oldIncidentsSnapshot.empty) {
      // Process in batches to stay within Firestore limits
      const batchSize = 400;
      let batchDocs = [];

      for (const doc of oldIncidentsSnapshot.docs) {
        batchDocs.push(doc);

        if (batchDocs.length >= batchSize) {
          await archiveIncidentBatch(batchDocs);
          archivedCount += batchDocs.length;
          batchDocs = [];
        }
      }

      // Handle remaining docs
      if (batchDocs.length > 0) {
        await archiveIncidentBatch(batchDocs);
        archivedCount += batchDocs.length;
      }
    }

    functions.logger.info(`Archived ${archivedCount} resolved incidents older than 30 days.`);
    return null;
  });

/**
 * Move a batch of incident documents to the archived_incidents collection
 * and delete the originals.
 * @param {Array<FirebaseFirestore.QueryDocumentSnapshot>} docs - Incident docs to archive.
 */
async function archiveIncidentBatch(docs) {
  const batch = db.batch();
  for (const doc of docs) {
    const archiveRef = db.collection("archived_incidents").doc(doc.id);
    batch.set(archiveRef, {
      ...doc.data(),
      archivedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    batch.delete(doc.ref);
  }
  await batch.commit();
}

// ============================================================================
// (f) onUserCreate
// Auth trigger on user creation.
// Sends a welcome notification and subscribes the user to role-based FCM topics.
// ============================================================================
exports.onUserCreate = functions.auth.user().onCreate(async (user) => {
  const uid = user.uid;
  const email = user.email || "";
  const displayName = user.displayName || email.split("@")[0] || "New User";

  functions.logger.info(`New user created: ${uid} (${email})`);

  // Wait briefly for the client to write the user profile document
  // (the Flutter app creates the /users/{uid} doc upon registration).
  // We retry a few times to handle race conditions.
  let userDoc = null;
  let role = "fan"; // default role

  for (let attempt = 0; attempt < 3; attempt++) {
    const snap = await db.collection("users").doc(uid).get();
    if (snap.exists) {
      userDoc = snap.data();
      role = userDoc.role || "fan";
      break;
    }
    // Wait 2 seconds before retrying
    await new Promise((resolve) => setTimeout(resolve, 2000));
  }

  // ----- 1. Create welcome notification document -----
  await db.collection("notifications").add({
    userId: uid,
    title: "Welcome to Mundial Manager!",
    body: `Hello ${displayName}, your account has been set up as ${formatRole(role)}. ` +
      "You will receive important updates and alerts here.",
    type: "welcome",
    referenceId: uid,
    isRead: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  functions.logger.info(`Welcome notification created for user ${uid} (role=${role}).`);

  // ----- 2. Subscribe user to role-based FCM topics -----
  // We need at least one FCM registration token to subscribe.
  // Check if the user doc contains an fcmToken field.
  const fcmToken = userDoc ? userDoc.fcmToken : null;

  if (fcmToken) {
    const topics = ROLE_TOPICS[role] || ROLE_TOPICS["fan"];
    // Always subscribe to the role topic itself
    const allTopics = [role, ...topics];
    const uniqueTopics = [...new Set(allTopics)];

    for (const topic of uniqueTopics) {
      try {
        await messaging.subscribeToTopic([fcmToken], topic);
        functions.logger.info(`Subscribed user ${uid} to topic '${topic}'.`);
      } catch (error) {
        functions.logger.error(
          `Failed to subscribe user ${uid} to topic '${topic}':`,
          error,
        );
      }
    }
  } else {
    functions.logger.info(
      `No FCM token found for user ${uid}. Topic subscriptions will be handled on first app launch.`,
    );
  }

  return null;
});

/**
 * Format a role key into a display-friendly string.
 * @param {string} role - Role key (fan, organizer, security, emergency).
 * @returns {string} Human-readable role name.
 */
function formatRole(role) {
  const names = {
    fan: "a Fan",
    organizer: "an Event Organizer",
    security: "Security Team",
    emergency: "Emergency Services",
  };
  return names[role] || role;
}
