import type { HttpContext } from '@adonisjs/core/http'
import User from '#models/user'
import { UpdateProfileValidator } from '#validators/profile'

export default class AdminUsersController {
  /**
   * Liste tous les utilisateurs. Réservé aux administrateurs.
   */
  async index({ auth, response }: HttpContext) {
    const user = auth.user
    if (!user) return response.unauthorized()

    await user.load('roles')
    const isAdmin = user.roles && user.roles.some((role) => role.name === 'admin')

    if (!isAdmin) {
      return response.forbidden({ message: 'Accès refusé.' })
    }

    const users = await User.query().preload('roles')
    return response.ok(users)
  }

  /**
   * Affiche un utilisateur spécifique. Réservé aux administrateurs.
   */
  async show({ auth, params, response }: HttpContext) {
    const user = auth.user
    if (!user) return response.unauthorized()

    await user.load('roles')
    const isAdmin = user.roles && user.roles.some((role) => role.name === 'admin')

    if (!isAdmin) {
      return response.forbidden({ message: 'Accès refusé.' })
    }

    const targetUser = await User.findOrFail(params.id)
    await targetUser.load('roles')

    return response.ok(targetUser)
  }

  /**
   * Met à jour un utilisateur spécifique. Réservé aux administrateurs.
   */
  async update({ auth, params, request, response }: HttpContext) {
    const user = auth.user
    if (!user) return response.unauthorized()

    await user.load('roles')
    const isAdmin = user.roles && user.roles.some((role) => role.name === 'admin')

    if (!isAdmin) {
      return response.forbidden({ message: 'Accès refusé.' })
    }

    const targetUser = await User.findOrFail(params.id)

    const payload = await request.validateUsing(UpdateProfileValidator, {
      meta: {
        userId: targetUser.id,
      },
    })

    targetUser.merge(payload)
    await targetUser.save()

    await targetUser.load('roles')

    return response.ok({
      message: 'Utilisateur mis à jour avec succès.',
      user: targetUser,
    })
  }
}
