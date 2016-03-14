Polymer
    is: 'admin-new-molecule'

    ### @private ###
    _showActions: (e) ->
        $(this).find(".dropdown").css "display", "none"
        $(e.target).parent("tr").find(".dropdown").css "display", "block"