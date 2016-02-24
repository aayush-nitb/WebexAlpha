Polymer
    is: 'app-user-preference'

    ### @public ###
    get: () ->
        userPref = $(this.login)[0].authorize
            url: "/molecules/app-user-preference/getPreferences",
            headers: {"app-user-preference": this.model}
        userPref.done (data) ->
            console.log data
            return
        this

    properties:
        model:
            type: String
            value: "molecules/app-user-preference/models/user-preference"
            notify: true
        login:
            type: String
            value: "app-login"
            notify: true