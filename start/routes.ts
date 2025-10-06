/*
|--------------------------------------------------------------------------
| Routes file
|--------------------------------------------------------------------------
|
| The routes file is used for defining the HTTP routes.
|
*/

import router from '@adonisjs/core/services/router'
const LoginController = () => import('#controllers/Auth/login_controller')
const RegistersController = () => import('#controllers/Auth/registers_controller')

router.get('/', async () => {
  return {
    hello: 'world',
  }
})

// Routes publiques (guest)
router
  .group(() => {
    router.post('login', [LoginController, 'login'])
    router.post('register', [RegistersController, 'register'])
  })
  .prefix('/api')
