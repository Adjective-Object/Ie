require("./Options.scss")

Reflux = require("reflux")
React  = require("react/addons")

CONSTANTS  = require("constants.cjsx")
PAGE_MODES = CONSTANTS.PAGE_MODES
BKG_MODES  = CONSTANTS.BKG_MODES

UserInfoOptionStore = require("stores/UserInfoOptionStore.cjsx")
StyleOptionStore    = require("stores/StyleOptionStore.cjsx")
GridOptionStore     = require("stores/GridOptionStore.cjsx")

PageStateStore = require("stores/PageStateStore.cjsx")

Actions       = require("actions.cjsx")
UIActions     = Actions.UIActions
OptionActions = Actions.OptionActions

name = require("namehelpers.cjsx")
CSS  = require("csshelpers.cjsx")

OptionsForm = require("components/OptionsForm.cjsx")

Options = React.createClass
    displayName: "Options"

    mixins: [
        Reflux.connect(StyleOptionStore, "styleOptions"),
        Reflux.connect(GridOptionStore, "gridOptions"),
        Reflux.connect(UserInfoOptionStore, "userInfoOptions")]

    _exitOptionsMode: ->
        document.getElementById("options").className = ""
        UIActions.enterMode(PAGE_MODES.LIVE)

    render: () ->
        self = this


        <div id="options">

            <h1> User Styles </h1>
            <OptionsForm
                optionSet={StyleOptionStore}
                objectChangeCallback={StyleOptionStore.editOption}/>

            <h1> User Info </h1>
            <OptionsForm
                optionSet={UserInfoOptionStore}
                objectChangeCallback={UserInfoOptionStore.editOption}/>

            <button onClick = { this._exitOptionsMode }>
                Close Menu
            </button>


        </div>

module.exports = Options


           # <label htmlFor="widget-background">Widget Background Color</label>
            # <input type="text"
            #     id="widget-background"
            #     defaultValue={ this.state.styleOptions.widgetBackground }
            #     onChange={ this._editGlobalOption("widgetBackground") } />
            # <label htmlFor="widget-foreground">Widget Foreground Color</label>
            # <input type="text"
            #     id="widget-foreground"
            #     defaultValue={ this.state.styleOptions.widgetForeground }
            #     onChange={ this._editGlobalOption("widgetForeground") } />
            # <label htmlFor="widgetBorder">Widget Border Color</label>
            # <input type="text"
            #     id="widget-border"
            #     defaultValue={ this.state.styleOptions.widgetBorder }
            #     onChange={ this._editGlobalOption("widgetBorder") } />
            # <input type="checkbox"
            #     id="background-mode"
            #     checked={ this._isImageMode() }
            #     onChange={ this._handleBackgroundToggle } />
            # <label htmlFor="background-mode">Use Background Image</label>
            # <label htmlFor="background-image">Background Image File</label>
            # <input type="file"
            #     id="background-image"
            #     disabled={ not this._isImageMode() }
            #     onChange={ this._handleBackgroundImage } />
            # <label htmlFor="background">Background</label>
            # <input type="text"
            #     id="background"
            #     defaulValue={ this.state.styleOptions.backgroundColor }
            #     onChange={ this._editGlobalOption("backgroundColor") }  />
            # <label htmlFor="foreground">Foreground</label>
            # <input type="text"
            #     id="foreground"
            #     defaulValue={ this.state.styleOptions.foreground }
            #     onChange={ this._editGlobalOption("foreground") } />
