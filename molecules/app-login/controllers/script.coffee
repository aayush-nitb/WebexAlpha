Polymer
    is: 'app-login'

    ### @private ###
    _defaultSuccess: () ->
        return

    ### @private ###
    _defaultFailure: () ->
        return
        
    ### @private ###
    _uiLogin: () ->
        this._login $(this).find("#username").val() $(this).find("#password").val()
        this

    ### @private ###
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

    ### @private ###
    _loginByToken: (token) ->
        if token
            localStorage.setItem "auth.token", token
            this._login()
        this

    ### @public ###
    login: (user, password) ->
        localStorage.setItem "auth.user", user
        this._login user, CryptoJS.MD5(password)
        this

    ### @public ###
    authorize: (success, failure, binding) ->
        test = $.ajax
            url: "/molecules/app-login/test",
            crossDomain: true,
            headers: {Authorization: this._auth}
        test.done (data, status, xhr) ->
            this._loginByToken xhr.getResponseHeader("auth-token")
            if success then success(binding) else this._defaultSuccess()
        test.fail () ->
            if failure then failure(binding) else this._defaultFailure()
        this

    ### @public ###
    logout: () ->
        localStorage.setItem "auth.user", ""
        localStorage.setItem "auth.token", ""
        this._auth = ""
        this._user = "null"
        this

    ### @public ###
    getUser: () ->
        this._user

    ### @public ###
    getAuth: () ->
        this._auth

    ### @public ###
    registerSuccess: (callback) ->
        this._defaultSuccess = callback
        this

    ### @public ###
    registerFailure: (callback) ->
        this._defaultFailure = callback
        this

    ### @override ###
    ready: () ->
        this._auth = ""
        this._user = "null"
        this._login()