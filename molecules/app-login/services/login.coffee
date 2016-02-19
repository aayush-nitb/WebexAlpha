randomstring = require 'just.randomstring'
basicAuth = require 'basic-auth'
rfr = require 'rfr'
md5 = require 'MD5'
mongo = require 'mongoskin'

module.exports = (req, res, next) ->
  model = rfr req.query.model

  TTL = 24 * 3600000
  #time-to-live is one day

  db = mongo.db "mongodb://" + model.server + "/" + model.db, native_parser:true
  user = basicAuth req

  unauthorized = (res) ->
    res.set 'WWW-Authenticate', 'Basic realm=Authorization Required'
    res.sendStatus 401

  authorize = (username, password) ->
    token = md5 randomstring()
    db.collection(model.collection).update {'user':username}
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

  if not user or not user.name or not user.pass
    return unauthorized(res)

  db.collection(model.collection).findOne {'user':user.name}
    , (err, item) ->
        if not item then return unauthorized(res)
        if item.password
          if item.token == user.pass and Date.now() < item.session
            return next()
          else if item.password == user.pass
            authorize user.name, user.pass
          else
            return unauthorized(res)
        else
          authorize user.name, user.pass
        return
  return