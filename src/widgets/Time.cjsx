require ("./Time.scss")

Reflux     = require("reflux")
React      = require("react")
_          = require("lodash")
classNames = require("classnames")
moment     = require("moment")

PageStateStore = require("stores/PageStateStore.cjsx")
Widget = require("widgets/Widget.cjsx")

WidgetActions = require("actions.cjsx").WidgetActions

Option = require("stores/Option.cjsx")
OptionTypes = require("stores/OptionTypes.cjsx")
OptionForm = require("components/OptionsForm.cjsx")

TimerOptions = Option.OptionSet
    name: "TimerOptions"

    options:
        width: 2
        height: 1

    optionTypes:
        width: OptionTypes.int
        height: OptionTypes.int


TimeWidget = Widget.createWidgetClass
    displayName: "TimeWidget"
    widgetName: "core-time-widget"

    mixins: [
        Widget.WidgetMixin,
        Reflux.connect(PageStateStore, "pageState")
    ]

    getInitialState: () ->
        return {
            date: new Date()
            options: TimerOptions
        }

    componentDidMount: () ->
        this.interval = setInterval(
            (()->this.setState {date: new Date()}).bind(this),
            1 * 1000)

    componentWillUnmount: () ->
        clearInterval(this.interval)

    acceptsDim: (x, y) ->
        return 0 < x < 2 && 0 < y < 2

    renderBasePanel: ->
        locale = window.navigator.userLanguage || window.navigator.language

        d = this.state.date
        m = moment()

        backgroundBorder = {
            borderColor: this.state.userStyle.widgetBackground
        }

        midnight = m.clone().startOf 'day'
        hDiff = m.clone().diff(midnight, 'hours')

        # We'll pretend 6 AM and 6 PM are sufficient
        clockImg = if (hDiff > 6 and hDiff < 18) then "day" else "night"

        <div>
            <div className="window-bar" style={this.invertedColors()}>
                <svg className="icon window" viewBox="0 0 32 32" style={this.invertedIconColors()}>
                    <use xlinkHref="img/icons/clock_icn.svg#content"></use>
                </svg>

                <a href="#" onClick={this.wToggleOptionsMode}>
                    <span className="icon options">
                        <svg viewBox="0 0 32 32" style={this.invertedIconColors()}>
                            <use xlinkHref="img/icons/options_icn.svg#content" />
                        </svg>
                    </span>
                </a>

                <h3>eastern standard time</h3>
            </div>
            <div className="clock-content"
                style={backgroundBorder}>
                <div className="status" style={this.invertedColors()}>
                    <svg viewBox="0 0 32 32" className="icon status" style={this.invertedIconColors()}>
                        <use xlinkHref="img/icons/#{clockImg}_img.svg#content" />
                    </svg>
                </div>
                <div className="clock-info">
                    <span className="utc">(UTC{m.format("Z")})</span>
                    <span className="time">{m.format("hh:mm")}
                        <span className="ampm">{m.format("A")}</span></span>
                    <span className="date">
                        {m.format("ddd, MMMM Do, YYYY").toLowerCase()}
                    </span>
                </div>
            </div>
        </div>

    _onOptionChange: (optionName, newVal) ->
        options = this.state.options
        if (optionName == "width" and newVal != options.width)
            WidgetActions.resizeWidget(
                this.props.widgetID,
                this.props.layoutName,
                newVal,
                options.height)

        if(optionName == "height" and newVal != options.height)
            WidgetActions.resizeWidget(
                this.props.widgetID,
                this.props.layoutName,
                options.width,
                newVal)

    renderOptionsPanel: ->
        <OptionForm
            optionSet={TimerOptions}
            objectChangeCallback={this._onOptionChange}
            style={this.invertedColors()}/>


module.exports = TimeWidget
