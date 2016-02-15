express = require 'express'
router = express.Router()

auth = require '../../app-login/services/login'

router.get '/test', auth, (req, res) ->
    res.json
        success: true
        error: false
    return

module.exports = router