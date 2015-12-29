require ("./Weather.scss")

Reflux     = require("reflux")
React      = require("react")
classNames = require("classnames")
_          = require("lodash")

PageStateStore = require("stores/PageStateStore.cjsx")
Widget = require("widgets/Widget.cjsx")

Option = require("stores/Option.cjsx")
OptionTypes = require("stores/OptionTypes.cjsx")
OptionForm = require("components/OptionsForm.cjsx")

WeatherOptions = Option.OptionSet
    name: "WeatherOptions"

    options:
        width: 2
        height: 2
        woeid: "2459115"

    optionTypes:
        width: OptionTypes.int
        height: OptionTypes.int
        woeid: OptionTypes.string

WeatherWidget = Widget.createWidgetClass
    widgetName: "core-weather-widget"

    mixins: [
        Widget.WidgetMixin,
        Reflux.connect(PageStateStore, "pageState")
    ]

    getInitialState: () ->
        return {
            options: WeatherOptions
            weather: []
        }

    componentDidMount: () ->
        woeid = this.state.options.options.woeid
        self = this
        # This is a bad way to generate queries
        fQuery = "select * from weather.forecast where woeid=" + woeid
        fURL = "https://query.yahooapis.com/v1/public/yql?format=json&q=" + fQuery
        responseJSON = {}
        fetch fURL
        .then (response) ->
            if (response.ok)
                return response.json()
        .then (json) ->
            # Each item in forecast has code, date, day, high, low, text
            forecast = json.query.results.channel.item.forecast
            for d, dForecast of forecast
                code = parseInt dForecast.code
                icon = null
                switch code
                    when 32, 33, 34, 36     then icon = "sunny"
                    when 37, 38, 39, 45, 47 then icon = "thunderstorm"
                    when 9, 10, 11, 12, 40  then icon = "raining"
                    when 26, 27, 28, 29, 30 then icon = "partly-cloudy"
                    else icon = "sunny.svg"
                forecast[d].condition = icon
            self.setState {weather: json.query.results.channel.item.forecast}

    ###
    getDefaultProps: () ->
        {
            weather: [
                {
                    day: "today"
                    condition: "sunny"
                    high: 91
                    low: 76
                },
                {
                    day: "mon"
                    condition: "sunny"
                    high: 91
                    low: 76
                },
                {
                    day: "mon"
                    condition: "sunny"
                    high: 91
                    low: 76
                },
                {
                    day: "mon"
                    condition: "sunny"
                    high: 91
                    low: 76
                },
                {
                    day: "mon"
                    condition: "sunny"
                    high: 91
                    low: 76
                },
                {
                    day: "mon"
                    condition: "sunny"
                    high: 91
                    low: 76
                },

            ]
        }
    ###

    acceptsDim: (x, y) ->
        return x == 2 && y == 2

    renderBasePanel: ->

        invertedColors = {
            backgroundColor: this.state.userStyle.widgetForeground
            color: this.state.userStyle.widgetBackground
        }

        mkWeather = (weather, index) ->
            <tr className="weather" key={index}>
                <td className="day">{weather.day}</td>
                <td className="weather-icon">
                    <img src={"img/icons/#{weather.condition}.png"} />
                </td>
                <td className="high">{weather.high}</td>
                <td className="low">{weather.low}</td>
            </tr>

        fiveday = (mkWeather d, i for d, i in this.state.weather[0..])

        <div>
             <div className="window-bar"
                 style={invertedColors}>
                <img src="img/icons/rain-drop.png" className="icon window" />
                <a href="#" onClick={this.wToggleOptionsMode}>
                    <span className="icon options">
                        <img src="img/icons/options-icon.png" />
                    </span>
                </a>
                <h3>the weather for today</h3>
            </div>

            <div className="today">
            </div>

            <table className="five-day">
                <thead>
                    <tr><th>Day</th><th>Weather</th><th>High</th><th>Low</th></tr>
                </thead>
                {fiveday}
            </table>
        </div>

    _onOptionsChange: (optionName, newVal) ->
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

        if(optionname == "woeid" and newVal != options.woeid)
            WidgetActions.updateWidgetSettings()

    renderOptionsPanel: ->
        invertedColors = {
            backgroundColor: this.state.userStyle.widgetForeground
            color: this.state.userStyle.widgetBackground
        }


        <OptionForm 
            optionSet={WeatherOptions} 
            objectChangeCallback={this._onOptionChange}
            style={invertedColors}/>

module.exports = WeatherWidget
