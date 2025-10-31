import { BaseSchema } from '@adonisjs/lucid/schema'
import { Currencies } from '../../app/models/contract.js'
import { PaymentMethods, PaymentStatus } from '../../app/models/payment.js'

export default class extends BaseSchema {
  protected tableName = 'payments'

  async up() {
    this.schema.createTable(this.tableName, (table) => {
      table.increments('id')
      table
        .integer('contract_id')
        .unsigned()
        .references('id')
        .inTable('contracts')
        .onDelete('CASCADE')
      table.decimal('amount', 12, 2).notNullable()
      table.enum('currency', Object.values(Currencies)).defaultTo(Currencies.USD)
      table.enum('payment_method', Object.values(PaymentMethods)).defaultTo(PaymentMethods.HBAR)
      table.string('transaction_id').unique()
      table.enum('status', Object.values(PaymentStatus)).defaultTo(PaymentStatus.PENDING)
      table.timestamps(true, true)
    })
  }

  async down() {
    this.schema.dropTable(this.tableName)
  }
}
