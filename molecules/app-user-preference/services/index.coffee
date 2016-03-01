express = require 'express'
rfr = require 'rfr'
models = rfr 'models'
router = express.Router()

login = rfr 'molecules/app-login/services/login'

router.get '/preferences', login.auth, (req, res) ->
    db = models(req.get 'app-user-preference').db()
    db.find(user: login.user()).toArray (err, result) ->
        res.json result
    return

router.post '/preferences', login.auth, (req, res) ->
    db = models(req.get 'app-user-preference').db()
    db.insert {
        user: login.user()
        preference: req.body.preference
    }, (err, result) ->
        db.find(user: login.user()).toArray (err, result) ->
            res.json result
    return

module.exports = router