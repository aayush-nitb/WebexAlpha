Polymer
    is: 'app-user-preference'

    ### @override ###
    ready: () ->
        app = this
        this.preferences = []
        document.addEventListener "app-login.login", (e) ->
            if e.target.sessionName is app.sessionName
                userPref = e.target.authorize
                    url: "/molecules/app-user-preference/getPreferences",
                    headers: {"app-user-preference": app.model}
                userPref.done (data) ->
                    app.preferences = data
                    return
            return
        document.addEventListener "app-login.logout", (e) ->
            if e.target.sessionName is app.sessionName
                app.preferences = []
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