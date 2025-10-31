import type { HttpContext } from '@adonisjs/core/http'
import { inject } from '@adonisjs/core'
import HederaService from '#services/hedera_service'
import { StorePaymentValidator } from '#validators/payment'
import Payment, { PaymentMethods, PaymentStatus } from '#models/payment'
import PaymentsService from '#services/payments_service'
import Contract from '#models/contract'

@inject()
export default class PaymentsController {
  constructor(protected hederaService: HederaService, protected paymentsService: PaymentsService = new PaymentsService()) {}

  /**
   * ✅ Effectuer un paiement (déjà existant)
   */
  async store({ request, response }: HttpContext) {
    const payload = await request.validateUsing(StorePaymentValidator)

    const contract = await Contract.find(payload.contractId)
    if (!contract) {
      return response.notFound({ message: 'Contrat introuvable' })
    }

    const payment = await Payment.create({
      ...payload,
      status: PaymentStatus.PENDING,
    })

    // MOBILE MONEY: initier chez l'agrégateur puis attendre le webhook
    if (payment.paymentMethod === PaymentMethods.MOBILE_MONEY) {
      const ref = `IMMOBX-${payment.id}-${Date.now()}`
      const init = await this.paymentsService.initiateMobileMoneyPayment({
        amount: payment.amount,
        currency: contract.currency,
        reference: ref,
      })
      payment.transactionId = init.providerReference ?? ref
      await payment.save()
      return response.created({ message: 'Paiement Mobile Money initié', data: { payment, checkoutUrl: init.checkoutUrl } })
    }

    // HBAR/USDC: paiement on-chain immédiat
    try {
      // S'assurer que le bail existe on-chain sinon le créer (sinon revert: Lease not found)
      if (!contract.hederaContractId) {
        const property = await contract.related('property').query().first()
        const endDate = contract.endDate
        const hederaData = {
          contractId: contract.id,
          landlordId: property ? property.user_id : 0,
          tenantId: contract.tenantId,
          endDate: endDate || null,
          rentAmount: contract.rentAmount,
          currency: contract.currency,
          status: contract.status,
          depositMonths: contract.depositMonths || 0,
          depositAmount: contract.depositAmount || 0,
          depositStatus: contract.depositStatus || 'pending',
        }
        try {
          const hederaContratId = await this.hederaService.createContratOnChain(hederaData as any)
          contract.hederaContractId = hederaContratId
          await contract.save()
        } catch (e) {
          console.error('Hedera create lease failed', e)
          // on continue vers paiement, mais Hedera refusera si le lease n existe pas
        }
      }

      const transactionId = await this.hederaService.makePaymentOnChain({
        dbContractId: contract.id,
        paymentId: payment.id,
        amount: Math.round(Number(payment.amount)),
        paymentMethod: payment.paymentMethod,
      })

      payment.transactionId = transactionId
      payment.status = PaymentStatus.PAID
      await payment.save()

      return response.created({
        message: 'Paiement effectué avec succès',
        data: payment,
      })
    } catch (error) {
      payment.status = PaymentStatus.FAILED
      await payment.save()
      console.error('Erreur lors du paiement Hedera:', error)
      return response.badRequest({ message: 'Paiement Hedera refusé', error: String(error) })
    }
  }

  /**
   * 🧾 Afficher l’historique des paiements d’un contrat
   */
  async history({ params, request, response }: HttpContext) {
    const contractId = params.id

    const contract = await Contract.find(contractId)
    if (!contract) {
      return response.notFound({ message: 'Contrat introuvable' })
    }

    // 🔹 Pagination et filtres optionnels
    const page = request.input('page', 1)
    const limit = request.input('limit', 10)
    const status = request.input('status')

    const query = Payment.query()
      .where('contract_id', contractId)
      .orderBy('created_at', 'desc')

    if (status) {
      query.andWhere('status', status)
    }

    const payments = await query.paginate(page, limit)

    return response.ok({
      message: 'Historique des paiements récupéré avec succès',
      data: payments,
    })
  }
}
