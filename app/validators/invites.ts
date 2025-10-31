import vine from '@vinejs/vine'

export const CreateInviteValidator = vine.compile(
  vine.object({
    contact: vine.string().trim(), // email ou téléphone (validation spécifique à ajouter si besoin)
    propertyId: vine.number().optional(),
  })
)




