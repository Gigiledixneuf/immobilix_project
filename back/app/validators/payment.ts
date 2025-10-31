import vine from '@vinejs/vine'
import { Currencies } from '#models/contract'
import { PaymentMethods } from '#models/payment'

export const PayDepositValidator = vine.compile(
  vine.object({
    paymentMethod: vine.enum(['HBAR', 'USDC', 'MOBILE_MONEY']),
    amount: vine.number().positive().optional(),
  })
)

export const StorePaymentValidator = vine.compile(
  vine.object({
    contractId: vine.number().positive(),
    amount: vine.number().positive(),
    currency: vine.enum(Object.values(Currencies)),
    paymentMethod: vine.enum(Object.values(PaymentMethods)),
  })
)
