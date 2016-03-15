express = require 'express'
rfr = require 'rfr'
models = rfr 'models'
router = express.Router()
ObjectID = require('mongoskin').ObjectID
path = require 'path'
walk = require 'walk'

appRoot = path.resolve "."
login = rfr 'molecules/app-login/services/login'

router.get '/molecule', login.auth, (req, res) ->
    molecules = walk.walk appRoot + "/molecules", followLinks:false
    molecules.on 'directories', (root, dirs, next) ->
        res.json dirs
    return

router.post '/molecule', login.auth, (req, res) ->
    res.json [{name:"app-seed"}, {name:"app-login"}]
    return

module.exports = router