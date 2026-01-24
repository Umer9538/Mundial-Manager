import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// Initialize Firebase Admin
admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

// Density thresholds for auto-alerts
const DENSITY_THRESHOLDS = {
  warning: 0.7,   // 70% capacity
  high: 0.85,     // 85% capacity
  critical: 0.95, // 95% capacity
};

// ============================================
// CROWD DENSITY AUTO-ALERT FUNCTION
// ============================================
/**
 * Triggered when crowd density data is created/updated.
 * Automatically creates alerts when density exceeds thresholds.
 */
export const onCrowdDensityUpdate = functions.firestore
  .document("crowd_density/{densityId}")
  .onWrite(async (change, context) => {
    const data = change.after.data();
    if (!data) return null;

    const density = data.density as number;
    const zoneName = data.zoneName as string;
    const eventId = data.eventId as string;
    const zoneId = data.zoneId as string;

    // Determine severity based on density
    let severity: string | null = null;
    let shouldAlert = false;

    if (density >= DENSITY_THRESHOLDS.critical) {
      severity = "critical";
      shouldAlert = true;
    } else if (density >= DENSITY_THRESHOLDS.high) {
      severity = "warning";
      shouldAlert = true;
    } else if (density >= DENSITY_THRESHOLDS.warning) {
      severity = "info";
      shouldAlert = true;
    }

    if (!shouldAlert || !severity) return null;

    // Check if similar active alert already exists (within last 30 minutes)
    const thirtyMinutesAgo = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() - 30 * 60 * 1000)
    );

    const existingAlerts = await db
      .collection("alerts")
      .where("eventId", "==", eventId)
      .where("zoneId", "==", zoneId)
      .where("type", "==", "congestion")
      .where("isActive", "==", true)
      .where("createdAt", ">=", thirtyMinutesAgo)
      .get();

    if (!existingAlerts.empty) {
      functions.logger.info(
        `Active congestion alert already exists for zone ${zoneName}`
      );
      return null;
    }

    // Create auto-alert
    const percentOccupied = Math.round(density * 100);
    const alertMessage = getAlertMessage(severity, zoneName, percentOccupied);

    const alertRef = await db.collection("alerts").add({
      type: "congestion",
      message: alertMessage,
      severity: severity,
      eventId: eventId,
      zoneId: zoneId,
      targetRoles: getTargetRolesForSeverity(severity),
      isActive: true,
      createdBy: "system",
      createdByName: "Auto-Alert System",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      expiresAt: admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + 2 * 60 * 60 * 1000) // 2 hours
      ),
    });

    functions.logger.info(
      `Created auto-alert ${alertRef.id} for ${zoneName} at ${percentOccupied}% capacity`
    );

    // Send push notification
    await sendAlertNotification(alertMessage, severity, getTargetRolesForSeverity(severity));

    return alertRef.id;
  });

// ============================================
// INCIDENT NOTIFICATION FUNCTION
// ============================================
/**
 * Triggered when a new incident is created.
 * Sends push notifications to relevant staff.
 */
