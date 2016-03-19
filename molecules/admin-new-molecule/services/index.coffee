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
    fs.writeFile file, data, (err) ->
        if err
            res.json
                success: false,
                error: err
        else
            next res
    return

_layout = (molecule) ->
    layout = 'link(rel="import", href="/bower_components/polymer/polymer.html")\n'
    layout += 'block molecules\n\n'
    layout += 'dom-module#' + molecule.name + '\n'
    layout += molecule.indent + 'template\n'
    layout += molecule.indent + molecule.indent + 'block css\n'
    layout += molecule.indent + molecule.indent + 'block content\n'
    layout += molecule.indent + 'block js'

_index = (molecule) ->
    index = 'extends layout\n\n'
    index += 'block css\n'
    index += molecule.indent + 'style.\n'
    index += molecule.indent + molecule.indent + ':host{display:block;}\n\n'
    index += 'block js\n'
    index += molecule.indent + 'script(src="#{url(\'controllers/script.coffee\')}")\n\n'
    index += 'block molecules\n\n'
    index += 'block content'

_script = (molecule) ->
    script = 'Polymer\n' + molecule.indent + 'is: "' + molecule.name + '"'

_meta = (molecule) ->
    meta = '{\n'
    meta += molecule.indent + '"name": "' + molecule.name + '",\n'
    meta += molecule.indent + '"version": "' + molecule.version + '",\n'
    meta += molecule.indent + '"description": "' + molecule.description + '",\n'
    meta += molecule.indent + '"author": "' + molecule.author + '",\n'
    meta += molecule.indent + '"dependencies": {},\n'
    meta += molecule.indent + '"attrs": {},\n'
    meta += molecule.indent + '"events": {},\n'
    meta += molecule.indent + '"methods": {},\n'
    meta += molecule.indent + '"middlewares": {},\n'
    meta += molecule.indent + '"model": {},\n'
    meta += molecule.indent + '"services": []\n'
    meta += '}'

router.get '/molecule', login.auth, (req, res) ->
    _showList res
    return

router.post '/molecule', login.auth, (req, res) ->
    if not req.body.name.match("[A-Za-z]+.*-.+")
        res.json
            success: false,
            error: "Molecule name must be in format of appname-something"
        return
    moleculeRoot = appRoot + "/molecules/" + req.body.name
    _mkdir moleculeRoot, res, (res) ->
        _mkdir moleculeRoot + '/views', res, (res) ->
            _mkdir moleculeRoot + '/controllers', res, (res) ->
                _write moleculeRoot + '/views/layout.jade', _layout(req.body), res, (res) ->
                    _write moleculeRoot + '/views/index.jade', _index(req.body), res, (res) ->
                        _write moleculeRoot + '/controllers/script.coffee', _script(req.body), res, (res) ->
                            _write moleculeRoot + '/molecule.json', _meta(req.body), res, _showList
    return

router.post '/molecule/:molecule', login.auth, (req, res) ->
    _showList res
    return

module.exports = router