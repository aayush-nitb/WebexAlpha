randomstring = require 'just.randomstring'
basicAuth = require 'basic-auth'
rfr = require 'rfr'
md5 = require 'MD5'
models = rfr 'models'

username = ''
exports.user = ->
  username

exports.auth = (req, res, next) ->
  TTL = 24 * 3600000
  #time-to-live is one day

  unauthorized = (res) ->
    res.set 'WWW-Authenticate', 'Basic realm=Authorization Required'
    res.sendStatus 403

  authorize = (username, password) ->
    token = md5 randomstring()
    loginModel.db().update {'user':username}
      , $set:
          'password': password
          'token': token
          'session': Date.now() + TTL
      , (err, records) ->
          if records
            res.set 'auth-token', token
            next()
          else
            unauthorized res
    return

  loginModel = models req
  user = basicAuth req

  if not user or not user.name or not user.pass
    return unauthorized(res)

  try
    loginModel.db().findOne {'user':user.name}
    , (err, item) ->
        if not item then return unauthorized(res)
        if not item.password then return authorize(user.name, user.pass)
        if item.token == user.pass and Date.now() < item.session
          return next()
        else if item.password == user.pass
          authorize user.name, user.pass
        else
          return unauthorized(res)
        return
    username = user.name
  catch ex
    return unauthorized(res)
  return