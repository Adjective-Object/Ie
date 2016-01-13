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

    onAddToLibrary: (widgetSrc) ->
        # Fetch the widget
        # this.trigger(widget)
        return

module.exports = LibraryStore
