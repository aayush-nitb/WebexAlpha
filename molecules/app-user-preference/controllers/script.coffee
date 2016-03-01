Polymer
    is: 'app-user-preference'

    ### @private ###
    _cancel: () ->
        this._window 'list'

    ### @private ###
    _add: () ->
        this._window 'add'

    ### @private ###
    _add_done: () ->
        app = this
        userPref = this.login.authorize
            method: 'POST'
            url: "/molecules/app-user-preference/preferences",
            headers: {"app-user-preference": app.model}
            data: preference: $(this).find("#new").val()
        userPref.done (data) ->
            app.preferences = data
            app._window 'list'
            return
        return

    ### @private ###
    _window: (window) ->
        $(this).find("#new").val('')
        $(this).find(".panel-body").hide()
        $(this).find("#view-" + window).show()
        if window is 'list'
            $(this).find(".action").show()
            if not this.preferences.length
                $(this).find("#view-list").hide()
                $(this).find("#view-empty").show()
        else
            $(this).find(".action").hide()

    ### @override ###
    ready: () ->
        app = this
        this._window 'login'
        this.preferences = []
        document.addEventListener "app-login.login", (e) ->
            if e.target.sessionName is app.sessionName
                userPref = e.target.authorize
                    url: "/molecules/app-user-preference/preferences",
                    headers: {"app-user-preference": app.model}
                userPref.done (data) ->
                    app.preferences = data
                    app._window 'list'
                    return
                this.login = e.target
            return
        document.addEventListener "app-login.logout", (e) ->
            if e.target.sessionName is app.sessionName
                app.preferences = []
                app._window 'login'
            return
        return

    properties:
        model:
            type: String
            value: "molecules/app-user-preference/models/user-preference"
            notify: true
        sessionName:
            type: String
            value: "default"
            notify: true