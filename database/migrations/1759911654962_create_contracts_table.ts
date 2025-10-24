import { BaseSchema } from '@adonisjs/lucid/schema'

export default class extends BaseSchema {
  protected tableName = 'contracts'

  async up() {
    this.schema.createTable(this.tableName, (table) => {
      table.increments('id')
      table
        .integer('property_id')
        .unsigned()
        .notNullable()
        .references('id')
        .inTable('properties')
        .onDelete('CASCADE')

      table
        .integer('tenant_id')
        .unsigned()
        .notNullable()
        .references('id')
        .inTable('users')
        .onDelete('CASCADE')

      // Contract fields
      table.date('start_date').notNullable()
      table.date('end_date').nullable()
      table.text('description').nullable()
      table.decimal('rent_amount', 12, 2).notNullable()
      table.string('currency', 10).defaultTo('USD')
      table.enum('status', ['active', 'terminated', 'suspended']).defaultTo('active')

      // New security deposit fields
      table.integer('deposit_months').unsigned().defaultTo(1)

      table.decimal('deposit_amount', 12, 2).nullable().comment('Total security deposit amount')
      table
        .enum('deposit_status', ['pending', 'paid', 'refunded', 'partially_refunded', 'withheld'])
        .defaultTo('pending')

      // Timestamps
      table.timestamp('created_at', { useTz: true }).defaultTo(this.now())
      table.timestamp('updated_at', { useTz: true }).defaultTo(this.now())
    })
  }

  async down() {
    this.schema.dropTable(this.tableName)
  }
}
