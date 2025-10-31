// import type { HttpContext } from '@adonisjs/core/http'

import User from '#models/user'
import Role from '#models/role'
import hash from '@adonisjs/core/services/hash'
import { RegisterValidator } from '#validators/Auth/register'
import { HttpContext } from '@adonisjs/core/http'

export default class RegistersController {
  async register({ request, response }: HttpContext) {
    const data = await request.validateUsing(RegisterValidator)

    try {
      //Hash du mot de passe
      const hashedPassword = await hash.use('scrypt').make(data.password)

      //Création de l'utilisateur
      const user = await User.create({
        fullName: data.full_name,
        email: data.email.trim().toLowerCase(),
        portable: data.portable,
        password: hashedPassword,
      })

      //Attribution des rôles
      const roleNames = data.roles && data.roles.length > 0 ? data.roles : ['locataire']
      const roles = await Role.query().whereIn('name', roleNames)

      if (roles.length > 0) {
        // @ts-ignore
        await user.related('roles').attach(roles.map((r) => r.id))
      }

      // Charger les rôles pour la réponse
      await user.load('roles')

      // 🔑 Génération du token
      const token = await User.accessTokens.create(user)

      // ✅ Réponse structurée
      return response.created({
        status: 'success',
        message: 'Inscription réussie',
        data: {
          user: user.serialize({
            fields: { omit: ['password'] },
            relations: { roles: { fields: ['id', 'name'] } },
          }),
          token: token.value!.release(),
        },
      })
    } catch (error) {
      console.error('Register error:', error)
      return response.internalServerError({
        status: 'error',
        message: 'Inscription échouée',
        error: error.message,
      })
    }
  }
}
