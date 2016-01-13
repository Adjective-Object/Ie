require ("./Widget.scss")

Reflux = require("reflux")
React  = require("react")
ReactDOM = require("react-dom")
CSSTransitionGroup = require("react-addons-css-transition-group")
classNames = require("classnames")

Option = require("stores/Option.cjsx")
CSS = require("csshelpers.cjsx")

GridOptionStore  = require("stores/GridOptionStore.cjsx")
StyleOptionStore = require("stores/StyleOptionStore.cjsx")
DragStore        = require("stores/DragStore.cjsx")

WidgetActions = require("actions.cjsx").WidgetActions

PAGE_MODES = require("constants.cjsx").PAGE_MODES

createWidgetClass = (obj) ->
    if not obj.acceptsDim?
        throw "no 'acceptsDim' method while trying to instanciate widget
               #{if 'displayName' in obj then " #{obj.displayName}." else "."}"
    React.createClass(obj)

WidgetMixin =

    mixins: [Reflux.connect(StyleOptionStore, "userStyle")]

    componentDidMount: () ->
        window.addEventListener('mousemove', this.wContinueDrag)
        window.addEventListener('mouseup', this.wEndDrag)

    componentWillUnmount: () ->
        window.removeEventListener('mousemove', this.wContinueDrag)
        window.removeEventListener('mouseup', this.wEndDrag)

    getInitialState: () ->
        trackingOrigin: undefined
        relativePos:
            x: 0
            y: 0
        isFront: false

        renderOptionsPanel: false
        renderBasePanel: true

    wStartDrag: (evt) ->
        evt.preventDefault()

        this.setState({
            trackingOrigin:
                x: evt.nativeEvent.x
                y: evt.nativeEvent.y })

        this.setState({
            relativePos:
                x: 0
                y: 0 })

        this.setState({
            isFront: true })

        WidgetActions.startDrag(this)

    wContinueDrag: (nativeEvent) ->
        if this.state.trackingOrigin?

            this.setState({
                relativePos:
                    x: nativeEvent.x - this.state.trackingOrigin.x
                    y: nativeEvent.y - this.state.trackingOrigin.y })

            ReactDOM.findDOMNode(this).style.transform = CSS.translate(
                this.props.mountOrigin.x + this.state.relativePos.x,
                this.props.mountOrigin.y + this.state.relativePos.y)

    wToggleOptionsMode: () ->
        this.setState({
            renderOptionsPanel: not this.state.renderOptionsPanel
            renderBasePanel: this.state.renderOptionsPanel
        })


    wEndDrag: (nativeEvt) ->
        if this.state.trackingOrigin?
            # reset the tracking state
            this.setState({trackingOrigin: undefined})

            endSlot = this.props.mountCallback(
                this.props.widgetID,
                this.props.gridSize,
                this.state.relativePos.x +
                    this.props.mountOrigin.x,
                this.state.relativePos.y +
                    this.props.mountOrigin.y)

            gp = this.props.gridPosition
            if endSlot? and (endSlot.x != gp.x or endSlot.y != gp.y)

                console.log "moving widget"
                WidgetActions.moveWidget(
                    this.props.widgetID,
                    this.props.layoutName,
                    endSlot.x, endSlot.y)

            else
                console.log "widget move failed endslot=#{endSlot}"
                domNode = ReactDOM.findDOMNode(this)
                # move it to the original position
                domNode.style.transform = CSS.translate(
                    this.props.mountOrigin.x,
                    this.props.mountOrigin.y)

            # remove the 'front' style after the 'return to tile' animation
            # has completed
            setTimeout((() =>
                # If isMounted is false, we are not allowed to setState
                # This happens if the drag resulted in a widget deletion
                if this.isMounted()?
                    this.setState({
                        isFront: false
                })), 200)

            WidgetActions.stopDrag(this)

    widgetStyle: ->
        {
            width: this.props.mountSize.x
            height: this.props.mountSize.y
            transform: CSS.translate(
                this.props.mountOrigin.x,
                this.props.mountOrigin.y)

            # requires that the wiuget listen to userStyle
            backgroundColor: this.state.userStyle.widgetBackground
            color: this.state.userStyle.widgetForeground
            borderColor: this.state.userStyle.widgetBorder
        }

    widgetContentStyle: ->
        {
            width: this.props.mountSize.x
            # Magic number for window title height
            height: this.props.mountSize.y - 32

            backgroundColor: this.state.userStyle.widgetBackground
            color: this.state.userStyle.widgetForeground
            borderColor: this.state.userStyle.widgetBorder
        }

    invertedColors: ->
        {
            backgroundColor: this.state.userStyle.widgetForeground
            color: this.state.userStyle.widgetBackground
        }

    iconColors: ->
        {
            stroke: "transparent"
            fill: this.state.userStyle.widgetForeground
        }

    invertedIconColors: ->
        {
            stroke: "transparent"
            fill: this.state.userStyle.widgetBackground
        }

    ShouldComponentUpdate: (nextState) ->
        return nextState.widget != this.state.widget

    widgetClasses: () ->
        base = {
            dragging: this.state.trackingOrigin?
            front: this.state.isFront
            widget: true
            "show-options": this.state.renderOptionsPanel
            "show-base": this.state.renderBasePanel
        }
        gridSize = this.props.gridSize
        base["sizex-#{gridSize.x}"] = true
        base["sizey-#{gridSize.y}"] = true
        base[this.widgetName] = true
        return base



    render: ->
        editing = this.state.pageState == PAGE_MODES.EDIT

        if this.state.renderBasePanel
            panel = React.cloneElement(
                    this.renderBasePanel(), {
                        className: "base-panel",
                        key: "base"
                    })
        else
            panel = React.cloneElement(
                    this.renderOptionsPanel(), {
                        className: "options-panel",
                        key: "opt"
                    })

        <CSSTransitionGroup
            transitionName="widgetpanel"
            transitionEnterTimeout={300}
            transitionLeaveTimeout={300}
            className={classNames(this.widgetClasses())}
            onMouseDown={ if editing then this.wStartDrag else undefined}
            onMouseUp={ if editing then this.wEndDrag else undefined}
            style={this.widgetStyle()}
            id={"widget-#{this.props.widgetID}"}>
            {panel}
        </CSSTransitionGroup>

module.exports = {
    createWidgetClass: createWidgetClass
    WidgetMixin: WidgetMixin
}
