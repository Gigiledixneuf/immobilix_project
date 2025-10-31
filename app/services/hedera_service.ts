// app/Services/HederaService.ts
import {
  Client,
  ContractId,
  ContractExecuteTransaction,
  ContractFunctionParameters,
  PrivateKey,
} from '@hashgraph/sdk'
import { DateTime } from 'luxon'

// ⚠️ Assurez-vous d'avoir ces variables définies dans votre fichier .env

/**
 * Interface pour les données utilisées lors de la création d'un contrat sur la chaîne
 */
export interface HederaContractData {
  contractId: number // ID du contrat DB
  landlordId: number // ID du bailleur DB
  tenantId: number // ID du locataire DB
  endDate: DateTime | null // Date de fin (peut être null)
  rentAmount: number // Montant du loyer
  currency: string
  status: string
  depositMonths: number
  depositAmount: number | null
  depositStatus: string
}

/**
 * Interface pour les données de mise à jour du contrat
 */
export interface HederaContractUpdateData {
  newEndDate?: DateTime | null
  newStatus?: string
  // Ajoutez d'autres champs à mettre à jour
}

/**
 * Service pour interagir avec le réseau Hedera (Smart Contracts)
 */
export default class HederaService {
  private client: Client
  private operatorKey: PrivateKey

  // 💡 L'ID du Smart Contract principal (MASTER_CONTRACT_ID est maintenant utilisé pour la création)
  private readonly MASTER_CONTRACT_ID = process.env.HEDERA_MASTER_CONTRACT_ID!

  constructor() {
    // Vérification de base des variables d'environnement
    if (
      !process.env.HEDERA_ACCOUNT_ID ||
      !process.env.HEDERA_PRIVATE_KEY ||
      !this.MASTER_CONTRACT_ID
    ) {
      throw new Error(
        'Les identifiants Hedera (HEDERA_ACCOUNT_ID/PRIVATE_KEY) ou HEDERA_MASTER_CONTRACT_ID doivent être configurés dans .env'
      )
    }

    // --- Configuration de la clé privée avec gestion du format ---
    const operatorId = process.env.HEDERA_ACCOUNT_ID
    let cleanedKey = process.env.HEDERA_PRIVATE_KEY.replace(/\s/g, '').trim()
    if (cleanedKey.startsWith('0x')) {
      cleanedKey = cleanedKey.substring(2)
    }

    // Nous assumons que la clé est de type ECDSA (basé sur la résolution de l'erreur précédente)
    // NOTE : Le SDK préfère les méthodes spécifiques pour le format HEX
    // Vous pouvez remplacer par PrivateKey.fromString(cleanedKey) si vous revenez à un format standard.
    try {
      this.operatorKey = PrivateKey.fromStringECDSA(cleanedKey)
    } catch (e) {
      console.warn('Échec du chargement de la clé en ECDSA. Tentative en format général.')
      this.operatorKey = PrivateKey.fromString(cleanedKey)
    }

    // Définir le réseau (Testnet, Mainnet, etc.)
    this.client = Client.forTestnet().setOperator(operatorId, this.operatorKey) // 💡 Remplacez par Client.forMainnet() pour la production

    // Augmenter le timeout pour la résilience
    this.client.setRequestTimeout(30 * 1000)

    console.log(`HederaService initialisé. Master Contract ID: ${this.MASTER_CONTRACT_ID}`)
  }

