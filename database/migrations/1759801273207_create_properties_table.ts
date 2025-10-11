import { BaseSchema } from '@adonisjs/lucid/schema'

export default class extends BaseSchema {
  protected tableName = 'properties'

  async up() {
    this.schema.createTable(this.tableName, (table) => {
      table.increments('id')

      // Relation avec l'utilisateur (bailleur)
      table
        .integer('user_id')
        .unsigned()
        .notNullable()
        .references('id')
        .inTable('users')
        .onDelete('CASCADE')

      // Informations de base
      table.string('name', 191).notNullable().unique()
      table.text('description').nullable()

      // Localisation
      table.string('address').notNullable()
      table.string('city').notNullable()

      // Caractéristiques du logement
      table.enu('type', ['house', 'apartment', 'studio', 'room']).notNullable()
      table.integer('surface').unsigned().notNullable() // m²
      table.integer('rooms').unsigned().notNullable() // nombre de pièces
      table.integer('capacity').unsigned().notNullable() // capacité max (personnes)
      table.decimal('price', 10, 2).notNullable() // prix du loyer

      // Image principale
      table.string('main_photo_url').nullable()

      // Dates automatiques
      table.timestamp('created_at', { useTz: true })
      table.timestamp('updated_at', { useTz: true })
    })
  }

  async down() {
    this.schema.dropTable(this.tableName)
  }
}
