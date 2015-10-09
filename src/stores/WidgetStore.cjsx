Reflux = require("reflux")

WidgetActions = (require "actions.cjsx").WidgetActions

WidgetStore = Reflux.createStore
    storeName: "WidgetStore"
    # actions this store listens to
    listenables: [WidgetActions]

    widgetKinds : {
        timer: require   "widgets/Time.cjsx"
        mail: require    "widgets/Mail.cjsx"
        weather: require "widgets/Weather.cjsx"
        picture: require "widgets/Picture.cjsx"
    }

    # default state
    widgets: [
        {
            widgetKind: "timer"
            layouts:
                large:
                    position: {x: 0, y: 0}
                    dimension: {x: 2, y: 1}
            uuid: "fake-uuid"
        },
        {
            widgetKind: "mail"
            layouts:
                large:
                    position: {x: 0, y: 1}
                    dimension: {x: 2, y: 2}
            uuid: "fake-uuid-2"
        },
        {
            widgetKind: "weather"
            layouts:
                large:
                    position: {x: 2, y: 0}
                    dimension: {x: 2, y: 2}
            uuid: "fake-uuid-3"
        },
        {
            widgetKind: "picture"
            data:
                img: "img/mocks/happy-tile-20.png"
            layouts:
                large:
                    position: {x: 4, y: 0}
                    dimension: {x: 2, y: 1}
            uuid: "fake-uuid-4"
        },
        {
            widgetKind: "picture"
            data:
                img: "img/mocks/tile-21.png"
            layouts:
                large:
                    position: {x: 4, y: 1}
                    dimension: {x: 2, y: 1}
            uuid: "fake-uuid-5"
        },
        {
            widgetKind: "picture"
            data:
                img: "img/mocks/tile-22.png"
            layouts:
                large:
                    position: {x: 4, y: 2}
                    dimension: {x: 2, y: 1}
            uuid: "fake-uuid-6"
        }
    ]

    getWidgetClass: (widgetInstance) ->
        return this.widgetKinds[widgetInstance.widgetKind]
    
    findOccupiedSpaces: (grid, ignoreWidgets) ->
        # init OccupiedSpaces
        occupiedSpaces = new Array(grid.gridDim.x)
        for ix in [0 .. (grid.gridDim.x - 1)]
            occupiedSpaces[ix] = new Array(grid.gridDim.y)
            for iy in [0 .. (grid.gridDim.y - 1)]
                occupiedSpaces[ix][iy] = false

        # fill spaces occuupied by widgets
        relevantWidgets = 
            (w for w in this.widgets when w.uuid not in ignoreWidgets)
        for widget in relevantWidgets
            wl = widget.layouts[grid.settingName]
            if wl?
                for ix in [0..wl.dimension.x - 1]
                    for iy in [0..wl.dimension.y - 1]
                        xo = wl.position.x + ix
                        yo = wl.position.y + iy
                        occupiedSpaces[xo][yo] = true
        return occupiedSpaces

    # the initial state of the store from localstorage
    # if that fails, use the default
    getInitialState: ->
        storageState = window.localStorage.getItem("widgets")
        if storageState
            this.widgets = JSON.parse(storageState)
        return this.widgets

    onAddWidget: (widget) ->
        this.widgets.push(widget)
        this.cacheAndTrigger()

    # moves a widget so its top left corner is at grid position x,y
    # assumes safe to move
    onMoveWidget: (widgetID, layout, x, y) ->
        for widget in this.widgets
            if widget.uuid == widgetID
                widget.layouts[layout].position =
                    x: x
                    y: y
                console.log "moved widget '#{widgetID}'"
                console.log this.widgets
                break
        this.cacheAndTrigger()

    onRemoveWidget: (widgetID) ->
        console.log("trying to remove widget", widgetID)
        for widgetIndex in [0..this.widgets.length]
            if this.widgets[widgetIndex].uuid == widgetID
                console.log("removing widget with ID", widgetID)
                this.widgets.splice(widgetIndex, 1)
                this.cacheAndTrigger()
                break

    onResizeWidget: (widgetID, layout, width, height) ->
        console.log("resizing widget", widgetID)
        for widget in this.widgets
            if widget.uuid == widgetID
                widget.layouts[layout].dimension = 
                    {x: width, y:height}
                this.trigger(this.widgets)
                return

    cacheAndTrigger: () ->
        this.trigger(this.widgets)
        window.localStorage.setItem(
            "widgets",
            JSON.stringify(this.widgets))



module.exports = WidgetStore
