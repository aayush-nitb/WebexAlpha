Polymer
  is: 'app-login'

  _defaultSuccess: () ->
    return
  registerSuccess: (callback) ->
    this._defaultSuccess = callback
    this

  _defaultFailure: () ->
    return
  registerFailure: (callback) ->
    this._defaultFailure = callback
    this

  authorize: (success, failure) ->
    test = $.get "/molecules/app-login/test"
    test.done () ->
        if success then success() else this._defaultSuccess()
    test.fail () ->
        if failure then failure() else this._defaultFailure()
    this