import { DateTime } from 'luxon'
import { BaseModel, belongsTo, column } from '@adonisjs/lucid/orm'
import User from '#models/user'
import type { BelongsTo } from '@adonisjs/lucid/types/relations'

export enum PropertyType {
  HOUSE = 'house',
  APARTMENT = 'apartment',
  STUDIO = 'studio',
  ROOM = 'room',
}

export default class Property extends BaseModel {
  @column({ isPrimary: true })
  declare id: number

  @column()
  declare user_id: number

  @column()
  declare name: string

  @column()
  declare address: string

  @column()
  declare city: string

  @column()
  declare type: PropertyType | string

  @column()
  declare surface: number | null

  @column()
  declare rooms: number | null

  @column()
  declare capacity: number

  @column()
  declare price: number

  @column()
  declare description?: string

  @column({ columnName: 'main_photo_url' })
  declare mainPhotoUrl?: string

  @column.dateTime({ autoCreate: true })
  declare createdAt: DateTime

  @column.dateTime({ autoCreate: true, autoUpdate: true })
  declare updatedAt: DateTime

  @belongsTo(() => User)
  declare user: BelongsTo<typeof User>
}
