import type { HttpContext } from '@adonisjs/core/http'
import PaymentsService, { WebhookPayload } from '#services/payments_service'
import Payment, { PaymentStatus } from '#models/payment'
import NotificationsService from '#services/notifications_service'
import FlutterwaveProvider from '#services/mobile_money/flutterwave_provider'

export default class WebhooksController {
  constructor(protected paymentsService: PaymentsService = new PaymentsService()) {}

  /**
   * POST /api/webhook/payment
   * Réception du webhook de paiement Mobile Money / agrégateur
   */
  async payment({ request, response }: HttpContext) {
    const body = request.all() as WebhookPayload & { paymentId?: number }

    // Vérification signature Flutterwave si header présent
    const flwSig = request.header('verif-hash')
    if (flwSig) {
      const flw = new FlutterwaveProvider()
      const ok = flw.verifyWebhookSignature(flwSig)
      if (!ok) {
        return response.unauthorized({ message: 'Signature webhook invalide' })
      }
    }

    // Identification du paiement (id interne ou référence/tx)
    let payment: Payment | null = null
    if (body.paymentId) {
      payment = await Payment.find(body.paymentId)
    }
    if (!payment && body.transactionId) {
      payment = await Payment.query().where('transaction_id', body.transactionId).first()
    }
    if (!payment && body.reference) {
      payment = await Payment.query().where('transaction_id', body.reference).first()
    }
    if (!payment) {
      return response.notFound({ message: 'Paiement introuvable' })
    }

    const result = await this.paymentsService.verifyPayment(body)
    if (!result.valid) {
      payment.status = PaymentStatus.FAILED
      await payment.save()
      return response.ok({ message: 'Paiement non valide', data: payment })
    }

    if (result.txid) payment.transactionId = result.txid
    payment.status = PaymentStatus.PAID
    await payment.save()

    // Notifier le bailleur/locataire (simplifié: notifie le locataire via logs)
    const notifier = new NotificationsService()
    await notifier.notifyUser(payment.contractId, 'Paiement confirmé', 'Votre paiement a été confirmé', {
      paymentId: payment.id,
    })

    return response.ok({ message: 'Paiement confirmé', data: payment })
  }
}


