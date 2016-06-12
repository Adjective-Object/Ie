require("./WidgetGrid.scss")

Reflux = require("reflux")
React  = require("react")
ReactDOM = require("react-dom")

GridOptionStore  = require("stores/GridOptionStore.cjsx")
StyleOptionStore = require("stores/StyleOptionStore.cjsx")
WidgetStore      = require("stores/WidgetStore.cjsx")
LibraryStore     = require("stores/LibraryStore.cjsx")

translate = require("csshelpers.cjsx").translate

WidgetActions = require("actions.cjsx").WidgetActions

GridTileIndicator = React.createClass
    render: ->
        grid = this.props.grid

        style = {
            width: grid.gridUnit.x
            height: grid.gridUnit.y
            transform: translate(
                (grid.gridUnit.x + grid.widgetMargin) * this.props.x,
                (grid.gridUnit.y + grid.widgetMargin) * this.props.y)
            margin: grid.widgetMargin / 2
            #borderColor: this.props.color
        }

        <div className="widget-grid-entry"
             style={style}>
        </div>

WidgetGrid = React.createClass
    displayName: "WidgetGrid"

    mixins: [
        Reflux.connect(GridOptionStore, "grid"),
        Reflux.connect(WidgetStore, "widgets")
        Reflux.connect(StyleOptionStore, "userStyle")
    ]

    ####################################
    # centering the grid vertically to #
    ####################################

    componentDidMount: ->
        window.addEventListener('resize', this._resizeWindow)
        this._centerWithMargin()

    componentWillUnmount: ->
        window.removeEventListener('resize', this._resizeWindow)

    _centerWithMargin: ->
        wrapper = ReactDOM.findDOMNode(this.refs.wrapper)

        topBarHeight = this.state.userStyle.topbarHeight

        availableSpace = window.innerHeight - topBarHeight
        innerPadding = Math.max(0, (availableSpace - wrapper.offsetHeight) / 2)

        wrapper.style.marginTop = "#{topBarHeight + innerPadding}px"

    _resizeWindow: ->
        this._centerWithMargin()
        GridOptionStore.pickGridAndTrigger()

    ###############################
    # fitting widgets to the grid #
    ###############################

    # returns null on failure (occupied spot, etc)
    fitWidgetToGrid: (widgetID, widgetGridSize, pixelX, pixelY) ->
        grid = this.state.grid
        gridX = Math.round(pixelX/(grid.widgetMargin/2 + grid.gridUnit.x))
        gridY = Math.round(pixelY/(grid.widgetMargin/2 + grid.gridUnit.y))

        occupiedSpaces =
            WidgetStore.findOccupiedSpaces(
                this.state.grid, [widgetID])

        isOpen = (x,y) ->
            0 <= x and x < grid.gridDim.x and
            0 <= y and y < grid.gridDim.y and
            not occupiedSpaces[x][y]

        # console.log widgetGridSize, gridX, gridY

        for ix in [0 .. widgetGridSize.x - 1]
            for iy in [0 .. widgetGridSize.y - 1]
                if not isOpen(gridX + ix, gridY + iy)
                    console.log "#{gridX + ix}, #{gridY + iy} is not open"
                    return null

        return {
            x: gridX
            y: gridY
        }

    reflowWidget: (widgetID) ->
      grid = this.state.grid
      invalidWidgets =
          WidgetStore.getInvalidWidgets(this.state.grid, [])
      occupiedSpaces =
        WidgetStore.findOccupiedSpaces(
            this.state.grid, invalidWidgets)
      isOpen = (x,y) ->
          0 <= x and x < grid.gridDim.x and
          0 <= y and y < grid.gridDim.y and
          not occupiedSpaces[x][y]

      isOkay = (gridX, gridY, widgetGridSize) ->
        for ix in [0 .. widgetGridSize.x - 1]
            for iy in [0 .. widgetGridSize.y - 1]
                if not isOpen(gridX + ix, gridY + iy)
                    return false
        return true
      interestedWidget = WidgetStore.getWidgetById(widgetID)
      if interestedWidget
          position = interestedWidget.layouts[grid.settingName].position
          widgetGridSize = interestedWidget.layouts[grid.settingName].dimension
          for py in [position.y .. 0]
            for px in [position.x .. 0]
              if isOkay(px, py, widgetGridSize)
                WidgetActions.moveWidget(
                    widgetID,
                    grid.settingName,
                    px, py)
                return true
      return false


    #############
    # rendering #
    #############

    render: ->
        grid = this.state.grid

        invalidWidgets =
            WidgetStore.getInvalidWidgets(this.state.grid, [])

        for invalidUUID in invalidWidgets
            result = this.reflowWidget(invalidUUID)
            if not result
              console.log "i can't move this shit anymore."

        console.log invalidWidgets

        occupiedSpaces =
            WidgetStore.findOccupiedSpaces(
                this.state.grid, invalidWidgets)

        # grid unit and padding
        fullGridUnit = {
            x: grid.gridUnit.x + grid.widgetMargin
            y: grid.gridUnit.y + grid.widgetMargin
        }

        w = grid.gridDim.x
        h = grid.gridDim.y
        xyPairs = ([c % w, Math.floor(c / w)] for c in [0..w * h - 1])

        innerStyle = {
            width:  fullGridUnit.x * grid.gridDim.x - grid.widgetMargin
            height: fullGridUnit.y * grid.gridDim.y - grid.widgetMargin
            marginLeft:   grid.externalMargin.left
            marginRight:  grid.externalMargin.right
            marginTop:    grid.externalMargin.top
            marginBottom: grid.externalMargin.bottom
        }

        wrapperStyle = {
            width:  fullGridUnit.x * grid.gridDim.x -
                    grid.widgetMargin +
                    grid.externalMargin.left +
                    grid.externalMargin.right
            height: fullGridUnit.y * grid.gridDim.y -
                    grid.widgetMargin +
                    grid.externalMargin.top +
                    grid.externalMargin.bottom
        }

        indicators = (<GridTileIndicator
            grid={grid} x={x} y={y} key={ind}
            color={if occupiedSpaces[x][y] then "red" else "blue"}
            /> for [x, y], ind in xyPairs)

        widgetLayouts =
            ([LibraryStore.getWidgetClass(w.widgetKind),
                w,
                w.layouts[grid.settingName]
                ] for w in this.state.widgets)

        <div id="widget-grid"
             style={wrapperStyle}
             ref="wrapper">
            <div id="widget-grid-inner"
                 style={innerStyle}>
                 {indicators}

                 {(<WidgetClass
                    mountOrigin={{
                        x: wl.position.x * fullGridUnit.x + grid.widgetMargin/2
                        y: wl.position.y * fullGridUnit.y + grid.widgetMargin/2
                    }}
                    mountSize={{
                        x: wl.dimension.x * fullGridUnit.x - grid.widgetMargin
                        y: wl.dimension.y * fullGridUnit.y - grid.widgetMargin
                    }}
                    gridSize={wl.dimension}
                    gridPosition={wl.position}
                    layoutName={grid.settingName}
                    key={w.uuid}
                    widgetID={w.uuid}
                    widgetData={if w.data? then w.data else {} }
                    mountCallback={this.fitWidgetToGrid}
                    /> for [WidgetClass, w, wl] in widgetLayouts when wl?)}
            </div>
        </div>

module.exports = WidgetGrid
