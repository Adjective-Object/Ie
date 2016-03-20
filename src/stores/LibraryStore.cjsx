Reflux = require("reflux")

PAGE_MODES = (require "constants.cjsx").PAGE_MODES
LibraryActions = (require "actions.cjsx").LibraryActions

LibraryStore = Reflux.createStore
    storeName: "LibraryStore"

    listenables: [LibraryActions]

    widgets: [
        #{
        #    kind: "timer"
        #    name: "Time"
        #    icon: "clock"
        #    class: require "widgets/Time.cjsx"
        #}
    ]

    getWidgetFromKind: (kind) ->
        return (w for w in this.widgets when w.kind is kind)[0]

    getWidgetClass: (kind) ->
        widget = this.getWidgetFromKind(kind)
        if widget
            return widget.class
        else
            # TODO: this should be some default widget
            console.log "Failed to resolve", kind
            return this.widgets[0].class

    init: () ->
        console.log "Hello I am a library", this.widgets
        storageState = window.localStorage.getItem("library")
        if storageState
            console.log "Restoring library from localstorage"
            this.widgets = JSON.parse(storageState)
            console.log this.widgets
            for widget in this.widgets
                if widget.source
                    console.log "resolved", widget.kind, "from localstorage source"
                    widget.class = eval widget.source
                    console.log widget.class
                else
                    console.log "Cannot resolve widget source from localstorage"
        return this.widgets

    getInitialState: () ->
        return this.widgets

    onAddToLibrary: (widgetURL) ->
        self = this
        newWidget = null
        console.log "Attempting to install widget from", widgetURL
        fetch(widgetURL)
        .then (response) ->
                console.log response
                return response.json()
            , (error) ->
                console.log "Manifest fetch failed", error
                return null
        .then (json) ->
                if json
                    console.log "Installing", json.name, "from", json.src
                    console.log "self", self
                    # manifest.json must contain kind, name, icon, src
                    newWidget = {
                        kind: json.kind
                        name: json.name
                        icon: "clock"
                    }
                    # src field points to widget js
                    return fetch(json.src)
                else return null
            , (error) ->
                console.log "Manifest JSON error", error
        .then (response) ->
                return response.text()
            , (error) ->
                console.log "Widget source fetch failed", error
        .then (text) ->
                if text
                    console.log "Got widget src"
                    source = eval text
                    console.log source
                    if newWidget
                        # Keep a copy of the source code around for future loads
                        newWidget.source = text

                        # Keep the eval'd function as the widget class for use now
                        newWidget.class = source

                        # Save it to the widget library and update
                        self.widgets.push(newWidget)
                        self.cacheAndTrigger()
                else return null
            , (error) ->
                console.log "Failed to eval widget", error
        return

    onRemoveFromLibrary: (kind) ->
        # Filter out the widget kind
        console.log "Trying to remove", kind
        widgets = (widget for widget in this.widgets when widget.kind != kind)
        this.widgets = widgets
        console.log "New library after delete:", this.widgets
        this.cacheAndTrigger()

    cacheAndTrigger: () ->
        # Need to deep copy the class
        this.trigger(this.widgets)
        widgetCache = []
        for widget in this.widgets
            widgetCache.push({
                kind: widget.kind
                name: widget.name
                icon: widget.icon
                source: widget.source
            })
        window.localStorage.setItem(
            "library",
            JSON.stringify(widgetCache))

module.exports = LibraryStore
