import vine from '@vinejs/vine'
import { uniqueRule } from '#validators/rules/unique'

export const UpdateProfileValidator = vine.compile(
  vine.object({
    fullName: vine.string().maxLength(255).optional(),
    email: vine
      .string()
      .email()
      .use(
        uniqueRule({
          table: 'users',
          column: 'email',
          except: (field: any) => field.meta.userId,
        })
      )
      .optional(),
    password: vine.string().minLength(8).confirmed().optional(),
  })
)
