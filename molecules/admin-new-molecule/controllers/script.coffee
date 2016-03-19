Polymer
    is: 'admin-new-molecule'

    ### @private ###
    _showActions: (e) ->
        $(e.target).parents("tr").find(".dropdown").show()
        return

    ### @private ###
    _hideActions: (e) ->
        $(e.target).parents("tr").find(".dropdown").hide()
        return

    ### @private ###
    _window: (window) ->
        $(this).find(".view").hide()
        $(this).find("#view-" + window).show()
        return

    ### @private ###
    _closeAction: (e) ->
        this._window 'list'
        return

    ### @private ###
    _add: (e) ->
        $(this).find("#view-add #input-name").val ""
        $(this).find("#view-add #input-description").val ""
        $(this).find("#view-add #input-version").val "0.0.1"
        this._window 'add'
        return

    ### @private ###
    _rename: (e) ->
        this._molecule = $(e.target).data "id"
        this._window 'rename'
        return

    ### @private ###
    _alert: (window, message, error) ->
        this._message = message
        view = if error then 'warning' else 'success'
        alert = $(this).find "#view-" + window + " #view-" + view
        alert.show().delay(5000).slideUp()
        return

    ### @private ###
    _add_done: (e) ->
        app = this
        molecule = this.login.authorize
            method: 'POST'
            url: "/molecules/admin-new-molecule/molecule",
            data:
                name: $(this).find("#view-add #input-name").val()
                description: $(this).find("#view-add #input-description").val()
                version: $(this).find("#view-add #input-version").val()
                author: $(this).find("#view-add #input-author").val()
                indent: $(this).find("#view-add #input-indent .active input").val()
        molecule.done (res) ->
            if res.success
                app._window 'list'
                app._list = res.data
                app._alert "list", "New molecule created"
            else
                app._alert "add", res.error, true
            return
        return

    ### @private ###
    _rename_done: (e) ->
        app = this
        molecule = this.login.authorize
            method: 'POST'
            url: "/molecules/admin-new-molecule/molecule/" + this._molecule,
            data: name: $(this).find("#view-rename #input-name").val()
        molecule.done (res) ->
            if res.success then app._list = res.data
            app._window 'list'
            return
        return

    ### @override ###
    ready: ->
        app = this
        this._window 'none'
        this._list = []
        document.addEventListener "app-login.login", (e) ->
            if e.target.sessionName is app.sessionName
                app._window 'list'
                molecule = e.target.authorize
                    url: "/molecules/admin-new-molecule/molecule"
                molecule.done (res) ->
                    if res.success then app._list = res.data
                    return
                app.login = e.target
            return
        document.addEventListener "app-login.logout", (e) ->
            if e.target.sessionName is app.sessionName
                app._list = []
                app._window 'none'
            return
        return

    properties:
        sessionName:
            type: String
            value: "default"
            notify: true