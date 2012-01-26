'use strict'
((define) ->
	define [], ->
		class TAPReporter extends jasmine.Reporter
			constructor: (@oncomplete = (result) -> console.log result) ->

			reportRunnerResults: (runner) ->
				results = []
				count = 0
				for suite in runner.suites()
					for spec in suite.specs()
						desc = [spec.description]
						suite = spec.suite
						while suite?
							desc.push suite.description
							suite = suite.parentSuite
						description = desc.reverse().join ' > '

						count++
						hasError = false
						errorMessages = []
						for result in spec.results().getItems()
							if result.type is 'expect' and !result.passed()
								errorMessages.push result.trace.stack or result.message
								hasError = true
						if hasError
							results.push "not ok #{count} - #{description}"
							results.push '# '+errorMessages.join('\n').replace(/\n/g, '\n# ')
						else
							results.push "ok #{count} - #{description}"
				results.unshift "1..#{count}"
				setTimeout? =>
					@oncomplete results.join '\n'
				, 50

		TAPReporter

)(if typeof define isnt 'undefined'
	define
else if typeof module isnt 'undefined'
	(deps, factory) -> module.exports = factory()
else
	(deps, factory) -> @['TAPReporter'] = factory()
)
