# jasmine-tapreporter

Jasmine reporter that reports a result in TAP format.

## Usage

```coffeescript
# a.coffee
jasmine = require 'jasmine-node'
TAPReporter = require 'jasmine-tapreporter'

describe "usage of jasmine-tapreporter", ->
  it "should be okay", ->
    expect(true).toBeTruthy()

jasmine.getEnv().addReporter new TAPReporter console.log
jasmine.getEnv().execute()
```

```
$ coffee a.coffee
ok 1 - usage of jasmine-tapreporter should be okay.
1..1
```

### DIRECTIVES

```coffeescript
# b.coffee
jasmine = require 'jasmine-node'
{TAPReporter, todo, skip} = require 'jasmine-tapreporter'

describe "sample of todo", ->
  it "shold have a todo directive", ->
    todo @, "reason of todo"
    expect(true).toBeTruthy()

describe "sample of skip", ->
  it "shold have a skip directive", ->
    skip @, "reason of skip"
    expect(true).toBeTruthy()

jasmine.getEnv().addReporter new TAPReporter console.log
jasmine.getEnv().execute()
```

```
$ coffee b.coffee
ok 1 - sample of todo shold have a todo directive. # TODO reason of todo
ok 2 - # SKIP reason of skip
1..2
```

### Bail out!

```coffeescript
# c.coffee
jasmine = require 'jasmine-node'
{TAPReporter, bailOut} = require 'jasmine-tapreporter'

describe "A first spec", ->
  it "should have a test", ->
    expect(true).toBeTruthy()

describe "A second spec", ->
  it "should have a test", ->
    bailOut "some reason"
    expect(true).toBeTruthy()

jasmine.getEnv().addReporter new TAPReporter console.log
jasmine.getEnv().execute()
```

```
$ coffee c.coffee
ok 1 - A first spec should have a test.
Bail out! some reason
```

### Diagnostics

```coffeescript
# d.coffee
jasmine = require 'jasmine-node'
{TAPReporter, diag} = require 'jasmine-tapreporter'

describe "A spec", ->
  it "should have a test", ->
    diag "Diagnostic line"
    expect(true).toBeTruthy()

jasmine.getEnv().addReporter new TAPReporter console.log
jasmine.getEnv().execute()
```

```
$ coffee d.coffee
# Diagnostic line
ok 1 - A spec should have a test.
1..1
```

## Install

```
npm install jasmine-tapreporter
```
