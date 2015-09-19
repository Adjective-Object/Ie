require("./Options.scss")

Reflux = require("reflux")
React  = require("react/addons")
warna  = require("warna")

CONSTANTS  = require("constants.cjsx")
PAGE_MODES = CONSTANTS.PAGE_MODES
BKG_MODES  = CONSTANTS.BKG_MODES

PageStateStore = require("stores/PageStateStore.cjsx")

Actions       = require("actions.cjsx")
UIActions     = Actions.UIActions
OptionActions = Actions.OptionActions

name = require("namehelpers.cjsx")
CSS  = require("csshelpers.cjsx")

module.exports =
    React.createClass
        displayName: "OptionForm"

        _handleEditOption: (name, value) ->
            if this.props.optionSet.validateOption(name, value)
                console.log "passed validation (#{name}, #{value})"
                CSS.removeClass(document.getElementById(name), 'invalid');
                CSS.addClass(document.getElementById(name), 'valid');
                this.props.objectChangeCallback(name, value)
            else
                console.log "failed validation (#{name}, #{value})"
                CSS.removeClass(document.getElementById(name), 'valid');
                CSS.addClass(document.getElementById(name), 'invalid');

        render: () ->
            console.log this
            mkInput = (fieldName, fieldValue) =>
                this.props.optionSet.optionTypes[fieldName].mkInputField(
                    fieldName,
                    fieldValue,
                    this._handleEditOption)

            opts = this.props.optionSet
            console.log "options:", opts.options, "types:", opts.optionTypes

            <div>
                {(mkInput(key, opts.options[key]) \
                    for key in Object.keys(opts.options))}
            </div>

