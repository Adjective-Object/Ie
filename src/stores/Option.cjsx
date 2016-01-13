React = require("react")
Reflux = require("reflux")

invariant = require "invariant"
_         = require "lodash"

OptionTypes = require("stores/OptionTypes.cjsx")
name = require("namehelpers.cjsx")

OptionMixin =
    fetchedFromStore: false
    getInitialState: ->
        if !this.fetchedFromStore
            storageState = window.localStorage.getItem(this.storeName)
            if storageState
                this.options = JSON.parse(storageState)
            this.fetchedFromStore = true
        return this.options

    editOption: (fieldName, fieldValue) ->
        console.log "editing option", fieldName, this.optionTypes
        this.options[fieldName] =
            this.optionTypes[fieldName].processor(fieldName, fieldValue)
        console.log "setting", fieldName, "to", this.options[fieldName]
        this.cacheAndTrigger()

    cacheAndTrigger: ->
        console.log "caching and triggering"
        window.localStorage.setItem(
            this.storeName,
            JSON.stringify(this.options))
        console.log(this.options)
        this.trigger(this.options)

OptionSet = (obj) ->
    # creaate an OptionSet, cmhecking a few conditionals required
    invariant "options" in Object.keys(obj),
              "Options Store mising an 'options' field"

    invariant "optionTypes" in Object.keys(obj),
              "Options Store mising a 'optionTypes' field"

    optionFields    = Object.keys(obj.options)
    typeFields      = Object.keys(obj.optionTypes)

    uniqueOptions = _.without.bind(
        this, typeFields).apply(
        this, typeFields)

    invariant uniqueOptions.length == 0,
              "options #{uniqueOptions} have no type declaration"

    obj.validateOption = (fieldName, fieldValue) ->
        return fieldName in Object.keys(this.options) and
            this.optionTypes[fieldName].validator(fieldValue)

    return obj

createStore = (obj) ->
    obj = OptionSet(obj)
    obj.mixins = (obj.mixins || []).concat(OptionMixin)
    return Reflux.createStore(obj)

module.exports =
    mixin: OptionMixin
    createStore: createStore
    OptionSet: OptionSet