export const onIncidentCreated = functions.firestore
  .document("incidents/{incidentId}")
  .onCreate(async (snapshot, context) => {
    const incident = snapshot.data();
    const incidentId = context.params.incidentId;

    const type = incident.type as string;
    const severity = incident.severity as string;
    const description = incident.description as string;

    // Determine notification targets based on incident type
    const targetTopics = getIncidentTargetTopics(type, severity);

    const title = getIncidentTitle(type, severity);
    const body = description.length > 100
      ? description.substring(0, 100) + "..."
      : description;

    // Send to each target topic
    for (const topic of targetTopics) {
      try {
        await messaging.send({
          topic: topic,
          notification: {
            title: title,
            body: body,
          },
          data: {
            type: "incident",
            incidentId: incidentId,
            incidentType: type,
            severity: severity,
            click_action: "FLUTTER_NOTIFICATION_CLICK",
          },
          android: {
            priority: severity === "critical" ? "high" : "normal",
            notification: {
              channelId: "incidents",
              priority: severity === "critical" ? "max" : "high",
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

        functions.logger.info(`Notification sent to topic: ${topic}`);
      } catch (error) {
        functions.logger.error(`Error sending to topic ${topic}:`, error);
      }
    }

    // Create notification records for relevant users
    await createNotificationRecords(
      title,
      body,
      "incident",
      incidentId,
      targetTopics
    );

    return null;
  });

// ============================================
// INCIDENT STATUS UPDATE NOTIFICATION
// ============================================
/**
 * Triggered when an incident is updated.
 * Notifies relevant parties of status changes.
 */
export const onIncidentUpdated = functions.firestore
  .document("incidents/{incidentId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const incidentId = context.params.incidentId;

    // Check if status changed
    if (before.status === after.status) return null;

    const statusMessages: Record<string, string> = {
      dispatched: "Help is on the way",
      on_site: "Responders have arrived",
      resolved: "Incident has been resolved",
    };

    const newStatus = after.status as string;
    const statusMessage = statusMessages[newStatus];

    if (!statusMessage) return null;

    const title = `Incident Update: ${statusMessage}`;
    const body = `${after.type} incident status changed to ${newStatus}`;

    // Notify security and emergency teams
    const topics = ["security", "emergency"];

    for (const topic of topics) {
      try {
        await messaging.send({
          topic: topic,
          notification: {
            title: title,
            body: body,
          },
          data: {
            type: "incident_update",
            incidentId: incidentId,
            newStatus: newStatus,
            click_action: "FLUTTER_NOTIFICATION_CLICK",
          },
        });
      } catch (error) {
        functions.logger.error(`Error sending update to ${topic}:`, error);
      }
    }

    return null;
  });

// ============================================
// ALERT BROADCAST NOTIFICATION
// ============================================
/**
 * Triggered when a new alert is created.
 * Sends push notifications to targeted roles.
 */
export const onAlertCreated = functions.firestore
  .document("alerts/{alertId}")
  .onCreate(async (snapshot, context) => {
    const alert = snapshot.data();
    const alertId = context.params.alertId;

    // Skip if created by system (already handled by auto-alert)
    if (alert.createdBy === "system") return null;

    const message = alert.message as string;
    const severity = alert.severity as string;
    const targetRoles = alert.targetRoles as string[];

    await sendAlertNotification(message, severity, targetRoles, alertId);

    return null;
  });

// ============================================
// EXPIRED ALERTS CLEANUP (Scheduled)
// ============================================
/**
 * Runs every hour to deactivate expired alerts.
 */
export const cleanupExpiredAlerts = functions.pubsub
  .schedule("every 1 hours")
  .onRun(async () => {
    const now = admin.firestore.Timestamp.now();

    const expiredAlerts = await db
      .collection("alerts")
      .where("isActive", "==", true)
      .where("expiresAt", "<=", now)
      .get();

    const batch = db.batch();
    let count = 0;

    expiredAlerts.forEach((doc) => {
      batch.update(doc.ref, { isActive: false });
      count++;
    });

    if (count > 0) {
      await batch.commit();
      functions.logger.info(`Deactivated ${count} expired alerts`);
    }

    return null;
  });

// ============================================
// EVENT STATUS AUTO-UPDATE (Scheduled)
// ============================================
/**
 * Runs every 15 minutes to update event statuses.
 */
export const updateEventStatuses = functions.pubsub
  .schedule("every 15 minutes")
  .onRun(async () => {
    const now = admin.firestore.Timestamp.now();

    // Get events that should be active (started but not ended)
    const eventsToActivate = await db
      .collection("events")
      .where("status", "==", "upcoming")
      .where("startDate", "<=", now)
      .get();

    // Get events that should be completed (end date passed)
    const eventsToComplete = await db
      .collection("events")
      .where("status", "==", "active")
      .where("endDate", "<=", now)
      .get();

    const batch = db.batch();
    let activatedCount = 0;
    let completedCount = 0;

    eventsToActivate.forEach((doc) => {
      batch.update(doc.ref, { status: "active" });
      activatedCount++;
    });

    eventsToComplete.forEach((doc) => {
      batch.update(doc.ref, { status: "completed" });
      completedCount++;
    });

    if (activatedCount > 0 || completedCount > 0) {
      await batch.commit();
      functions.logger.info(
        `Updated events: ${activatedCount} activated, ${completedCount} completed`
      );
    }

    return null;
  });

// ============================================
// HELPER FUNCTIONS
// ============================================

function getAlertMessage(
  severity: string,
  zoneName: string,
  percentOccupied: number
): string {
  switch (severity) {
    case "critical":
      return `CRITICAL: ${zoneName} is at ${percentOccupied}% capacity! Immediate crowd control required.`;
    case "warning":
      return `Warning: ${zoneName} is experiencing high congestion (${percentOccupied}% capacity). Consider alternate routes.`;
    default:
      return `${zoneName} is filling up (${percentOccupied}% capacity). Please be aware of crowd levels.`;
  }
}

function getTargetRolesForSeverity(severity: string): string[] {
  switch (severity) {
    case "critical":
      return ["fan", "organizer", "security", "emergency"];
    case "warning":
      return ["fan", "security", "organizer"];
    default:
      return ["fan"];
  }
}

function getIncidentTargetTopics(type: string, severity: string): string[] {
  const topics: string[] = ["security"];

  if (type === "medical" || severity === "critical") {
    topics.push("emergency");
  }

  if (severity === "critical" || severity === "high") {
    topics.push("organizer");
  }

  return topics;
}

function getIncidentTitle(type: string, severity: string): string {
  const typeLabels: Record<string, string> = {
    medical: "Medical Emergency",
    security: "Security Incident",
    overcrowding: "Overcrowding Alert",
    facility: "Facility Issue",
    other: "Incident Report",
  };

  const label = typeLabels[type] || "Incident";
  const severityLabel = severity === "critical" ? " - CRITICAL" : "";

  return `${label}${severityLabel}`;
}

async function sendAlertNotification(
  message: string,
  severity: string,
  targetRoles: string[],
  alertId?: string
): Promise<void> {
  const title =
    severity === "critical"
      ? "CRITICAL ALERT"
      : severity === "warning"
        ? "Warning Alert"
        : "Alert";

  for (const role of targetRoles) {
    try {
      await messaging.send({
        topic: role,
        notification: {
          title: title,
          body: message,
        },
        data: {
          type: "alert",
          alertId: alertId || "",
          severity: severity,
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
        android: {
          priority: severity === "critical" ? "high" : "normal",
          notification: {
            channelId: "alerts",
            priority: severity === "critical" ? "max" : "high",
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

      functions.logger.info(`Alert notification sent to role: ${role}`);
    } catch (error) {
      functions.logger.error(`Error sending alert to ${role}:`, error);
    }
  }
}

async function createNotificationRecords(
  title: string,
  body: string,
  type: string,
  referenceId: string,
  targetTopics: string[]
): Promise<void> {
  // Get users matching target roles
  const usersSnapshot = await db
    .collection("users")
    .where("role", "in", targetTopics)
    .where("isActive", "==", true)
    .get();

  const batch = db.batch();

  usersSnapshot.forEach((userDoc) => {
    const notificationRef = db.collection("notifications").doc();
    batch.set(notificationRef, {
      userId: userDoc.id,
      title: title,
      body: body,
      type: type,
      referenceId: referenceId,
      isRead: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  if (!usersSnapshot.empty) {
    await batch.commit();
    functions.logger.info(
      `Created ${usersSnapshot.size} notification records`
    );
  }
}
