export default class NotificationsService {
  async notifyUser(userId: number, title: string, body: string, data?: Record<string, unknown>) {
    // TODO: Brancher FCM/WebSocket
    console.log(`[NOTIFY user:${userId}] ${title} - ${body}`, data ?? {})
  }

  async notifyContact(
    contact: string,
    title: string,
    body: string,
    data?: Record<string, unknown>
  ) {
    // TODO: SMS/Email provider
    console.log(`[NOTIFY contact:${contact}] ${title} - ${body}`, data ?? {})
  }
}


