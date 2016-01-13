require("./Options.scss")

Reflux = require("reflux")
React  = require("react")

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
