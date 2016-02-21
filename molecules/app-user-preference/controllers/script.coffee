Polymer
    is: 'app-user-preference'

    get: (auth) ->
        userPref = $.get
            url: "/molecules/app-user-preference/getPreferences",
            headers: {Authorization: auth},
            data: {model: this.model}
        userPref.done (data) ->
            console.log data

    properties:
        model:
            type: String
            value: "molecules/app-user-preference/models/user-preference"
            notify: true