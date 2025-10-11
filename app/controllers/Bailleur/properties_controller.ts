import type { HttpContext } from '@adonisjs/core/http'
import { PropertyValidator } from '#validators/Bailleur/property'
import Property from '#models/property'
import app from '@adonisjs/core/services/app'

export default class PropertiesController {
  /**
   * 🏠 Liste des logements du bailleur connecté
   */
  async index({ auth, response }: HttpContext) {
    const user = auth.user
    if (!user) return response.unauthorized({ message: 'You are not authorized' })

    await user.load('roles')
    const isBailleur = user.roles?.some((r) => r.name === 'bailleur') ?? false
    if (!isBailleur) return response.badRequest({ message: "Vous n'êtes pas bailleur" })

    const properties = await Property.query().where('user_id', user.id)
    return response.ok({ message: 'Liste des logements récupérée', data: properties })
  }

  /**
   * 🧱 Créer un nouveau logement
   */
  async store({ request, auth, response }: HttpContext) {
    const user = auth.user
    if (!user) return response.unauthorized({ message: 'You are not authorized' })

    await user.load('roles')
    const isBailleur = user.roles?.some((role) => role.name === 'bailleur') ?? false
    if (!isBailleur) return response.badRequest({ message: "Vous n'êtes pas bailleur" })

    const payload = await request.validateUsing(PropertyValidator)

    let fileName: string | undefined
    if (payload.main_photo_url) {
      await payload.main_photo_url.move(app.makePath('uploads/properties'))
      fileName = payload.main_photo_url.fileName
    }

    const property = await Property.create({
      name: payload.name,
      address: payload.address,
      city: payload.city,
      type: payload.type,
      surface: payload.surface ?? null,
      rooms: payload.rooms ?? null,
      capacity: payload.capacity,
      price: payload.price,
      description: payload.description,
      mainPhotoUrl: fileName,
      user_id: user.id,
    })

    return response.created({
      message: 'Logement créé avec succès',
      data: property,
    })
  }

  /**
   * 🔎 Afficher un logement (seulement s’il appartient au bailleur)
   */
  async show({ params, auth, response }: HttpContext) {
    const user = auth.user
    if (!user) return response.unauthorized({ message: 'You are not authorized' })

    const property = await Property.find(params.id)
    if (!property) return response.notFound({ message: 'Logement introuvable' })

    if (property.user_id !== user.id)
      return response.forbidden({ message: "Vous n'avez pas accès à ce logement" })

    return response.ok({ message: 'Détails du logement', data: property })
  }

  /**
   * ✏️ Modifier un logement
   */
  async update({ params, request, auth, response }: HttpContext) {
    const user = auth.user
    if (!user) return response.unauthorized({ message: 'You are not authorized' })

    const property = await Property.find(params.id)
    if (!property) return response.notFound({ message: 'Logement introuvable' })
    if (property.user_id !== user.id)
      return response.forbidden({ message: "Vous n'avez pas accès à ce logement" })

    const payload = await request.validateUsing(PropertyValidator)

    let fileName: string | undefined
    if (payload.main_photo_url) {
      await payload.main_photo_url.move(app.makePath('uploads/properties'))
      fileName = payload.main_photo_url.fileName
    }

    property.merge({
      name: payload.name,
      address: payload.address,
      city: payload.city,
      type: payload.type,
      surface: payload.surface ?? property.surface,
      rooms: payload.rooms ?? property.rooms,
      capacity: payload.capacity ?? property.capacity,
      price: payload.price ?? property.price,
      description: payload.description ?? property.description,
      mainPhotoUrl: fileName ?? property.mainPhotoUrl,
    })

    await property.save()

    return response.ok({
      message: 'Logement mis à jour avec succès',
      data: property,
    })
  }

  /**
   * 🗑️ Supprimer un logement
   */
  async destroy({ params, auth, response }: HttpContext) {
    const user = auth.user
    if (!user) return response.unauthorized({ message: 'You are not authorized' })

    const property = await Property.find(params.id)
    if (!property) return response.notFound({ message: 'Logement introuvable' })
    if (property.user_id !== user.id)
      return response.forbidden({ message: "Vous n'avez pas accès à ce logement" })

    await property.delete()
    return response.ok({ message: 'Logement supprimé avec succès' })
  }
}
