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
        $(this).find("#new").val ""
        return

    ### @private ###
    _add: (e) ->
        this._window 'add'
        return

    ### @private ###
    _rename: (e) ->
        this._molecule = $(e.target).data "id"
        this._window 'rename'
        return

    ### @private ###
    _add_done: (e) ->
        return

    ### @private ###
    _rename_done: (e) ->
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
                molecule.done (data) ->
                    app._list = data
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