express = require 'express'
rfr = require 'rfr'
router = express.Router()

auth = rfr 'molecules/app-login/services/login'

router.get '/getPreferences', auth, (req, res) ->
    res.json
        success: true
        error: false
    return

module.exports = router