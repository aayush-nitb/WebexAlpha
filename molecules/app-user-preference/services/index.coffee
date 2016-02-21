express = require 'express'
rfr = require 'rfr'
models = rfr 'models'
router = express.Router()

login = rfr 'molecules/app-login/services/login'

router.get '/getPreferences', login.auth, (req, res) ->
    models(req).db().find {user: login.user()}, (err, records) ->
        res.json records
    return

module.exports = router