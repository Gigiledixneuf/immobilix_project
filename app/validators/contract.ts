import vine from '@vinejs/vine'
import { DateTime } from 'luxon'

/**
 * Transformer pour convertir les Date JS en Luxon DateTime
 */
const toDateTime = (date?: Date) => (date ? DateTime.fromJSDate(date) : undefined)

/**
 * Validator pour la création d'un contrat (version simplifiée)
 */
export const StoreContractValidator = vine.compile(
  vine.object({
    propertyId: vine.number().positive(),
    tenantId: vine.number().positive(),
    startDate: vine
      .date()
      .afterOrEqual(new Date().toISOString().split('T')[0])
      .transform(toDateTime),
    endDate: vine.date().optional().transform(toDateTime),
    description: vine.string().trim().minLength(5),
    rentAmount: vine.number().positive(),
    currency: vine.string().trim().toUpperCase().in(['USD', 'EUR', 'CDF', 'XAF']),
    status: vine.string().trim().toLowerCase().in(['active', 'pending', 'terminated']),
    depositMonths: vine.number().min(0).max(12),
    depositAmount: vine.number().min(0).optional(),
    depositStatus: vine.string().trim().toLowerCase().in(['paid', 'unpaid', 'partial']),
  })
)

/**
 * Validator pour la mise à jour d'un contrat (version simplifiée)
 */
export const UpdateContractValidator = vine.compile(
  vine.object({
    propertyId: vine.number().positive().optional(),
    tenantId: vine.number().positive().optional(),
    startDate: vine.date().optional().transform(toDateTime),
    endDate: vine.date().optional().transform(toDateTime),
    description: vine.string().trim().minLength(5).optional(),
    rentAmount: vine.number().positive().optional(),
    currency: vine.string().trim().toUpperCase().in(['USD', 'EUR', 'CDF', 'XAF']).optional(),
    status: vine.string().trim().toLowerCase().in(['active', 'pending', 'terminated']).optional(),
    depositMonths: vine.number().min(0).max(12).optional(),
    depositAmount: vine.number().min(0).optional(),
    depositStatus: vine.string().trim().toLowerCase().in(['paid', 'unpaid', 'partial']).optional(),
  })
)
