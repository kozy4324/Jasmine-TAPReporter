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
        parent = spec.suite
        while parent?
          if parent.__skip_reason
            spec.results_.skipped = true
            spec.__skip_reason = parent.__skip_reason
          parent = parent.parentSuite

      retrieveTodoDirective = (spec) ->
        return spec.__todo_directive if spec.__todo_directive
        parent = spec.suite
        while parent?
          return parent.__todo_directive if parent.__todo_directive
          parent = parent.parentSuite
        return ''

      reportSpecResults: (spec) ->
        @count++
        buf = []
        directive = retrieveTodoDirective spec
        for item in spec.results().getItems() when item.type is 'log'
          buf.push "# #{item.values[0]}"
        if spec.results().skipped
          buf.push "ok #{@count} - # SKIP #{spec.__skip_reason or ''}"
        else if spec.results().passed()
          buf.push "ok #{@count} - #{spec.getFullName()}#{directive}"
        else
          buf.push "not ok #{@count} - #{spec.getFullName()}#{directive}"
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

      @todo: (target={}, reason) ->
        target.__todo_directive = " # TODO #{reason}"

      @skip: (target={}, reason) ->
        if target.results_ # spec
          target.results_.skipped = true
        target.__skip_reason = reason

      @TAPReporter: @

    TAPReporter

)(if typeof define isnt 'undefined'
  define
else if typeof module isnt 'undefined'
  (deps, factory) -> module.exports = factory()
else
  (deps, factory) -> @['TAPReporter'] = factory()
)
