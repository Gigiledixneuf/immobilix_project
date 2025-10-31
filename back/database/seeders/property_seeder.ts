import { BaseSeeder } from '@adonisjs/lucid/seeders'
import Property from '#models/property'
import User from '#models/user'

export default class PropertySeeder extends BaseSeeder {
  public async run() {
    // Récupérer tous les users qui ont le rôle "bailleur"
    const bailleurs = await User.query().whereHas('roles', (query) => {
      // @ts-ignore
      query.where('name', 'bailleur')
    })

    if (bailleurs.length === 0) {
      console.warn('Aucun bailleur trouvé, impossible de créer des propriétés.')
      return
    }

    // Créer 5 logements avec un bailleur aléatoire
    const propertiesData = [
      {
        name: 'Charmant studio au centre-ville',
        address: '12 rue de la République',
        city: 'Paris',
        type: 'studio',
        surface: 28,
        rooms: 1,
        capacity: 1,
        price: 850,
        description: 'Studio moderne proche de toutes commodités, idéal pour étudiant.',
        mainPhotoUrl: 'studio_paris.jpg',
      },
      {
        name: 'Appartement T2 lumineux',
        address: '45 avenue Victor Hugo',
        city: 'Lyon',
        type: 'apartment',
        surface: 45,
        rooms: 2,
        capacity: 2,
        price: 1100,
        description: 'Bel appartement avec balcon et vue dégagée, proche métro.',
        mainPhotoUrl: 'appartement_lyon.jpg',
      },
      {
        name: 'Maison familiale avec jardin',
        address: '8 impasse des Lilas',
        city: 'Toulouse',
        type: 'house',
        surface: 120,
        rooms: 5,
        capacity: 6,
        price: 1800,
        description: 'Grande maison avec jardin et garage dans un quartier calme.',
        mainPhotoUrl: 'maison_toulouse.jpg',
      },
      {
        name: 'Loft industriel rénové',
        address: '22 quai du Commerce',
        city: 'Nantes',
        type: 'apartment',
        surface: 70,
        rooms: 3,
        capacity: 3,
        price: 1350,
        description: 'Magnifique loft avec poutres apparentes et grande hauteur sous plafond.',
        mainPhotoUrl: 'loft_nantes.jpg',
      },
      {
        name: 'Studio cosy proche université',
        address: '3 rue Pasteur',
        city: 'Lille',
        type: 'studio',
        surface: 20,
        rooms: 1,
        capacity: 1,
        price: 650,
        description: 'Petit studio meublé parfait pour étudiant ou jeune actif.',
        mainPhotoUrl: 'studio_lille.jpg',
      },
    ]

    for (const property of propertiesData) {
      // Sélection aléatoire d’un bailleur
      const randomBailleur = bailleurs[Math.floor(Math.random() * bailleurs.length)]

      await Property.create({
        ...property,
        user_id: randomBailleur.id,
      })
    }
  }
}
