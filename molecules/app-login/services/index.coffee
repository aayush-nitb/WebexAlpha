express = require 'express'
basicAuth = require 'basic-auth'
rfr = require 'rfr'
mongo = require 'mongoskin'
auth = require './login'

router = express.Router()

router.get '/test', auth, (req, res) ->
    res.json
        success: true
        error: false
    return

router.get '/logout', auth, (req, res) ->
    model = rfr req.query.model
    db_auth = if model.db_user is "" then "" else model.db_user + ":" + model.db_pass
    db_url = db_auth + "@" + model.server + "/" + model.db
    db = mongo.db "mongodb://" + db_url, native_parser:true
    user = basicAuth req
    db.collection(model.collection).update {'user':user.name}
      , $set:
          'token': ''
      , (err, records) ->
          if records then res.sendStatus 200 else res.sendStatus 417
    return

module.exports = router