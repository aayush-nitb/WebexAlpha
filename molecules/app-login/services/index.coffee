express = require 'express'
rfr = require 'rfr'
router = express.Router()

auth = require './login'

router.get '/test', auth, (req, res) ->
    res.json
        success: true
        error: false
    return

module.exports = router