  /**
   * Crée un nouveau bail en appelant la fonction 'createNewLease' du Master Contract.
   * Cette méthode utilise ContractExecuteTransaction sur le MASTER_CONTRACT_ID.
   * @param data Les données du contrat à enregistrer.
   * @returns L'ID du Master Contract (ou l'ID unique si votre Master Contract en retourne un).
   */
  public async createContratOnChain(data: HederaContractData): Promise<string> {

    const contractIdObject = ContractId.fromString(this.MASTER_CONTRACT_ID)
    const functionName = 'createNewLease' // ⚠️ Assurez-vous que cette fonction existe dans votre Smart Contract

    // 1. Définir les paramètres pour la fonction de création
    const parameters = new ContractFunctionParameters()
      .addInt64(data.contractId) // ID DB
      .addInt64(data.landlordId)
      .addInt64(data.tenantId)
      // Conversion de la date de fin en secondes Unix (0 si null)
      .addInt64(data.endDate ? data.endDate.toSeconds() : 0)
      // NOTE: Si votre contrat utilise uint256/int256, vous devez utiliser BigNumber
      .addUint256(data.rentAmount)
      .addString(data.currency)
      .addString(data.status)
      .addInt64(data.depositMonths)
      .addUint256(data.depositAmount || 0)
      .addString(data.depositStatus)

    console.log(
      `Tentative de création du bail Hedera via Master Contract ID: ${this.MASTER_CONTRACT_ID}`
    )

    // 2. Exécuter la transaction sur le Master Contract
    // 💡 Gaz augmenté pour les appels qui modifient l'état du contrat (écriture)
    const tx = await new ContractExecuteTransaction()
      .setContractId(contractIdObject)
      .setGas(500000) // 500k devrait suffire pour une exécution de fonction
      .setFunction(functionName, parameters)
      // 💡 Optionnel : Définir le montant de Hbar à attacher à l'appel (pour payer le dépôt ou des frais)
      // Nous ne payons pas de montant ici, nous laissons le frais de transaction standard.
      // .setPayableAmount(new Hbar(0))
      .execute(this.client)

    const receipt = await tx.getReceipt(this.client)

    if (receipt.status.toString() !== 'SUCCESS') {
      // Ajout de l'erreur détaillée pour un meilleur diagnostic
      throw new Error(
        `Échec de la création du bail Hedera. Statut: ${receipt.status.toString()}. Consultez le statut de la transaction pour plus de détails.`
      )
    }

    console.log(`✅ Bail créé avec succès. Transaction ID: ${tx.transactionId.toString()}`)
    // Retourne l'ID du Master Contract comme référence (ou l'ID du nouveau contrat si retourné par Solidity)
    return this.MASTER_CONTRACT_ID
  }

  // NOTE: La fonction updateContractOnChain reste la même pour l'instant.
  // Vous pouvez ajouter une gestion d'erreur plus robuste ici aussi si nécessaire.
  public async updateContractOnChain(
    hederaContractId: string,
    updates: HederaContractUpdateData
  ): Promise<void> {
    const contractIdObject = ContractId.fromString(hederaContractId)
    let transactionExecuted = false

    // 1. Mise à jour de la date de fin
    if (updates.newEndDate !== undefined) {
      const functionName = 'updateEndDate'
      const newEndDateInSeconds = updates.newEndDate ? updates.newEndDate.toSeconds() : 0

      const parameters = new ContractFunctionParameters().addInt64(newEndDateInSeconds)

      const tx = await new ContractExecuteTransaction()
        .setContractId(contractIdObject)
        .setGas(100000)
        .setFunction(functionName, parameters)
        .execute(this.client)

      const receipt = await tx.getReceipt(this.client)

      if (receipt.status.toString() !== 'SUCCESS') {
        throw new Error(
          `Échec de la mise à jour de la date de fin Hedera: ${receipt.status.toString()}`
        )
      }
      console.log(`Contrat Hedera ${hederaContractId} mis à jour (Date de fin).`)
      transactionExecuted = true
    }

    // 2. Mise à jour du statut
    if (updates.newStatus !== undefined) {
      const functionName = 'updateStatus'

      const parameters = new ContractFunctionParameters().addString(updates.newStatus)

      const tx = await new ContractExecuteTransaction()
        .setContractId(contractIdObject)
        .setGas(100000)
        .setFunction(functionName, parameters)
        .execute(this.client)

      const receipt = await tx.getReceipt(this.client)

      if (receipt.status.toString() !== 'SUCCESS') {
        throw new Error(`Échec de la mise à jour du statut Hedera: ${receipt.status.toString()}`)
      }
      console.log(
        `Contrat Hedera ${hederaContractId} mis à jour (Nouveau statut: ${updates.newStatus}).`
      )
      transactionExecuted = true
    }

    if (!transactionExecuted) {
      console.log(`Aucun champ à mettre à jour pour le contrat Hedera ${hederaContractId}.`)
    }
  }
}
