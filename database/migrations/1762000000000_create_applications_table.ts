import { BaseSchema } from '@adonisjs/lucid/schema'

export default class extends BaseSchema {
  protected tableName = 'applications'

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
      table.text('message').nullable()
      table
        .enum('status', ['pending', 'accepted', 'rejected'])
        .defaultTo('pending')
      table.timestamps(true, true)
    })
  }

  async down() {
    this.schema.dropTable(this.tableName)
  }
}




