import type { HttpContext } from '@adonisjs/core/http'
import { ApplyToPropertyValidator } from '#validators/applications'
import Property from '#models/property'
import Application, { ApplicationStatus } from '#models/application'
import Contract from '#models/contract'
import { DateTime } from 'luxon'
import NotificationsService from '#services/notifications_service'

export default class ApplicationsController {
  /**
   * GET /api/properties/:id/applications
   * Le bailleur voit les candidatures d’un logement lui appartenant
   */
  async index({ params, auth, response }: HttpContext) {
    const user = auth.user
    if (!user) return response.unauthorized({ message: 'Non authentifié' })

    const propertyId = Number(params.id)
    const property = await Property.find(propertyId)
    if (!property) return response.notFound({ message: 'Logement introuvable' })
    if (property.user_id !== user.id) {
      return response.forbidden({ message: "Vous n'êtes pas propriétaire de ce logement" })
    }

    const apps = await Application.query()
      .where('property_id', propertyId)
      .preload('tenant', (t) => t.select(['id', 'fullName', 'email', 'portable']))

    return response.ok({ message: 'Candidatures', data: apps })
  }

  /**
   * PATCH /api/applications/:id/accept
   */
  async accept({ params, auth, response }: HttpContext) {
    const user = auth.user
    if (!user) return response.unauthorized({ message: 'Non authentifié' })
    const application = await Application.find(params.id)
    if (!application) return response.notFound({ message: 'Candidature introuvable' })
    const property = await Property.find(application.propertyId)
    if (!property) return response.notFound({ message: 'Logement introuvable' })
    if (property.user_id !== user.id)
      return response.forbidden({ message: "Vous n'êtes pas propriétaire de ce logement" })

    application.status = ApplicationStatus.ACCEPTED
    await application.save()
    return response.ok({ message: 'Candidature acceptée', data: application })
  }

  /**
   * PATCH /api/applications/:id/reject
   */
  async reject({ params, auth, response }: HttpContext) {
    const user = auth.user
    if (!user) return response.unauthorized({ message: 'Non authentifié' })
    const application = await Application.find(params.id)
    if (!application) return response.notFound({ message: 'Candidature introuvable' })
    const property = await Property.find(application.propertyId)
    if (!property) return response.notFound({ message: 'Logement introuvable' })
    if (property.user_id !== user.id)
      return response.forbidden({ message: "Vous n'êtes pas propriétaire de ce logement" })

    application.status = ApplicationStatus.REJECTED
    await application.save()
    return response.ok({ message: 'Candidature refusée', data: application })
  }

  /**
   * POST /api/applications/:id/create-contract
   * Crée un contrat minimal à partir d’une candidature (MVP)
   */
  async createContract({ params, auth, response }: HttpContext) {
    const user = auth.user
    if (!user) return response.unauthorized({ message: 'Non authentifié' })
    const application = await Application.find(params.id)
    if (!application) return response.notFound({ message: 'Candidature introuvable' })
    const property = await Property.find(application.propertyId)
    if (!property) return response.notFound({ message: 'Logement introuvable' })
    if (property.user_id !== user.id)
      return response.forbidden({ message: "Vous n'êtes pas propriétaire de ce logement" })

    // Création contrat simple: actif, loyer = price, dépôt = 1 mois, currency USD
    const now = DateTime.now()
    const contract = await Contract.create({
      propertyId: property.id,
      tenantId: application.tenantId,
      startDate: now,
      endDate: now.plus({ months: 12 }),
      description: application.message || null,
      rentAmount: property.price,
      currency: 'USD',
      status: 'active',
      depositMonths: 1,
      depositAmount: property.price,
      depositStatus: 'pending',
    })

    application.status = ApplicationStatus.ACCEPTED
    await application.save()

    return response.created({ message: 'Contrat créé à partir de la candidature', data: contract })
  }
  /**
   * POST /api/properties/:id/apply
   * Le locataire postule pour un logement.
   */
  async apply({ params, request, auth, response }: HttpContext) {
    const user = auth.user
    if (!user) return response.unauthorized({ message: 'Non authentifié' })

    const propertyId = Number(params.id)
    const property = await Property.find(propertyId)
    if (!property) return response.notFound({ message: 'Logement introuvable' })

    const payload = await request.validateUsing(ApplyToPropertyValidator)

    // Vérifier l'absence de candidature en attente existante
    const existing = await Application.query()
      .where('property_id', propertyId)
      .andWhere('tenant_id', user.id)
      .andWhere('status', ApplicationStatus.PENDING)
      .first()
    if (existing) {
      return response.badRequest({ message: 'Candidature déjà en attente pour ce logement' })
    }

    const appRow = await Application.create({
      propertyId: propertyId,
      tenantId: user.id,
      message: payload.message ?? null,
      status: ApplicationStatus.PENDING,
    })

    // Notification au bailleur propriétaire
    const notifier = new NotificationsService()
    await notifier.notifyUser(property.user_id, 'Nouvelle candidature', `Un locataire a postulé pour votre logement #${propertyId}`, {
      propertyId,
      applicationId: appRow.id,
    })

    return response.created({ message: 'Candidature enregistrée', data: appRow })
  }
}


