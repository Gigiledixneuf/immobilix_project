import { BaseSchema } from '@adonisjs/lucid/schema'

export default class extends BaseSchema {
  protected tableName = 'invites'

  async up() {
    this.schema.createTable(this.tableName, (table) => {
      table.increments('id')
      table
        .integer('landlord_id')
        .unsigned()
        .notNullable()
        .references('id')
        .inTable('users')
        .onDelete('CASCADE')
      table
        .integer('property_id')
        .unsigned()
        .nullable()
        .references('id')
        .inTable('properties')
        .onDelete('SET NULL')
      table.string('contact').notNullable() // email ou téléphone
      table.string('code').notNullable().unique()
      table.enum('status', ['pending', 'accepted', 'cancelled']).defaultTo('pending')
      table.timestamps(true, true)
    })
  }

  async down() {
    this.schema.dropTable(this.tableName)
  }
}




