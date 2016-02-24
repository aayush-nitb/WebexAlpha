Polymer
    is: 'app-login'

    ### @private ###
    _defaultSuccess: (data, status, xhr) ->
        return

    ### @private ###
    _defaultFailure: (xhr, status, err) ->
        return
        
    ### @private ###
    _uiLogin: () ->
        if this._user is 'null'
            this.login $(this).find("#username").val(), $(this).find("#password").val()
        else
            this.logout()
        this

    ### @private ###
    _logoutWindow: () ->
        $(this).find("#username").val this._user
        $(this).find("#password").val "****"
        $(this).find("#login").text "Sign Out"
        $(this).find("#login").animateCss('pulse').switchClass "btn-success", "btn-danger", 0
        $(this).find("#username").prop "disabled", true
        $(this).find("#password").prop "disabled", true
        this

    ### @private ###
    _loginWindow: () ->
        $(this).find("#username").val ""
        $(this).find("#password").val ""
        $(this).find("#login").text "Sign In"
        $(this).find("#login").animateCss('pulse').switchClass "btn-danger", "btn-success", 0
        $(this).find("#username").prop "disabled", false
        $(this).find("#password").prop "disabled", false
        this

    ### @public ###
    login: (user, password) ->
        if this._loading is true then return this
        app = this
        old_user = this._user
        old_auth = this._auth
        this._user = user
        this._auth = 'Basic ' + Base64.encode(user + ':' + CryptoJS.MD5(password))
        test = this.authorize url: "/molecules/app-login/test"
        test.done (data, status, xhr) ->
            token = xhr.getResponseHeader("auth-token")
            if token then app._auth = 'Basic ' + Base64.encode(app._user + ':' + token)
            localStorage.setItem "auth.user", user
            localStorage.setItem "auth.token", app._auth
            app._logoutWindow()
            return
        test.fail () ->
            app._user = old_user
            app._auth = old_auth
            $(app).find(".panel").animateCss 'flash'
            return
        this

    ### @public ###
    authorize: (req) ->
        this._loading = true
        app = this
        req.crossDomain = true
        req.cache = false
        req.headers = $.extend {Authorization: this._auth, 'app-login': this.model}, req.headers
        test = $.ajax req
        test.done (data, status, xhr) ->
            app._defaultSuccess data, status, xhr
            return
        test.fail (xhr, status, err) ->
            app._defaultFailure xhr, status, err
            return
        test.always () ->
            app._loading = false
            return
        test

    ### @public ###
    logout: () ->
        this._loading = true
        app = this
        test = this.authorize url: "/molecules/app-login/logout"
        test.done () ->
            localStorage.setItem "auth.user", ""
            localStorage.setItem "auth.token", ""
            app._auth = ""
            app._user = "null"
            app._loginWindow()
            return
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
        app = this
        this._user = "null"
        this._auth = ""
        authUser = localStorage.getItem "auth.user"
        authToken = localStorage.getItem "auth.token"
        if authUser and authToken
            this._user = authUser
            this._auth = authToken
            test = this.authorize url: "/molecules/app-login/test"
            test.done () ->
                app._logoutWindow()
                return
            test.fail () ->
                app._user = "null"
                app._auth = ""
                return
        return
    
    properties:
        model:
            type: String
            value: "molecules/app-login/models/login"
            notify: true