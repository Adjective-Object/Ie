# Ie (家)
A highly customizable & extendable homepage

## Style and Vocabulary

### Import Style
- Group associated imports together in blocks, formatted like so:

    Module         = require("./Module.cjsx")
    LongNameModule = require("./LongNameModule.cjsx")
    ModuleToo      = require("./ModuleToo.cjsx")

- When importing multiple submodules, bind the top level module to
  a local variable, and then reference that for the submodule
  bindings

  Widget = require("./constants.cjsx")
  WidgetHelpers = Widget.helpers

### Naming Conventions
- Stores should be postfixed with the word `Store` (i.e the store
  that tracks which widget is being dragged is called the DragStore)
- `Option` is used to refer to Reflux stores that contain some
  group of user-configurable variables.

