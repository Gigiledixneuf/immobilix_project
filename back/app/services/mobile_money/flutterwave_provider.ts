import 'dotenv/config'

export interface InitiateParams {
  amount: number
  currency: string
  reference: string
  customer: { email?: string; phonenumber?: string; name?: string }
  redirect_url?: string
}

export interface InitiateResult {
  reference: string
  providerReference?: string
  checkoutUrl?: string
}

export default class FlutterwaveProvider {
  private readonly baseUrl = 'https://api.flutterwave.com/v3'
  private readonly secretKey = process.env.FLW_SECRET_KEY
  private readonly webhookHash = process.env.FLW_WEBHOOK_HASH // pour vérification header 'verif-hash'

  private get authHeader() {
    if (!this.secretKey) throw new Error('FLW_SECRET_KEY manquant dans .env')
    return { Authorization: `Bearer ${this.secretKey}`, 'Content-Type': 'application/json' }
  }

  /**
   * Minimal: crée une intention de paiement standard (checkout) pour mobile.
   * Pour un vrai flux Mobile Money, adapter l’endpoint "charges" selon l’opérateur.
   */
  async initiatePayment(params: InitiateParams): Promise<InitiateResult> {
    const body = {
      tx_ref: params.reference,
      amount: params.amount,
      currency: params.currency,
      redirect_url: params.redirect_url,
      customer: params.customer,
      payment_options: 'mobilemoney,card,ussd',
    }

    const res = await fetch(`${this.baseUrl}/payments`, {
      method: 'POST',
      headers: this.authHeader,
      body: JSON.stringify(body),
    })
    const json = (await res.json()) as any
    if (!res.ok) {
      throw new Error(`Flutterwave initiate error: ${json?.message || res.statusText}`)
    }
    return {
      reference: params.reference,
      providerReference: json?.data?.flw_ref,
      checkoutUrl: json?.data?.link,
    }
  }

  /** Vérifie la signature de webhook Flutterwave via header 'verif-hash' */
  verifyWebhookSignature(headerHash?: string): boolean {
    if (!this.webhookHash) return false
    return Boolean(headerHash && headerHash === this.webhookHash)
  }
}




