import { DateTime } from 'luxon'
import { BaseModel, belongsTo, column } from '@adonisjs/lucid/orm'
import type { BelongsTo } from '@adonisjs/lucid/types/relations'
import Contract, { Currencies } from './contract.js'

export enum PaymentMethods {
  HBAR = 'HBAR',
  USDC = 'USDC',
  MOBILE_MONEY = 'MOBILE_MONEY',
}

export enum PaymentStatus {
  PENDING = 'pending',
  PAID = 'paid',
  FAILED = 'failed',
}

export default class Payment extends BaseModel {
  @column({ isPrimary: true })
  declare id: number

  @column()
  declare contractId: number

  @column()
  declare amount: number

  @column()
  declare currency: Currencies

  @column()
  declare paymentMethod: PaymentMethods

  @column()
  declare transactionId: string

  @column()
  declare status: PaymentStatus

  @column.dateTime({ autoCreate: true })
  declare createdAt: DateTime

  @column.dateTime({ autoCreate: true, autoUpdate: true })
  declare updatedAt: DateTime

  @belongsTo(() => Contract)
  declare contract: BelongsTo<typeof Contract>
}
