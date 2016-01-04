React = require("react")

name = require("namehelpers.cjsx")

colorRegex = new RegExp("#[0-9a-fA-F]{3,6}")
mkGenericInput = (inputType) ->
    (fieldName, fieldValue, editOptionCallback) ->
        edit = (event) ->
            editOptionCallback(fieldName, event.target.value)

        <label
            htmlFor={fieldName}
            key={fieldName}>
            {name.legibleVariableName(fieldName)}
            <input type={inputType}
                id={fieldName}
                defaultValue={fieldValue}
                onChange={edit}
                spellCheck={false} />
        </label>

idProcessor = (name, x) -> x

stringOption = {
    validator: (str) -> typeof(str) == 'string'
    processor: idProcessor
    mkInputField: mkGenericInput('text')
}

colorOption = {
    validator: (str) -> colorRegex.test(str)
    processor: idProcessor
    mkInputField: mkGenericInput('text')
}

intOption = {
    validator: (n) -> not isNaN(parseInt(n)) and isFinite(parseInt(n))
    processor: (name, n) -> parseInt n
    mkInputField: mkGenericInput('number') #todo slider
}

imgOption = {
    validator: (val) -> val? # TODO
    processor: (name, base64) -> "url(#{base64})"
    mkInputField: (fieldName, fieldValue, editOptionCallback) ->

        loadAndSignalImage = () ->
            fileList = document.getElementById(fieldName).files
            file = fileList[0]

            reader = new FileReader()
            reader.onload = (e) ->
                editOptionCallback(fieldName, reader.result)

            reader.readAsDataURL(file)

        <label
            htmlFor={fieldName}
            key={fieldName}>
            {name.legibleVariableName(fieldName)}
            <input type='file'
                id={fieldName}
                defaultValue={fieldValue}
                onChange={loadAndSignalImage}
                spellCheck={false} />
        </label>
}

enumeratedOption = (someEnum) ->
    enumKeys = Object.keys(someEnum)
    mkOption = (optName) ->
        <option
            value={optName}
            key={optName}>
            {name.legibleEnumName(optName)}
        </option>

    return {
        validator: (val) -> typeof(val) == "string" and
                val in Object.keys(someEnum)
        processor: idProcessor
        mkInputField: (fieldName, fieldValue, editOptionCallback) ->
            edit = (event) ->
                editOptionCallback(fieldName, event.target.value)

            <label  id={fieldName}
                    key={fieldName}>
                {name.legibleVariableName(fieldName)}
                <select id={fieldName}
                        key={fieldName}
                        name={fieldName}
                        onChange={edit}>
                    {mkOption e for e in enumKeys}
                </select>
            </label>
    }


intRangeOption = (low, high) ->
    validator: (n) ->
        not isNaN(parseFloat(n)) and isFinite(n) and
            low < parseInt(val) <= high
    processor: (name, n) -> parseInt n
    mkInputField: mkGenericInput('text') # todo slider

module.exports = {
    string: stringOption
    img: imgOption
    color: colorOption
    int: intOption
    enumerated: enumeratedOption
    intRange: intRangeOption
}
