'use strict'
((define) ->
  define [], ->
    class TAPReporter extends jasmine.Reporter
      constructor: (@print) ->
        @results_ = []
        @count = 0

      getResults: -> @results_

      reportRunnerStarting: (runner) ->
      reportRunnerResults: (runner) ->
        plan = "1..#{@count}"
        @results_.push plan
        @print? plan
      reportSuiteResults: (suite) ->
      reportSpecStarting: (spec) ->
      reportSpecResults: (spec) ->
        @count++
        buf = []
        for item in spec.results().getItems() when item.type is 'log'
          buf.push "# #{item.values[0]}"
        if spec.results().passed()
          buf.push "ok #{@count} - #{spec.getFullName()}"
        else
          buf.push "not ok #{@count} - #{spec.getFullName()}"
          msgs = []
          for item in spec.results().getItems()
            if item.type is 'expect' and !item.passed()
              msgs = msgs.concat item.message.split /\r\n|\r|\n/
          buf.push "# #{msg}" for msg in msgs
        for line in buf
          @results_.push line
          @print? line
      log: (str) ->
        @results_.push "# #{str}"
        @print? "# #{str}"

    TAPReporter

)(if typeof define isnt 'undefined'
  define
else if typeof module isnt 'undefined'
  (deps, factory) -> module.exports = factory()
else
  (deps, factory) -> @['TAPReporter'] = factory()
)
