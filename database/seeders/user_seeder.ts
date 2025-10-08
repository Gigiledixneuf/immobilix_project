import { BaseSeeder } from '@adonisjs/lucid/seeders'
import Role from '#models/role'
import User from '#models/user'
import hash from '@adonisjs/core/services/hash'

export default class extends BaseSeeder {
  async run() {
    // Write your database queries inside the run method
    console.log('🌱 Seeding test users...')

    // --- 1️⃣ Récupération des rôles déjà existants
    const roles = await Role.query()
    const roleMap = Object.fromEntries(roles.map((r) => [r.name, r.id]))

    if (!roleMap.admin || !roleMap.bailleur || !roleMap.locataire) {
      console.warn('⚠️ Certains rôles manquent. Exécute d’abord le RoleSeeder.')
      return
    }

    // --- 2️⃣ Fonction utilitaire pour créer un utilisateur + hash mot de passe
    const createUser = async (
      fullName: string,
      email: string,
      portable: string,
      plainPassword: string
    ) => {
      return await User.create({
        fullName,
        email,
        portable,
        password: await hash.use('scrypt').make(plainPassword),
      })
    }

    // --- 3️⃣ Création des utilisateurs

    // 👑 Admin
    const admin = await createUser('Admin User', 'admin@example.com', '0600000000', 'password123')
    // @ts-ignore
    await admin.related('roles').attach([roleMap.admin])

    // 🧑‍💼 Bailleur1
    const bailleur1 = await createUser(
      'Well Monga',
      'bailleur1@example.com',
      '0611111111',
      'password'
    )
    // @ts-ignore
    await bailleur1.related('roles').attach([roleMap.bailleur])

    // 🧑‍💼 Bailleur2
    const bailleur2 = await createUser(
      'Adeline Kayeya',
      'bailleur2@example.com',
      '0611111111',
      'password'
    )
    // @ts-ignore
    await bailleur2.related('roles').attach([roleMap.bailleur])

    // 👩‍💻 Locataire
    const locataire = await createUser(
      'Zoukoumayzeee',
      'locataire1@example.com',
      '0622222222',
      'password'
    )
    // @ts-ignore
    await locataire.related('roles').attach([roleMap.locataire])

    const locataire2 = await createUser(
      'Kaki Santana',
      'locataire2@example.com',
      '0622222222',
      'password'
    )
    // @ts-ignore
    await locataire2.related('roles').attach([roleMap.locataire])

    // 👥 User mixte (bailleur + locataire)
    const multi = await createUser('Thomas Koffi', 'multi@example.com', '0633333333', 'password')
    // @ts-ignore
    await multi.related('roles').attach([roleMap.bailleur, roleMap.locataire])

    console.log('✅ Users seeded successfully.')
  }
}
