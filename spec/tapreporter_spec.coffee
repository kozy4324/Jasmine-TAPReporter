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

jasmine.getEnv().addReporter new TAPReporter console.log
jasmine.getEnv().execute()
