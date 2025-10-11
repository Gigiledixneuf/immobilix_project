import vine from '@vinejs/vine'

export const PropertyValidator = vine.compile(
  vine.object({
    name: vine
      .string()
      .trim()
      .maxLength(80)
      .minLength(3)
      .unique({ table: 'properties', column: 'name' }),
    address: vine.string().trim().minLength(5),
    city: vine.string().trim().minLength(2),
    type: vine.enum(['house', 'apartment', 'studio', 'room']),
    surface: vine.number().positive(),
    rooms: vine.number().positive(),
    capacity: vine.number().positive(),
    price: vine.number().positive(),
    description: vine.string().trim().minLength(5).optional(),
    main_photo_url: vine
      .file({
        size: '10mb',
        extnames: ['jpg', 'jpeg', 'png', 'webp'],
      })
      .optional(),
  })
)
