rfr = require 'rfr'
mongo = require 'mongoskin'

Model = (req) ->
    model = rfr req.query.model
    db_auth = if model.db_user is "" then "" else model.db_user + ":" + model.db_pass
    db_url = db_auth + "@" + model.server + "/" + model.db
    database = mongo.db "mongodb://" + db_url, native_parser:true
    this.db = ->
        database.collection model.collection
    this

module.exports = (req) ->
    new Model(req)