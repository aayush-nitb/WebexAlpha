express = require 'express'
rfr = require 'rfr'
models = rfr 'models'
router = express.Router()
ObjectID = require('mongoskin').ObjectID
path = require 'path'
walk = require 'walk'
fs = require 'fs'

appRoot = path.resolve "."
login = rfr 'molecules/app-login/services/login'

showList = (res) ->
    molecules = walk.walk appRoot + "/molecules", followLinks:false
    molecules.on 'directories', (root, dirs, next) ->
        res.json
            success: true,
            error: false,
            data: dirs
    return

router.get '/molecule', login.auth, (req, res) ->
    showList res
    return

router.post '/molecule', login.auth, (req, res) ->
    fs.mkdir appRoot + "/molecules/" + req.body.name, (ex) ->
        if ex
            res.json
                success: false,
                error: ex.message
        else
            showList res
    return

router.post '/molecule/:molecule', login.auth, (req, res) ->
    showList res
    return

module.exports = router