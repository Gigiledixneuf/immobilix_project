import type { HttpContext } from '@adonisjs/core/http'
import { CreateInviteValidator } from '#validators/invites'
import Invite, { InviteStatus } from '#models/invite'
import Property from '#models/property'
import NotificationsService from '#services/notifications_service'

function generateCode(length = 8): string {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'
  let out = ''
  for (let i = 0; i < length; i++) out += chars[Math.floor(Math.random() * chars.length)]
  return out
}

export default class InvitesController {
  /**
   * POST /api/invites
   * Le bailleur envoie une invitation à un locataire (email/téléphone), optionnellement liée à un logement.
   */
  async store({ request, auth, response }: HttpContext) {
    const user = auth.user
    if (!user) return response.unauthorized({ message: 'Non authentifié' })

    const payload = await request.validateUsing(CreateInviteValidator)

    if (payload.propertyId) {
      const property = await Property.find(payload.propertyId)
      if (!property) return response.notFound({ message: 'Logement introuvable' })
      if (property.user_id !== user.id) {
        return response.forbidden({ message: "Vous n'êtes pas propriétaire de ce logement" })
      }
    }

    const code = generateCode()

    const invite = await Invite.create({
      landlordId: user.id,
      propertyId: payload.propertyId ?? null,
      contact: payload.contact,
      code,
      status: InviteStatus.PENDING,
    })

    const notifier = new NotificationsService()
    await notifier.notifyContact(
      payload.contact,
      'Invitation ImmobiliX',
      `Vous avez été invité à rejoindre ImmobiliX. Code: ${code}`,
      {
      propertyId: payload.propertyId ?? undefined,
      code,
    })

    return response.created({ message: 'Invitation créée', data: invite })
  }
}


