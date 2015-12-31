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
            weather: {
                today: {
                    condition: 'sunny',
                    temp: '0',
                    high: '0',
                    low: '0'
                }
                forecast: []
            }
        }

    componentDidMount: () ->
        woeid = this.state.options.options.woeid
        self = this
        # This is a bad way to generate queries
        fQuery = "select * from weather.forecast where woeid=" + woeid
        fURL = "https://query.yahooapis.com/v1/public/yql?format=json&q=" + fQuery
        fetch fURL
        .then (response) ->
            if (response.ok)
                return response.json()
        .then (json) ->
            # Each item in forecast has code, date, day, high, low, text
            weather = {}
            forecast = json.query.results.channel.item.forecast
            for d, dForecast of forecast
                code = parseInt dForecast.code
                forecast[d].condition = self._conditionCodeToIcon code
            weather.forecast = forecast

            weather.today = json.query.results.channel.item.condition
            weather.today.condition = self._conditionCodeToIcon weather.today.code
            weather.today.high = forecast[0].high
            weather.today.low = forecast[0].low

            self.setState {weather: weather}

    _conditionCodeToIcon: (code) ->
        switch code
            when 32, 33, 34, 36     then return "sunny"
            when 37, 38, 39, 45, 47 then return "thunderstorm"
            when 9, 10, 11, 12, 40  then return "raining"
            when 26, 27, 28, 29, 30 then return "partly-cloudy"
            else return "sunny"

    acceptsDim: (x, y) ->
        return x == 2 && y == 2

    renderBasePanel: ->

        invertedColors = {
            backgroundColor: this.state.userStyle.widgetForeground
            color: this.state.userStyle.widgetBackground
        }

        mkForecast = (forecast, index) ->
            <tr className="weather" key={index}>
                <td className="day">{forecast.day}</td>
                <td className="weather-icon">
                    <img src={"img/icons/#{forecast.condition}.png"} />
                </td>
                <td className="high">{forecast.high}</td>
                <td className="low">{forecast.low}</td>
            </tr>

        mkToday = (today) ->
            <div className="today" style={invertedColors}>
                <div className="weather-icon">
                    <img src={"img/icons/#{today.condition}.png"} />
                </div>
                <div className="conditions">
                    <div className="temperature">{today.temp}&deg;</div>
                    <div className="highlow">
                        <div className="high">{today.high}&deg;</div>
                        <div className="low">{today.low}&deg;</div>
                    </div>
                </div>
            </div>

        fiveday = (mkForecast d, i for d, i in this.state.weather.forecast[1..])
        today = (mkToday this.state.weather.today)

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

            <div className="weather-container">
                {today}

                <table className="five-day">
                    {fiveday}
                </table>
            </div>
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
