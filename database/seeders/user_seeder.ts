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

    // 🧑‍💼 Bailleur
    const bailleur = await createUser(
      'Jean Dupont',
      'bailleur@example.com',
      '0611111111',
      'password123'
    )
    // @ts-ignore
    await bailleur.related('roles').attach([roleMap.bailleur])

    // 👩‍💻 Locataire
    const locataire = await createUser(
      'Marie Diallo',
      'locataire@example.com',
      '0622222222',
      'password123'
    )
    // @ts-ignore
    await locataire.related('roles').attach([roleMap.locataire])

    // 👥 User mixte (bailleur + locataire)
    const multi = await createUser('Thomas Koffi', 'multi@example.com', '0633333333', 'password123')
    // @ts-ignore
    await multi.related('roles').attach([roleMap.bailleur, roleMap.locataire])

    console.log('✅ Users seeded successfully.')
  }
}
