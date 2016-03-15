Polymer
    is: 'admin-new-molecule'

    ### @private ###
    _showActions: (e) ->
        $(e.target).parents("tr").find(".dropdown").show()

    ### @private ###
    _hideActions: (e) ->
        $(e.target).parents("tr").find(".dropdown").hide()

    ### @override ###
    ready: ->
        app = this
        app._list = [{name:"app-seed"}, {name:"app-login"}]
        # molecule = $.get "/molecules/admin-new-molecule/molecule"
        # molecule.done (data) ->
        #   app._list = data