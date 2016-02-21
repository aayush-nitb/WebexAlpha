express = require 'express'
rfr = require 'rfr'
router = express.Router()

login = rfr 'molecules/app-login/services/login'

router.get '/getPreferences', login.auth, (req, res) ->
    res.json
        success: true
        error: false
    return

module.exports = router