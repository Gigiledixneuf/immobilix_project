import vine from '@vinejs/vine'
import db from '@adonisjs/lucid/services/db'

// Define a custom validation rule for uniqueness
export const uniqueRule = vine.createRule(async (value: any, options: { table: string; column: string; except?: any }, field) => {
  const query = db.from(options.table).where(options.column, value)

  if (options.except) {
    query.whereNot('id', options.except)
  }

  const row = await query.first()

  if (row) {
    field.report('The {{ field }} has already been taken.', 'unique', field)
  }
})
