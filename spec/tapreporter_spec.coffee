jasmine = require 'jasmine-node'
{TAPReporter, todo, skip, diag, bailOut} = require '../src/tapreporter.coffee'

describe 'TAPReporter', ->

  [env, tapreporter] = []

  beforeEach ->
    env = new jasmine.Env()
    env.updateInterval = 0
    tapreporter = new TAPReporter()
    env.addReporter tapreporter

  it 'should be defined', ->
    expect(TAPReporter).toBeDefined()

  describe '(in passed test case)', ->

    it 'should have the plan and the test line', ->
      env.describe 'test suite', ->
        env.it 'should be ok', ->
          @expect(true).toBeTruthy()

      env.execute()
      expect(tapreporter.getResults().length).toEqual 2
      expect(tapreporter.getResults()[0]).toEqual 'ok 1 - test suite should be ok.'
      expect(tapreporter.getResults()[1]).toEqual '1..1'

  describe '(in failed test case)', ->

    it 'should have the diff by diagnostic line', ->
      env.describe 'test suite', ->
        env.it 'should be ok', ->
          @expect(false).toBeTruthy()

      env.execute()
      expect(tapreporter.getResults().length).toEqual 3
      expect(tapreporter.getResults()[0]).toEqual 'not ok 1 - test suite should be ok.'
      expect(tapreporter.getResults()[1]).toEqual '# Expected false to be truthy.'
      expect(tapreporter.getResults()[2]).toEqual '1..1'

    it 'should have the useful message for each failed expect', ->

      env.describe 'failed matcher messages', ->
        env.it 'follow this line', ->
          @expect(false).toBe(true)
          @expect({aaa:'bbb'}).toBe({ccc:'ddd'})
        env.it 'follow this line', ->
          @expect(true).toNotBe(true)
          o = {}
          @expect(o).toNotBe(o)
        env.it 'follow this line', ->
          obj = {fn: ->}
          @spyOn obj, 'fn'
          @expect(obj.fn).toHaveBeenCalled()
          obj.fn()
          @expect(obj.fn).not.toHaveBeenCalled()

      env.describe 'runtime error message', ->
        env.it 'follow this line', ->
          undefined.undeclared_function()

      env.describe 'waitsFor timeout error message', ->
        env.it 'follow this line', ->
          @waitsFor((->), 'waitsFor timeout', 1)

      env.execute()
      waits 50
      diag 'waits 50 msec...' # message appear immediately
      # jasmine.log 'waits 50 msec...' # message will appear at reporter.reportSpecResults
      runs ->
        results = tapreporter.getResults()
        expect(results.length).toEqual 14
        expect(results[ 0]).toEqual 'not ok 1 - failed matcher messages follow this line.'
        expect(results[ 1]).toEqual '# Expected false to be true.'
        expect(results[ 2]).toEqual "# Expected { aaa : 'bbb' } to be { ccc : 'ddd' }."
        expect(results[ 3]).toEqual 'not ok 2 - failed matcher messages follow this line.'
        expect(results[ 4]).toEqual '# Expected true to not be true.'
        expect(results[ 5]).toEqual '# Expected {  } to not be {  }.'
        expect(results[ 6]).toEqual 'not ok 3 - failed matcher messages follow this line.'
        expect(results[ 7]).toEqual '# Expected spy fn to have been called.'
        expect(results[ 8]).toEqual '# Expected spy fn not to have been called.'
        expect(results[ 9]).toEqual 'not ok 4 - runtime error message follow this line.'
        expect(results[10]).toEqual "# TypeError: Cannot call method 'undeclared_function' of undefined"
        expect(results[11]).toEqual 'not ok 5 - waitsFor timeout error message follow this line.'
        expect(results[12]).toEqual '# timeout: timed out after 1 msec waiting for waitsFor timeout'
        expect(results[13]).toEqual '1..5'

  describe '#log', ->

    it 'should add a diagnostic line immediately', ->

      env.describe 'test suite', ->
        env.it 'should be ok 1', ->
          @expect(true).toBeTruthy()
        env.it 'should be ok 2', ->
          env.reporter.log "log message 1"
          @expect(true).toBeTruthy()
          env.reporter.log "log message 2"
        env.it 'should be ok 3', ->
          @expect(true).toBeTruthy()

      env.execute()
      expect(tapreporter.getResults().length).toEqual 6
      expect(tapreporter.getResults()[0]).toEqual 'ok 1 - test suite should be ok 1.'
      expect(tapreporter.getResults()[1]).toEqual '# log message 1'
      expect(tapreporter.getResults()[2]).toEqual '# log message 2'
      expect(tapreporter.getResults()[3]).toEqual 'ok 2 - test suite should be ok 2.'
      expect(tapreporter.getResults()[4]).toEqual 'ok 3 - test suite should be ok 3.'
      expect(tapreporter.getResults()[5]).toEqual '1..3'

    it 'should be able to recieve multi-line string', ->

      env.describe 'test suite', ->
        env.it 'should be ok 1', ->
          env.reporter.log """
                           log message 1
                           log message 2
                           log message 3
                           """
          @expect(true).toBeTruthy()

      env.execute()
      expect(tapreporter.getResults().length).toEqual 5
      expect(tapreporter.getResults()[0]).toEqual '# log message 1'
      expect(tapreporter.getResults()[1]).toEqual '# log message 2'
      expect(tapreporter.getResults()[2]).toEqual '# log message 3'
      expect(tapreporter.getResults()[3]).toEqual 'ok 1 - test suite should be ok 1.'
      expect(tapreporter.getResults()[4]).toEqual '1..1'

    it 'should be able to recieve variable arguments', ->

      env.describe 'test suite', ->
        env.it 'should be ok 1', ->
          env.reporter.log "log message 1", "log message 2", "log message 3"
          @expect(true).toBeTruthy()

      env.execute()
      expect(tapreporter.getResults().length).toEqual 5
      expect(tapreporter.getResults()[0]).toEqual '# log message 1'
      expect(tapreporter.getResults()[1]).toEqual '# log message 2'
      expect(tapreporter.getResults()[2]).toEqual '# log message 3'
      expect(tapreporter.getResults()[3]).toEqual 'ok 1 - test suite should be ok 1.'
      expect(tapreporter.getResults()[4]).toEqual '1..1'

  describe 'jasmine.log (Spec.log)', ->

    it 'should add a diagnostic line', ->

      env.describe 'test suite', ->
        env.it 'should be ok 1', ->
          @expect(true).toBeTruthy()
        env.it 'should be ok 2', ->
          @log "log message 1"
          @expect(true).toBeTruthy()
          @log "log message 2"
        env.it 'should be ok 3', ->
          @expect(true).toBeTruthy()

      env.execute()
      expect(tapreporter.getResults().length).toEqual 6
      expect(tapreporter.getResults()[0]).toEqual 'ok 1 - test suite should be ok 1.'
      expect(tapreporter.getResults()[1]).toEqual '# log message 1'
      expect(tapreporter.getResults()[2]).toEqual '# log message 2'
      expect(tapreporter.getResults()[3]).toEqual 'ok 2 - test suite should be ok 2.'
      expect(tapreporter.getResults()[4]).toEqual 'ok 3 - test suite should be ok 3.'
      expect(tapreporter.getResults()[5]).toEqual '1..3'

    it 'should be able to recieve multi-line string', ->

      env.describe 'test suite', ->
        env.it 'should be ok 1', ->
          @log """
               log message 1
               log message 2
               log message 3
               """
          @expect(true).toBeTruthy()

      env.execute()
      expect(tapreporter.getResults().length).toEqual 5
      expect(tapreporter.getResults()[0]).toEqual '# log message 1'
      expect(tapreporter.getResults()[1]).toEqual '# log message 2'
      expect(tapreporter.getResults()[2]).toEqual '# log message 3'
      expect(tapreporter.getResults()[3]).toEqual 'ok 1 - test suite should be ok 1.'
      expect(tapreporter.getResults()[4]).toEqual '1..1'

    it 'can not recieve variable arguments', ->

      env.describe 'test suite', ->
        env.it 'should be ok 1', ->
          @log "log message 1", "log message 2", "log message 3"
          @expect(true).toBeTruthy()

      env.execute()
      expect(tapreporter.getResults().length).toEqual 3
      expect(tapreporter.getResults()[0]).toEqual '# log message 1'
      expect(tapreporter.getResults()[1]).toEqual 'ok 1 - test suite should be ok 1.'
      expect(tapreporter.getResults()[2]).toEqual '1..1'

  describe '::diag', ->

    it 'should add a diagnostic line immediately', ->

      # TAPReporter::diag is a wrapper for jasmine.getEnv().reporter.log function.
      # if a second argument is ommitted, the first argument will be assumed a message
      # string and will be added to current env.
      env.describe 'test suite', ->
        env.it 'should be ok 1', ->
          @expect(true).toBeTruthy()
        env.it 'should be ok 2', ->
          diag env, "log message 1"
          diag "[log mesasge 1]"
          @expect(true).toBeTruthy()
          diag env, "log message 2"
          diag "[log mesasge 2]"
        env.it 'should be ok 3', ->
          @expect(true).toBeTruthy()

      env.execute()
      expect(tapreporter.getResults().length).toEqual 6
      expect(tapreporter.getResults()[0]).toEqual 'ok 1 - test suite should be ok 1.'
      expect(tapreporter.getResults()[1]).toEqual '# log message 1'
      expect(tapreporter.getResults()[2]).toEqual '# log message 2'
      expect(tapreporter.getResults()[3]).toEqual 'ok 2 - test suite should be ok 2.'
      expect(tapreporter.getResults()[4]).toEqual 'ok 3 - test suite should be ok 3.'
      expect(tapreporter.getResults()[5]).toEqual '1..3'

    it 'should be able to recieve multi-line string', ->

      env.describe 'test suite', ->
        env.it 'should be ok 1', ->
          diag env, """
                  log message 1
                  log message 2
                  log message 3
                  """
          diag """
               [log message 1]
               [log message 2]
               [log message 3]
               """
          @expect(true).toBeTruthy()

      env.execute()
      expect(tapreporter.getResults().length).toEqual 5
      expect(tapreporter.getResults()[0]).toEqual '# log message 1'
      expect(tapreporter.getResults()[1]).toEqual '# log message 2'
      expect(tapreporter.getResults()[2]).toEqual '# log message 3'
      expect(tapreporter.getResults()[3]).toEqual 'ok 1 - test suite should be ok 1.'
      expect(tapreporter.getResults()[4]).toEqual '1..1'

    it 'should be able to recieve variable arguments', ->

      env.describe 'test suite', ->
        env.it 'should be ok 1', ->
          diag env, "log message 1", "log message 2", "log message 3"
          diag "[log message 1]", "[log message 2]", "[log message 3]"
          @expect(true).toBeTruthy()

      env.execute()
      expect(tapreporter.getResults().length).toEqual 5
      expect(tapreporter.getResults()[0]).toEqual '# log message 1'
      expect(tapreporter.getResults()[1]).toEqual '# log message 2'
      expect(tapreporter.getResults()[2]).toEqual '# log message 3'
      expect(tapreporter.getResults()[3]).toEqual 'ok 1 - test suite should be ok 1.'
      expect(tapreporter.getResults()[4]).toEqual '1..1'

  describe '::todo', ->

    it 'should mark [TODO DIRECTIVE] on current spec', ->
      env.describe 'test suite', ->
        env.it 'should be ok', ->
        env.it 'should be ok', ->
          todo @, 'reason 1'
          @expect(true).toBeTruthy()
        env.it 'should be ok', ->
        env.it 'should be not ok', ->
          todo @, 'reason 2'
          @expect(false).toBeTruthy()
        env.it 'should be ok', ->

      env.execute()
      expect(tapreporter.getResults().length).toEqual 7
      expect(tapreporter.getResults()[0]).toEqual 'ok 1 - test suite should be ok.'
      expect(tapreporter.getResults()[1]).toEqual 'ok 2 - test suite should be ok. # TODO reason 1'
      expect(tapreporter.getResults()[2]).toEqual 'ok 3 - test suite should be ok.'
      expect(tapreporter.getResults()[3]).toEqual 'not ok 4 - test suite should be not ok. # TODO reason 2'
      expect(tapreporter.getResults()[4]).toEqual '# Expected false to be truthy.'
      expect(tapreporter.getResults()[5]).toEqual 'ok 5 - test suite should be ok.'
      expect(tapreporter.getResults()[6]).toEqual '1..5'

    it 'should mark [TODO DIRECTIVE] on current suite', ->
      env.describe 'test suite 1', ->
        env.it 'should be ok 1', ->
      env.describe 'test suite 2', ->
        todo @, 'reason'
        env.it 'should be ok 1', ->
        env.it 'should be ok 2', ->
        env.it 'should be ok 3', ->
      env.describe 'test suite 3', ->
        env.it 'should be ok 1', ->

      env.execute()
      expect(tapreporter.getResults().length).toEqual 6
      expect(tapreporter.getResults()[0]).toEqual 'ok 1 - test suite 1 should be ok 1.'
      expect(tapreporter.getResults()[1]).toEqual 'ok 2 - test suite 2 should be ok 1. # TODO reason'
      expect(tapreporter.getResults()[2]).toEqual 'ok 3 - test suite 2 should be ok 2. # TODO reason'
      expect(tapreporter.getResults()[3]).toEqual 'ok 4 - test suite 2 should be ok 3. # TODO reason'
      expect(tapreporter.getResults()[4]).toEqual 'ok 5 - test suite 3 should be ok 1.'
      expect(tapreporter.getResults()[5]).toEqual '1..5'

    it 'should mark [TODO DIRECTIVE] on nestesd suite', ->
      env.describe 'test suite 1', ->
        env.it 'should be ok 1', ->
      env.describe 'test suite 2', ->
        todo @, 'reason'
        env.it 'should be ok 1', ->
        env.describe 'test suite 2 nested', ->
          env.it 'should be ok 1', ->
        env.it 'should be ok 2', ->
      env.describe 'test suite 3', ->
        env.it 'should be ok 1', ->

      env.execute()
      results = tapreporter.getResults()
      expect(results.length).toEqual 6
      expect(results[0]).toEqual 'ok 1 - test suite 1 should be ok 1.'
      expect(results[1]).toEqual 'ok 2 - test suite 2 should be ok 1. # TODO reason'
      expect(results[2]).toEqual 'ok 3 - test suite 2 test suite 2 nested should be ok 1. # TODO reason'
      expect(results[3]).toEqual 'ok 4 - test suite 2 should be ok 2. # TODO reason'
      expect(results[4]).toEqual 'ok 5 - test suite 3 should be ok 1.'
      expect(results[5]).toEqual '1..5'

  describe '::skip', ->

    it 'should mark [SKIP DIRECTIVE] on current spec', ->
      env.describe 'test suite', ->
        env.it 'should be ok', ->
        env.it 'should be ok', ->
          skip @, 'reason 1'
        env.it 'should be ok', ->
        env.it 'should be not ok', ->
          skip @, 'reason 2'
        env.it 'should be ok', ->

      env.execute()
      expect(tapreporter.getResults().length).toEqual 6
      expect(tapreporter.getResults()[0]).toEqual 'ok 1 - test suite should be ok.'
      expect(tapreporter.getResults()[1]).toEqual 'ok 2 - # SKIP reason 1'
      expect(tapreporter.getResults()[2]).toEqual 'ok 3 - test suite should be ok.'
      expect(tapreporter.getResults()[3]).toEqual 'ok 4 - # SKIP reason 2'
      expect(tapreporter.getResults()[4]).toEqual 'ok 5 - test suite should be ok.'
      expect(tapreporter.getResults()[5]).toEqual '1..5'

    it 'should mark [SKIP DIRECTIVE] on current suite', ->
      env.describe 'test suite 1', ->
        env.it 'should be ok 1', ->
      env.describe 'test suite 2', ->
        skip @, 'reason'
        env.it 'should be ok 1', ->
        env.it 'should be ok 2', ->
        env.it 'should be ok 3', ->
      env.describe 'test suite 3', ->
        env.it 'should be ok 1', ->

      env.execute()
      expect(tapreporter.getResults().length).toEqual 6
      expect(tapreporter.getResults()[0]).toEqual 'ok 1 - test suite 1 should be ok 1.'
      expect(tapreporter.getResults()[1]).toEqual 'ok 2 - # SKIP reason'
      expect(tapreporter.getResults()[2]).toEqual 'ok 3 - # SKIP reason'
      expect(tapreporter.getResults()[3]).toEqual 'ok 4 - # SKIP reason'
      expect(tapreporter.getResults()[4]).toEqual 'ok 5 - test suite 3 should be ok 1.'
      expect(tapreporter.getResults()[5]).toEqual '1..5'

    it 'should mark [SKIP DIRECTIVE] on nestesd suite', ->
      env.describe 'test suite 1', ->
        env.it 'should be ok 1', ->
      env.describe 'test suite 2', ->
        skip @, 'reason'
        env.it 'should be ok 1', ->
        env.describe 'test suite 2 nested', ->
          env.it 'should be ok 1', ->
        env.it 'should be ok 2', ->
      env.describe 'test suite 3', ->
        env.it 'should be ok 1', ->

      env.execute()
      results = tapreporter.getResults()
      expect(results.length).toEqual 6
      expect(results[0]).toEqual 'ok 1 - test suite 1 should be ok 1.'
      expect(results[1]).toEqual 'ok 2 - # SKIP reason'
      expect(results[2]).toEqual 'ok 3 - # SKIP reason'
      expect(results[3]).toEqual 'ok 4 - # SKIP reason'
      expect(results[4]).toEqual 'ok 5 - test suite 3 should be ok 1.'
      expect(results[5]).toEqual '1..5'

  describe '::bailOut', ->

    it 'should be [Bail out!] and stop the test execution immediately', ->
      env.describe 'test suite 1', ->
        env.it 'should be ok 1', ->
      env.describe 'test suite 2', ->
        env.it 'should be ok 1', ->
          bailOut env, 'reason'
        env.it 'should be ok 2', ->
      env.describe 'test suite 3', ->
        env.it 'should be ok 1', ->

      env.execute()
      results = tapreporter.getResults()
      expect(results.length).toEqual 2
      expect(results[0]).toEqual 'ok 1 - test suite 1 should be ok 1.'
      expect(results[1]).toEqual 'Bail out! reason'

  describe 'console color enable', ->
    [env, tapreporter] = []

    beforeEach ->
      env = new jasmine.Env()
      env.updateInterval = 0
      tapreporter = new TAPReporter(null, true)
      env.addReporter tapreporter

    it 'should effect passwd line', ->
      env.describe 'test suite', ->
        env.it 'should be ok', ->
          @expect(true).toBeTruthy()

      env.execute()
      #expect(tapreporter.getResults()[0]).toEqual '\033[36mok\033[0m 1 - test suite should be ok.'

    it 'should effect skipped line', ->
      env.describe 'test suite', ->
        env.it 'should be ok', ->
          skip @, 'reason 1'

      env.execute()
      #expect(tapreporter.getResults()[0]).toEqual '\033[33mok\033[0m 1 - # SKIP reason 1'

    it 'should effect failed line', ->
      env.describe 'test suite', ->
        env.it 'should be ok', ->
          @expect(false).toBeTruthy()

      env.execute()
      #expect(tapreporter.getResults()[0]).toEqual '\033[31mnot ok\033[0m 1 - test suite should be ok.'

jasmine.getEnv().addReporter new TAPReporter console.log, true
jasmine.getEnv().execute()
