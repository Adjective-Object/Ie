require("./TopBar.scss")

Reflux     = require("reflux")
React      = require("react")
classNames = require("classnames")

CONSTANTS  = require("constants.cjsx")
PAGE_MODES = CONSTANTS.PAGE_MODES
BKG        = CONSTANTS.BKG_MODES

UserInfoOptionStore = require("stores/UserInfoOptionStore.cjsx")
StyleOptionStore    = require("stores/StyleOptionStore.cjsx")

PageStateStore = require("stores/PageStateStore.cjsx")
WidgetStore    = require("stores/WidgetStore.cjsx")
DragStore      = require("stores/DragStore.cjsx")

Actions       = require("actions.cjsx")
UIActions     = Actions.UIActions
WidgetActions = Actions.WidgetActions


NavButton = React.createClass
    displayName: "NavButton"

    mixins: [
        Reflux.connect(PageStateStore, "pageState")
    ]

    _handleClick: ->
        if this.state.pageState == this.props.target
            UIActions.enterMode(PAGE_MODES.LIVE)
        else
            UIActions.enterMode(this.props.target)

    render: ->
        classes =
            "nav-button": true
            "active": this.props.target == this.state.pageState

        <a className={classNames classes}
             onClick={this._handleClick}>
            {this.props.children}
        </a>

WidgetTrash = React.createClass
    displayName: "WidgetTrash"

    mixins: [
        Reflux.connect(WidgetStore, "widgets"),
        Reflux.connect(DragStore, "drag"),
        Reflux.connect(PageStateStore, "pageState")
    ]

    getInitialState: () ->
        return {
            aboutToTrash: false 
        }

    trashClass: ->
        if this.state.aboutToTrash
            return "trashing"
        else
            return ""

    _enabled: ->
        return this.state.pageState == PAGE_MODES.EDIT

    _handleMouseOver: ->
        if this._enabled() and this.state.drag?
            this.setState({
                aboutToTrash: true
            })
        return # I have no idea why this returns false without this return

    _handleMouseOut: ->
        if this._enabled() and this.state.drag?
            this.aboutToTrash = false
            this.setState({
                aboutToTrash: false
            })
        return

    _handleMouseUp: ->
        console.log("Enabled: ", this._enabled())
        console.log("Dragging: ", this.state.drag)
        console.log("About to trash: ", this.aboutToTrash)
        if this._enabled() and this.state.drag?
            WidgetActions.removeWidget(this.state.drag.props.widgetID)
            this.setState({
                aboutToTrash: false
            })
        return

    render: ->
        <img id="widget-trash"
            src="./img/icons/trash.png"
            className={ this.trashClass() }
            onMouseOver={ this._handleMouseOver }
            onMouseOut={ this._handleMouseOut }
            onMouseUp={ this._handleMouseUp } />

        
TopBar = React.createClass
    displayName: "TopBar"

    mixins: [
        Reflux.connect(StyleOptionStore, "userStyle")
        Reflux.connect(UserInfoOptionStore, "userInfo")
    ]

    render: ->
        pageMode = this.state.pageState

        classes = {}

        <nav id="top-bar"
             className={classNames classes}
             style={{height: this.state.userStyle.topbarHeight}}>
            <NavButton target={PAGE_MODES.EDIT}>
                <img src="./img/icons/edit-mode.png" />
            </NavButton>
            <NavButton target={PAGE_MODES.OPTS}>
                <img src="./img/icons/options-mode.png" />
            </NavButton>
            <WidgetTrash />
            <h1 id="motd">Welcome, {this.state.userInfo.name}</h1>
        </nav>

module.exports = TopBar
