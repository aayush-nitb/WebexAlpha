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

_showList = (res) ->
    molecules = walk.walk appRoot + "/molecules", followLinks:false
    molecules.on 'directories', (root, dirs, next) ->
        res.json
            success: true,
            error: false,
            data: dirs
    return

_mkdir = (path, res, next) ->
    fs.mkdir path, (ex) ->
        if ex
            res.json
                success: false,
                error: ex.message
        else
            next res
    return

_write = (file, data, res, next) ->
    fs.writeFile file, data, (ex) ->
        if ex
            res.json
                success: false,
                error: ex.message
        else
            next res
    return

_layout = (molecule) ->
    layout = 'link(rel="import", href="/bower_components/polymer/polymer.html")\n'
    layout += 'block molecules\n\n'
    layout += 'dom-module#' + molecule.name + '\n'
    layout += '\ttemplate\n'
    layout += '\t\tblock css\n'
    layout += '\t\tblock content\n'
    layout += '\tblock js'

_index = ->
    index = 'extends layout\n\n'
    index += 'block css\n'
    index += '\tstyle.\n'
    index += '\t\t:host{display:block;}\n\n'
    index += 'block js\n'
    index += '\tscript(src="#{url(\'controllers/script.coffee\')}")\n\n'
    index += 'block molecules\n\n'
    index += 'block content'

_script = (molecule) ->
    script = 'Polymer\n\tis: "' + molecule.name + '"'

_meta = (molecule) ->
    meta = '{\n'
    meta += '\t"name": "' + molecule.name + '",\n'
    meta += '\t"version": "' + molecule.version + '",\n'
    meta += '\t"description": "' + molecule.description + '",\n'
    meta += '\t"author": "' + molecule.author + '",\n'
    meta += '\t"dependencies": {},\n'
    meta += '\t"attrs": {},\n'
    meta += '\t"events": {},\n'
    meta += '\t"methods": {},\n'
    meta += '\t"middlewares": {},\n'
    meta += '\t"model": {},\n'
    meta += '\t"services": []\n'
    meta += '}'

router.get '/molecule', login.auth, (req, res) ->
    _showList res
    return

router.post '/molecule', login.auth, (req, res) ->
    moleculeRoot = appRoot + "/molecules/" + req.body.name
    _mkdir moleculeRoot, res, (res) ->
        _mkdir moleculeRoot + '/views', res, (res) ->
            _mkdir moleculeRoot + '/controllers', res, (res) ->
                _write moleculeRoot + '/views/layout.jade', _layout req.body, res, (res) ->
                    _write moleculeRoot + '/views/index.jade', _index(), res, (res) ->
                        _write moleculeRoot + '/controllers/script.coffee', _script req.body, res, (res) ->
                            _write moleculeRoot + '/molecule.json', _meta req.body, res, _showList
    return

router.post '/molecule/:molecule', login.auth, (req, res) ->
    _showList res
    return

module.exports = router