import vine from '@vinejs/vine'

/**
 * Validation pour l'inscription d'un utilisateur
 */
export const RegisterValidator = vine.compile(
  vine.object({
    full_name: vine.string().trim().maxLength(80).minLength(3),
    email: vine.string().trim().email().unique({ table: 'users', column: 'email' }),
    portable: vine.string().regex(/^[0-9+]{8,15}$/),
    password: vine.string().trim().minLength(8).confirmed(),
    roles: vine.array(vine.enum(['bailleur', 'locataire', 'admin'])).optional(),
  })
)
