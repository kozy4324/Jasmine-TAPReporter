class TAPReporter extends jasmine.Reporter
  constructor: (@oncomplete = (result) ->
    console.log result
    phantom?.exit 0
  ) ->

  reportRunnerResults: (runner) ->
    results = []
    count = 0
    runner.suites().map (suite) ->
      suite.specs().map (spec) ->
        desc = [spec.description]
        suite = spec.suite
        while suite?
          desc.push suite.description
          suite = suite.parentSuite
        description = desc.reverse().join " > "

        count++
        hasError = false
        errorMessages = []
        spec.results().getItems().forEach (result) ->
          if result.type == "expect" and !result.passed()
            errorMessages.push result.trace.stack or result.message
            hasError = true
        if hasError
          results.push "not ok #{count} - #{description}"
          results.push "# "+errorMessages.join("\n").replace(/\n/g, "\n# ")
        else
          results.push "ok #{count} - #{description}"
    results.unshift "1..#{count}"
    # is this format okay?
    window?.setTimeout =>
      @oncomplete(results.join("\n"))
    , 1000

window.TAPReporter = TAPReporter if window?
