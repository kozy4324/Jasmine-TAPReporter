# jasmine-tapreporter

Jasmine reporter that reports a result in TAP format.

## Usage

```coffeescript
# a.coffee
jasmine = require 'jasmine-node'
Tapreporter = require 'jasmine-tapreporter'

describe "usage of jasmine-tapreporter", ->
  it "should be okay", ->
    expect(true).toBeTruthy()

jasmine.getEnv().addReporter new Tapreporter console.log
jasmine.getEnv().execute()
```

```
$ coffee a.coffee
ok 1 - usage of jasmine-tapreporter should be okay.
1..1
```

## Install

```
npm install jasmine-tapreporter
```
