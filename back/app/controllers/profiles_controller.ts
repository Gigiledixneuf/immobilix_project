import type { HttpContext } from '@adonisjs/core/http'
import { UpdateProfileValidator } from '#validators/profile'

export default class ProfilesController {
  /**
   * Récupère le profil de l'utilisateur actuellement authentifié.
   */
  async show({ auth, response }: HttpContext) {
    const user = auth.user!

    await user.load('roles')

    return response.ok(user)
  }

  /**
   * Met à jour le profil de l'utilisateur authentifié.
   */
  async update({ auth, request, response }: HttpContext) {
    const user = auth.user!

    const payload = await request.validateUsing(UpdateProfileValidator, {
      meta: {
        userId: user.id,
      },
    })

    user.merge(payload)
    await user.save()

    await user.load('roles')

    return response.ok({
      message: 'Profil mis à jour avec succès.',
      user,
    })
  }
}
