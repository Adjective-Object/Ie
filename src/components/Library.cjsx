require("./Library.scss")

Reflux = require("reflux")
React  = require("react")
warna  = require("warna")

CONSTANTS  = require("constants.cjsx")
PAGE_MODES = CONSTANTS.PAGE_MODES

LibraryStore   = require("stores/LibraryStore.cjsx")

Actions        = require("actions.cjsx")
UIActions      = Actions.UIActions
WidgetActions  = Actions.WidgetActions
LibraryActions = Actions.LibraryActions

name = require("namehelpers.cjsx")
CSS  = require("csshelpers.cjsx")

Library = React.createClass
    displayName: "Library"
    
    mixins: [Reflux.connect(LibraryStore, "library")]

    getInitialState: () ->
        showWidgetEntry: false

    _exitLibraryMode: ->
        document.getElementById("library").className = ""
        UIActions.enterMode(PAGE_MODES.LIVE)

    _addWidget: (widget) ->
        WidgetActions.addWidget(widget.kind)

    _removeWidget: (widget) ->
        LibraryActions.removeFromLibrary(widget.kind)

    _addWidgetInput: ->
        if not this.state.showWidgetEntry
            this.refs.url.value = ""

        this.setState({
            showWidgetEntry: !this.state.showWidgetEntry
            urlStatus: ""
        })

    _processWidgetURL: (event) ->
        if event.charCode == 13
            if this.refs.url.value.length
                this.setState({urlStatus: "good"})
                LibraryActions.addToLibrary(this.refs.url.value)
            else
                # Empty url
                console.log "Empty url!"
                this.setState({urlStatus: "bad"})

    render: () ->
        self = this

        mkLibraryEntry = (widget) ->
            <div className="library-entry" key={widget.kind}>
                <a className="add-widget" href="#" onClick={ self._addWidget.bind(self, widget) }>
                    <span className="add-icon">+</span>
                    <img className="icon" src="img/icons/#{widget.icon}_icn.svg#content" />
                    <span className="widget-name">{widget.name}</span>
                </a>
                <a className="remove-widget" href="#" onClick={ self._removeWidget.bind(self, widget) }>x</a>
            </div>

        catalog = (mkLibraryEntry w for w in this.state.library)

        <div id="library">
            <h1>Widget Library</h1>
            <div id="catalog">
                {catalog}
            </div>

            <button onClick = { this._exitLibraryMode }>
                Close Menu
            </button>

            <div id="add-widget-wrapper"
                className={ if this.state.showWidgetEntry then "show" else "" }>
                <button onClick = { this._addWidgetInput }>
                    Add Widget
                </button>
                <input
                    id="widget-url"
                    ref="url"
                    className={ if this.state.urlStatus? then this.state.urlStatus else "" }
                    onKeyPress={ this._processWidgetURL }
                    type="text"
                    placeholder="Widget URL"></input>
            </div>
        </div>

module.exports = Library
