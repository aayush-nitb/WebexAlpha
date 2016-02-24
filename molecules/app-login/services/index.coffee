express = require 'express'
basicAuth = require 'basic-auth'
rfr = require 'rfr'
mongo = require 'mongoskin'
login = require './login'
models = rfr 'models'

router = express.Router()

router.get '/test', login.auth, (req, res) ->
    res.json
        success: true
        error: false
    return

router.get '/logout', login.auth, (req, res) ->
    db = models(req.get 'app-login').db()
    db.update {'user': login.user()}
      , $set:
          'token': ''
      , (err, records) ->
          if records then res.sendStatus 200 else res.sendStatus 417
    return

module.exports = router