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

    _login: (authUser, authToken) ->
        if authUser and authToken
            auth = Base64.encode authUser + ':' + authToken
            this._auth = 'Basic ' + auth
        else
            authUser = localStorage.getItem "auth.user"
		    authToken = localStorage.getItem "auth.token"
            if authUser and authToken
                this._user = authUser
                auth = Base64.encode authUser + ':' + authToken
                this._auth = 'Basic ' + auth
        this

    _loginByToken: (token) ->
        if token
            localStorage.setItem "auth.token", token
            this._login()
        this

    login: (user, password) ->
        localStorage.setItem "auth.user", user
		this._login user, CryptoJS.MD5(password)
        this

    authorize: (success, failure) ->
        test = $.get "/molecules/app-login/test"
        test.done (data, status, xhr) ->
            this._loginByToken xhr.getResponseHeader("auth-token")
            if success then success() else this._defaultSuccess()
        test.fail () ->
            if failure then failure() else this._defaultFailure()
        this

    logout: () ->
        localStorage.setItem "auth.user", ""
		localStorage.setItem "auth.token", ""
		this._auth = ""
        this._user = "null"
        this

    getUser: () ->
        this._user

    getAuth: () ->
        this._auth

    ready: () ->
        this._auth = ""
        this._user = "null"
        this._login()