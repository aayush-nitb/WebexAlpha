path = require 'path'

appRoot = path.resolve "."
getURL = undefined

mainIndex = (req, res) ->
  res.render 'main/views/index',
    title: 'WebExpress'
    url: getURL.bind(base: 'main')
  return

mainImages = (req, res) ->
  res.sendFile 'main/images/' + req.params.image, root: appRoot
  return

moleculeIndex = (req, res) ->
  res.render 'molecules/' + req.params.molecule + '/views/index', url: getURL.bind(base: 'molecules/' + req.params.molecule)
  return

moleculeImages = (req, res) ->
  res.sendFile 'molecules/' + req.params.molecule + '/images/' + req.params.image, root: appRoot
  return

exports.configure = (app, fileProvider) ->
  getURL = fileProvider
  app.get '/', mainIndex
  app.get '/molecules/:molecule', moleculeIndex
  app.get '/main/images/:image', mainImages
  app.get '/molecules/:molecule/images/:image', moleculeImages
  return