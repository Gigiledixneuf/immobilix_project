/*
|--------------------------------------------------------------------------
| Routes file
|--------------------------------------------------------------------------
|
| The routes file is used for defining the HTTP routes.
|
*/

import router from '@adonisjs/core/services/router'
import { middleware } from '#start/kernel'
const PropertiesController = () => import('#controllers/Bailleur/properties_controller')
const LoginController = () => import('#controllers/Auth/login_controller')
const RegistersController = () => import('#controllers/Auth/registers_controller')

router.get('/', async () => {
  return {
    hello: 'world',
  }
})

//Routes protégées par authentification
router
  .group(() => {
    router.resource('/properties', PropertiesController)
  })
  .prefix('/api')
  .middleware([middleware.auth()])

// Routes publiques (guest)
router
  .group(() => {
    router.post('login', [LoginController, 'login'])
    router.post('register', [RegistersController, 'register'])
  })
  .prefix('/api')
