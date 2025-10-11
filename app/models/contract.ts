import { DateTime } from 'luxon'
import { BaseModel, belongsTo, column } from '@adonisjs/lucid/orm'
import Property from '#models/property'
import type { BelongsTo } from '@adonisjs/lucid/types/relations'
import User from '#models/user'

export default class Contract extends BaseModel {
  @column({ isPrimary: true })
  declare id: number

  @column()
  declare propertyId: number

  @column()
  declare tenantId: number

  @column.date()
  declare startDate: DateTime

  @column.date()
  declare endDate: DateTime | null

  @column()
  declare description: string | null

  @column()
  declare rentAmount: number

  @column()
  declare currency: string

  @column()
  declare status: string

  // New security deposit fields
  @column()
  declare depositMonths: number

  @column()
  declare depositAmount: number | null

  @column()
  declare depositStatus: string

  @column.dateTime({ autoCreate: true })
  declare createdAt: DateTime

  @column.dateTime({ autoCreate: true, autoUpdate: true })
  declare updatedAt: DateTime

  // 🔗 Relations

  // A contract belongs to a property
  @belongsTo(() => Property)
  declare property: BelongsTo<typeof Property>

  // A contract belongs to a tenant (user)
  @belongsTo(() => User)
  declare tenant: BelongsTo<typeof User>
}
