express = require 'express'
rfr = require 'rfr'
models = rfr 'models'
router = express.Router()

login = rfr 'molecules/app-login/services/login'

router.get '/getPreferences', login.auth, (req, res) ->
    db = models(req.get 'app-user-preference').db()
    db.find(user: login.user()).toArray (err, result) ->
        res.json result
    return

module.exports = router