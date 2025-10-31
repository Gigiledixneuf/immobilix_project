import { BaseSeeder } from '@adonisjs/lucid/seeders'
import Contract from '#models/contract'
import Property from '#models/property'
import User from '#models/user'
import { DateTime } from 'luxon'
import Role from '#models/role'
import { ModelQueryBuilderContract } from '@adonisjs/lucid/types/model'

export default class ContractSeeder extends BaseSeeder {
  public async run() {
    console.log('🌱 Seeding contracts...')

    try {
      // --- 1️⃣ Get properties with their owners
      const properties = await Property.query()
      console.log(`📊 Found ${properties.length} properties`)

      // --- 2️⃣ Get tenants
      const tenants = await User.query().whereHas(
        'roles',
        (roleQuery: ModelQueryBuilderContract<typeof Role>) => {
          roleQuery.where('name', 'locataire')
        }
      )
      console.log(`👥 Found ${tenants.length} tenants`)

      if (properties.length === 0 || tenants.length === 0) {
        console.warn('⚠️ Not enough properties or tenants. Run previous seeders first.')
        return
      }

      // --- 3️⃣ Utility function to create a contract
      const createContract = async (property: Property, tenant: User, months: number = 6) => {
        const rentAmount = property.price
        const depositAmount = rentAmount * 2

        console.log(`🔄 Creating contract for property ${property.id}, tenant ${tenant.id}`)

        const contractData = {
          propertyId: property.id,
          tenantId: tenant.id,
          startDate: DateTime.now(),
          endDate: DateTime.now().plus({ months }),
          description: `Rental contract for property "${property.name}" located in ${property.city}.`,
          rentAmount: rentAmount,
          currency: 'USD',
          status: 'active',
          depositMonths: 2,
          depositAmount: depositAmount,
          depositStatus: 'paid',
        }

        console.log('📝 Contract data:', contractData)

        const contract = await Contract.create(contractData)
        console.log(`✅ Contract created with ID: ${contract.id}`)
        return contract
      }

      // --- 4️⃣ Generate contracts
      const contracts: Contract[] = []
      const maxContracts = Math.min(5, properties.length, tenants.length)

      for (let i = 0; i < maxContracts; i++) {
        const property = properties[i % properties.length]
        const tenant = tenants[i % tenants.length]

        const contract = await createContract(property, tenant)
        contracts.push(contract)
      }

      console.log(`🎉 ${contracts.length} contracts created successfully.`)
    } catch (error) {
      console.error('❌ Error seeding contracts:', error)
    }
  }
}
