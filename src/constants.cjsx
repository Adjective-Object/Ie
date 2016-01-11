Enum = (lst) ->
    @[f] = f for f in lst
    this

PAGE_MODES = new Enum([
    "LIVE",
    "EDIT",
    "OPTS",
    "LIBR"
])

BKG_MODES = new Enum([
    "BKG_COLOR",
    "BKG_IMG"
])

LOCALES = new Enum([
    "en-US"
])

TIMEZONES = new Enum([
    "EST"
])


module.exports = {
    PAGE_MODES: PAGE_MODES
    BKG_MODES:  BKG_MODES
    LOCALES:    LOCALES
    TIMEZONES:  TIMEZONES
}
