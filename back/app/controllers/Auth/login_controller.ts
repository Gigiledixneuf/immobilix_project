// import type { HttpContext } from '@adonisjs/core/http'

import { HttpContext } from '@adonisjs/core/http'
import User from '#models/user'
import hash from '@adonisjs/core/services/hash'
import { errors } from '@vinejs/vine'

export default class LoginController {
  async login({ request, response }: HttpContext) {
    try {
      const { email, password } = request.only(['email', 'password'])

      /**
       * Find a user by email. Return error if a user does
       * not exist
       */
      const user = await User.findBy('email', email)

      if (!user) {
        return response.abort('Invalid credentials')
      }

      /**
       * Verify the password using the hash service
       */
      await hash.verify(user.password, password)

      const token = await User.accessTokens.create(user)

      return response.ok({
        status: 'success',
        message: 'Login successful',
        data: {
          user: user.serialize({
            fields: { omit: ['password', 'created_at', 'updated_at'] },
            relations: { role: { fields: ['id', 'name'] } },
          }),
          token: token.value!.release(),
        },
      })
    } catch (error) {
      if (error instanceof errors.E_VALIDATION_ERROR) {
        return response.badRequest({
          status: 'error',
          message: 'Validation failed',
          errors: error.messages,
        })
      }

      if (error.code === 'E_ROW_NOT_FOUND') {
        return response.unauthorized({
          status: 'error',
          message: 'Invalid credentials',
        })
      }

      return response.internalServerError({
        status: 'error',
        message: 'Login failed',
        error: error.message,
      })
    }
  }
}
