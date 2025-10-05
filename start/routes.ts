/*
|--------------------------------------------------------------------------
| Routes file
|--------------------------------------------------------------------------
|
| The routes file is used for defining the HTTP routes.
|
*/

import router from '@adonisjs/core/services/router'
import LoginController from '#controllers/Auth/login_controller'

router.get('/', async () => {
  return {
    hello: 'world',
  }
})

// Routes publiques (guest)
router
  .group(() => {
    router.post('login', [LoginController, 'login'])
  })
  .prefix('/api')
