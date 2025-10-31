const WebhooksController = () => import('#controllers/webhooks_controller')
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
const ContractsController = () => import('#controllers/contracts_controller')
const PaymentsController = () => import('#controllers/payments_controller')
const PropertiesController = () => import('#controllers/Bailleur/properties_controller')
const ApplicationsController = () => import('#controllers/applications_controller')
const InvitesController = () => import('#controllers/invites_controller')
//const PublicPropertiesController = () => import('#controllers/Public/properties_controller')
const ProfilesController = () => import('#controllers/profiles_controller')
const AdminUsersController = () => import('#controllers/Admin/users_controller')
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
    router.get('/tenants', [PropertiesController, 'listTenants'])
    router.get('/properties/:id/applications', [ApplicationsController, 'index'])
    router.patch('/applications/:id/accept', [ApplicationsController, 'accept'])
    router.patch('/applications/:id/reject', [ApplicationsController, 'reject'])
    router.post('/applications/:id/create-contract', [ApplicationsController, 'createContract'])
    // Alias POST pour compat frontend
    router.post('/applications/:id/accept', [ApplicationsController, 'accept'])
    router.post('/applications/:id/reject', [ApplicationsController, 'reject'])
    router.resource('/contracts', ContractsController)
    router.post('/contracts/:id/pay-deposit', [ContractsController, 'payDeposit'])
    router.post('/properties/:id/apply', [ApplicationsController, 'apply'])
    router.get('/profile', [ProfilesController, 'show'])
    router.put('/profile', [ProfilesController, 'update'])
    router.post('/payments', [PaymentsController, 'store'])
    router.get('/contracts/:id/payments', [PaymentsController, 'history'])
    router.post('/invites', [InvitesController, 'store'])
  })
  .prefix('/api')
  .middleware([middleware.auth()])

// Routes d'administration
router
  .group(() => {
    router.resource('/users', AdminUsersController).only(['index', 'show', 'update'])
  })
  .prefix('/api/admin')
  .middleware([middleware.auth()])

// Routes publiques (guest)
router
  .group(() => {
    router.post('login', [LoginController, 'login'])
    router.post('register', [RegistersController, 'register'])
    // router.get('public/properties', [PublicPropertiesController, 'index'])
    router.post('webhook/payment', [WebhooksController, 'payment'])
  })
  .prefix('/api')
