getURL = undefined

mainIndex = (req, res) ->
  res.render 'main/views/index',
    title: 'WebExpress'
    url: getURL.bind(base: 'main')
  return

moleculeIndex = (req, res) ->
  res.render 'molecules/' + req.params.molecule + '/views/index', url: getURL.bind(base: 'molecules/' + req.params.molecule)
  return

exports.configure = (app, fileProvider) ->
  getURL = fileProvider
  app.get '/', mainIndex
  app.get '/molecules/:molecule', moleculeIndex
  return