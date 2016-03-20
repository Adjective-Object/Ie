Reflux = require "reflux"

# Each action is like an event channel for one specific event.
#     Actions are called by components.
# The store is listening to all actions,
# and the components in turn are listening to the store.
# Thus the flow is:
#     User interaction ->
#     component calls action ->
#     store reacts and triggers ->
#     components update

WidgetActions = Reflux.createActions([
    "addWidget"
    "removeWidget"
    "updateWidgetSettings"
    "moveWidget"
    "startDrag"
    "stopDrag"
    "trashHover"
    "trashUnhover"
    "resizeWidget"
])

UIActions = Reflux.createActions([
    "enterMode"
])

OptionActions = Reflux.createActions([
    "editOption"
])

LibraryActions = Reflux.createActions([
    "addToLibrary"
    "configureWidget"
    "createWidget"
    "removeFromLibrary"
])

GridActions = Reflux.createActions([
    "changeGridOptions"
])

module.exports =
    WidgetActions: WidgetActions
    UIActions: UIActions
    OptionActions: OptionActions
    LibraryActions: LibraryActions
    GridActions: GridActions
