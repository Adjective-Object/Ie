require("./Library.scss")

Reflux = require("reflux")
React  = require("react")
warna  = require("warna")

CONSTANTS  = require("constants.cjsx")
PAGE_MODES = CONSTANTS.PAGE_MODES

LibraryStore   = require("stores/LibraryStore.cjsx")

Actions        = require("actions.cjsx")
WidgetActions  = Actions.WidgetActions
LibraryActions = Actions.LibraryActions

name = require("namehelpers.cjsx")
CSS  = require("csshelpers.cjsx")

Library = React.createClass
    displayName: "Library"
    
    mixins: [Reflux.connect(LibraryStore, "library")]

    _exitLibraryMode: ->
        document.getElementById("library").className = ""
        UIActions.enterMode(PAGE_MODES.LIVE)

    _addWidget: (widget) ->
        WidgetActions.addWidget(widget.kind)

    render: () ->
        self = this

        mkLibraryEntry = (widget) ->
            <div className="library-entry" key={widget.kind}>
                <a className="add-widget" href="#" onClick={ self._addWidget.bind(self, widget) }>
                    <span className="add-icon">+</span>
                    <img className="icon" src="img/icons/#{widget.icon}_icn.svg#content" />
                    <span className="widget-name">{widget.name}</span>
                </a>
                <a className="remove-widget" href="#">x</a>
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
        </div>

module.exports = Library
