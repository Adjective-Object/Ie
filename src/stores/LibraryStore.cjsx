Reflux = require("reflux")

PAGE_MODES = (require "constants.cjsx").PAGE_MODES
LibraryActions = (require "actions.cjsx").LibraryActions

LibraryStore = Reflux.createStore
    storeName: "LibraryStore"

    listenables: [LibraryActions]

    widgets: [
        {
            kind: "time"
            name: "Time"
            icon: "clock"
            source: ""
        },
        {
            kind: "weather"
            name: "Weather"
            icon: "weather"
            source: ""
        },
        {
            kind: "mail"
            name: "Mail"
            icon: "mail"
            source: ""
        }
    ]

    getWidgetFromKind: (kind) ->
        return (w for w in this.widgets when w.kind is kind)[0]

    getInitialState: () ->
        # if localstorage
        return this.widgets

    onAddToLibrary: (widgetURL) ->
        console.log "Attempting to install widget from", widgetURL
        fetch(widgetURL)
        .then (response) ->
                return response.json()
            , (error) ->
                console.log "Fetch failed", error
                return null
        .then (json) ->
                if json
                    console.log json
            , (error) ->
                console.log "Manifest JSON error", error

        # Fetch the widget
        # this.trigger(widget)
        return

module.exports = LibraryStore
