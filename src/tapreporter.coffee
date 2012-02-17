'use strict'
((define) ->
  define [], ->
    class TAPReporter extends jasmine.Reporter

      constructor: (@print) ->
        @results_ = []
        @count = 0

      getResults: -> @results_

      putResult: (result) ->
        @results_.push result
        @print? result

      reportRunnerStarting: (runner) ->

      reportRunnerResults: (runner) -> @putResult "1..#{@count}"

      reportSuiteResults: (suite) ->

      reportSpecStarting: (spec) ->
        parent = {parentSuite: spec.suite}
        while (parent = parent.parentSuite)?
          if parent.__skip_reason
            spec.results_.skipped = true
            spec.__skip_reason = parent.__skip_reason

      retrieveTodoDirective = (spec) ->
        return spec.__todo_directive if spec.__todo_directive
        parent = {parentSuite: spec.suite}
        while (parent = parent.parentSuite)?
          return parent.__todo_directive if parent.__todo_directive
        ''

      reportSpecResults: (spec) ->
        directive = retrieveTodoDirective spec
        results = spec.results()
        items = results.getItems()
        @putResult "# #{item.values[0]}" for item in items when item.type is 'log'
        if results.skipped
          @putResult "ok #{++@count} - # SKIP #{spec.__skip_reason or ''}"
        else if results.passed()
          @putResult "ok #{++@count} - #{spec.getFullName()}#{directive}"
        else
          @putResult "not ok #{++@count} - #{spec.getFullName()}#{directive}"
          for item in items when item.type is 'expect' and !item.passed()
            @putResult "# #{msg}" for msg in item.message.split /\r\n|\r|\n/

      log: (str) -> @putResult "# #{str}"

      @diag: (env, str) ->
        [env, str] = [jasmine.getEnv(), env] unless str?
        env?.reporter?.log str

      @todo: (target, reason) ->
        target?.__todo_directive = " # TODO #{reason}"

      @skip: (target, reason) ->
        target?.results_?.skipped = true
        target?.__skip_reason = reason

      @TAPReporter: @

    TAPReporter

)(if typeof define isnt 'undefined'
  define
else if typeof module isnt 'undefined'
  (deps, factory) -> module.exports = factory()
else
  (deps, factory) -> @['TAPReporter'] = factory()
)
