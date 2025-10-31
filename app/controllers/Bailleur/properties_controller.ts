import type { HttpContext } from '@adonisjs/core/http'
import { PropertyValidator } from '#validators/Bailleur/property'
import Property from '#models/property'
import app from '@adonisjs/core/services/app'
import Contract from '#models/contract'
import User from '#models/user' // Assurez-vous que ce modèle existe

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
   * 🔎 Afficher un logement (bailleur ou locataire)
   */
  async show({ params, auth, response }: HttpContext) {
    const user = auth.user
    if (!user) {
      return response.unauthorized({ message: 'You are not authorized' })
    }

    // On précharge les informations du bailleur (user).
    const property = await Property.query().where('id', params.id).preload('user').first()

    if (!property) {
      return response.notFound({ message: 'Logement introuvable' })
    }

    const isOwner = user.id === property.user_id

    // On vérifie s'il existe un contrat entre l'utilisateur et le logement
    const contract = await Contract.query()
      .where('property_id', property.id)
      .where('tenant_id', user.id)
      .first()
    const isTenant = !!contract

    if (!isOwner && !isTenant) {
      return response.forbidden({ message: "Vous n'avez pas accès à ce logement" })
    }

    // On s'assure de ne retourner que les informations publiques du bailleur
    const ownerDetails = property.user.serialize()

    const propertyData = {
      ...property.serialize(),
      user: {
        id: ownerDetails.id,
        fullName: ownerDetails.fullName,
        email: ownerDetails.email,
        portable: ownerDetails.portable,
      },
    }

    // La réponse inclut maintenant les données du logement et celles du bailleur
    return response.ok({ message: 'Détails du logement', data: propertyData })
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
      surface: property.surface ?? property.surface,
      rooms: property.rooms ?? property.rooms,
      capacity: property.capacity ?? property.capacity,
      price: property.price ?? property.price,
      description: property.description ?? property.description,
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

  /**
   * 👥 Liste des locataires du bailleur connecté
   */
  async listTenants({ auth, response }: HttpContext) {
    const user = auth.user
    if (!user) return response.unauthorized({ message: 'You are not authorized' })

    await user.load('roles')
    const isBailleur = user.roles?.some((r) => r.name === 'bailleur') ?? false
    if (!isBailleur)
      return response.forbidden({ message: "Vous n'êtes pas autorisé à accéder à cette liste" })

    // 1. Récupérer les IDs de propriétés du bailleur
    const userProperties = await Property.query().where('user_id', user.id).select('id')

    const propertyIds = userProperties.map((prop) => prop.id)

    if (propertyIds.length === 0) {
      return response.ok({
        message: 'Liste des locataires récupérée (aucune propriété)',
        data: [],
      })
    }

    // 2. Récupérer les IDs de locataires à partir des contrats de ces propriétés
    const contractTenants = await Contract.query()
      .whereIn('propertyId', propertyIds)
      .select('tenantId') // Sélectionner uniquement le tenantId

    const tenantIds = contractTenants
      .map((contract) => contract.tenantId)
      // 💡 S'assurer d'avoir des IDs uniques
      .filter((value, index, self) => self.indexOf(value) === index)

    if (tenantIds.length === 0) {
      return response.ok({
        message: 'Liste des locataires récupérée (aucun contrat trouvé)',
        data: [],
      })
    }

    // 3. Récupérer les informations des locataires
    const tenants = await User.query()
      .whereIn('id', tenantIds)
      .select(['id', 'fullName', 'email', 'portable']) // 🔒 SÉLECTIONNER UNIQUEMENT LES CHAMPS PUBLICS

    return response.ok({
      message: 'Liste des locataires récupérée avec succès',
      data: tenants,
    })
  }
}
