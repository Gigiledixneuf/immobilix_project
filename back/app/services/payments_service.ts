export interface WebhookPayload {
  provider: 'MOBILE_MONEY' | 'FLUTTERWAVE' | 'OTHER'
  reference?: string
  transactionId?: string
  amount?: number
  currency?: string
  status: 'success' | 'failed' | 'pending'
}

export default class PaymentsService {
  async initiateMobileMoneyPayment(input: {
    amount: number
    currency: string
    reference: string
    customer?: { email?: string; phonenumber?: string; name?: string }
  }): Promise<{ reference: string; providerReference?: string; checkoutUrl?: string }> {
    const { default: FlutterwaveProvider } = await import('./mobile_money/flutterwave_provider.js')
    const flw = new FlutterwaveProvider()
    const res = await flw.initiatePayment({
      amount: input.amount,
      currency: input.currency,
      reference: input.reference,
      customer: input.customer ?? {},
    })
    return res
  }
  /**
   * Vérifie la validité d’un paiement via l’agrégateur Mobile Money
   * et/ou la Mirror Node Hedera (pour crypto). Stub MVP.
   */
  async verifyPayment(payload: WebhookPayload): Promise<{ valid: boolean; txid?: string }> {
    // MVP: on valide si status success; pour Flutterwave, la vérification avancée peut interroger /transactions/verify
    if (payload.status === 'success') {
      return { valid: true, txid: payload.transactionId ?? payload.reference }
    }
    return { valid: false }
  }
}


