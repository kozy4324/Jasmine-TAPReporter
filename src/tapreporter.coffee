((define) ->
  define [], ->
    class TAPReporter extends jasmine.Reporter

      constructor: (@print, @color=false) ->
        @results_ = []
        @count = 0

      getResults: -> @results_

      putResult: (result) ->
        @results_.push result
        @print? result

      reportRunnerStarting: (runner) ->

      reportRunnerResults: (runner) ->
        if runner.queue.abort
          @putResult "Bail out! #{runner.__bailOut_reason or ''}"
        else
          @putResult "1..#{@count}"

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
        return if spec.__bailOut
        directive = retrieveTodoDirective spec
        results = spec.results()
        items = results.getItems()
        for item in items when item.type is 'log'
          @putResult "# #{msg}" for msg in item.values[0].split /\r\n|\r|\n/
        if results.skipped
          status = if @color then '\u001b[33mok\u001b[0m' else 'ok'
          @putResult "#{status} #{++@count} - # SKIP #{spec.__skip_reason or ''}"
        else if results.passed()
          status = if @color then '\u001b[36mok\u001b[0m' else 'ok'
          @putResult "#{status} #{++@count} - #{spec.getFullName()}#{directive}"
        else
          status = if @color then '\u001b[31mnot ok\u001b[0m' else 'not ok'
          @putResult "#{status} #{++@count} - #{spec.getFullName()}#{directive}"
          for item in items when item.type is 'expect' and !item.passed()
            @putResult "# #{msg}" for msg in item.message.split /\r\n|\r|\n/

      log: (str...) ->
        messages = str.join "\n"
        @putResult "# #{msg}" for msg in messages.split /\r\n|\r|\n/

      @diag: (env, messages...) ->
        if env?.reporter?.log
          env.reporter.log msg for msg in messages
        else
          messages.unshift env
          jasmine.getEnv().reporter.log msg for msg in messages

      @todo: (target, reason) ->
        target?.__todo_directive = " # TODO #{reason}"

      @skip: (target, reason) ->
        target?.results_?.skipped = true
        target?.__skip_reason = reason

      @bailOut: (env, reason) ->
        [env, reason] = [jasmine.getEnv(), env] unless reason?
        runner = env.currentRunner()
        runner.__bailOut_reason = reason
        runner.queue.abort = true
        for suite in runner.suites()
          suite.queue.abort = true
          spec.queue.abort = true for spec in suite.specs()
        env.currentSpec.__bailOut = true

      @TAPReporter: @

    TAPReporter

)(if typeof define isnt 'undefined'
  define
else if typeof module isnt 'undefined'
  (deps, factory) -> module.exports = factory()
else
  (deps, factory) -> @['TAPReporter'] = factory()
)
