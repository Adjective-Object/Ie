Reflux     = require("reflux")
React      = require("react")
_          = require("lodash")

PageStateStore = require("stores/PageStateStore.cjsx")
Widget = require("widgets/Widget.cjsx")

imgfallback = "img/mocks/happy-tile-20.png"

PictureWidget = Widget.createWidgetClass

    widgetName: "core-picture-widget"

    mixins: [
        Widget.WidgetMixin,
        Reflux.connect(PageStateStore, "pageState")
    ]

    acceptsDim: (x, y) ->
        # Picture widget can be any size
        return true

    renderBasePanel: ->
        invertedColors = {
            backgroundColor: this.state.userStyle.widgetForeground
            color: this.state.userStyle.widgetBackground
        }

        widget_data_imgurl = this.props.widgetData.img
        imgurl = if widget_data_imgurl? then widget_data_imgurl else imgfallback

        <img src={ imgurl } />

module.exports = PictureWidget
