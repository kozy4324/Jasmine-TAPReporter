jasmine = require 'jasmine-node'
TAPReporter = require '../src/tapreporter.coffee'

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

jasmine.getEnv().addReporter new TAPReporter console.log
jasmine.getEnv().execute()
