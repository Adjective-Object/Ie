require("./index.scss")
React = require("react")
ReactDOM = require("react-dom")
Root  = require("./components/Root")

window.onload = () ->

    # render the root element to render on each store change
    ReactDOM.render(
        <Root/>,
        document.getElementById('app')
    )
