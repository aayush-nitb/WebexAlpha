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
        old_user = this._user
        old_auth = this._auth
        this._user = user
        this._auth = 'Basic ' + Base64.encode(user + ':' + CryptoJS.MD5(password))
        this.authorize (->
            localStorage.setItem "auth.user", user
            localStorage.setItem "auth.token", this._auth
            this._logoutWindow()
        ), ->
            this._user = old_user
            this._auth = old_auth
            $(this).find(".panel").animateCss 'flash'
        this

    ### @public ###
    authorize: (success, failure, binding) ->
        this._loading = true
        app = this
        test = $.ajax
            url: "/molecules/app-login/test",
            data: {model: this.model},
            crossDomain: true,
            cache: false,
            headers: {Authorization: app._auth}
        test.done (data, status, xhr) ->
            token = xhr.getResponseHeader("auth-token")
            if token then this._auth = 'Basic ' + Base64.encode(this._user + ':' + token)
            if success then success.bind(app)(binding) else app._defaultSuccess()
        test.fail () ->
            if failure then failure.bind(app)(binding) else app._defaultFailure()
        test.always () ->
            app._loading = false
        this

    ### @public ###
    logout: () ->
        this._loading = true
        app = this
        test = $.ajax
            url: "/molecules/app-login/logout",
            data: {model: this.model},
            crossDomain: true,
            cache: false,
            headers: {Authorization: app._auth}
        test.done (data, status, xhr) ->
            localStorage.setItem "auth.user", ""
            localStorage.setItem "auth.token", ""
            app._auth = ""
            app._user = "null"
            app._loginWindow()
        test.always () ->
            app._loading = false
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
        this._user = "null"
        this._auth = ""
        authUser = localStorage.getItem "auth.user"
        authToken = localStorage.getItem "auth.token"
        if authUser and authToken
            this._user = authUser
            this._auth = authToken
            this.authorize (->
                this._logoutWindow()
            ), ->
                this._user = "null"
                this._auth = ""
    
    properties:
        model:
            type: String
            value: "molecules/app-login/models/login"
            notify: true