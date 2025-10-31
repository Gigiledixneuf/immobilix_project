import { DateTime } from 'luxon'
import { BaseModel, belongsTo, column } from '@adonisjs/lucid/orm'
import type { BelongsTo } from '@adonisjs/lucid/types/relations'
import User from '#models/user'
import Property from '#models/property'

export enum InviteStatus {
  PENDING = 'pending',
  ACCEPTED = 'accepted',
  CANCELLED = 'cancelled',
}

export default class Invite extends BaseModel {
  @column({ isPrimary: true })
  declare id: number

  @column()
  declare landlordId: number

  @column()
  declare propertyId: number | null

  @column()
  declare contact: string // email ou téléphone

  @column()
  declare code: string

  @column()
  declare status: InviteStatus

  @column.dateTime({ autoCreate: true })
  declare createdAt: DateTime

  @column.dateTime({ autoCreate: true, autoUpdate: true })
  declare updatedAt: DateTime

  @belongsTo(() => User, { foreignKey: 'landlordId' })
  declare landlord: BelongsTo<typeof User>

  @belongsTo(() => Property)
  declare property: BelongsTo<typeof Property>
}




