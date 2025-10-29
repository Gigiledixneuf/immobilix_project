import { BaseSchema } from '@adonisjs/lucid/schema'

// Le nom de la classe et du fichier de migration est bon pour indiquer l'action
export default class AddHederaContractIdToContracts extends BaseSchema {
  // Nous ciblons la table qui doit être modifiée
  protected tableName = 'contracts'

  async up() {
    this.schema.alterTable(this.tableName, (table) => {
      // 🎯 C'est la seule ligne qui est nécessaire dans la méthode up()
      table
        .string('hedera_contract_id')
        .nullable()
        .unique() // L'ID doit être unique s'il référence un Smart Contract
        .comment('ID du Smart Contract Hedera')
        .after('deposit_status') // Optionnel, pour un meilleur ordre des colonnes
    })
  }

  async down() {
    this.schema.alterTable(this.tableName, (table) => {
      // Pour annuler, nous retirons la colonne
      table.dropColumn('hedera_contract_id')
    })
  }
}
