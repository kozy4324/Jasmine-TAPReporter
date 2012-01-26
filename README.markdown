# jasmine-tapreporter

Jasmine reporter that reports a result in TAP format.

## Usage

```coffeescript
jasmine = require 'jasmine-node'
Tapreporter = require 'jasmine-tapreporter'

describe "usage of jasmine-tapreporter", ->
        it "should be okay!", ->
                expect(true).toBeTruthy()

jasmine.getEnv().addReporter new Tapreporter()
jasmine.getEnv().execute()
```

```
1..1
ok 1 - usage of jasmine-tapreporter > should be okay!
```

## Install

npm install jasmine-tapreporter
