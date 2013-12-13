# Whirlr

Manage deferred event queues with `lock` and `unlock` control

## Requirements

* jQuery or simply-deferred


## Install

```
$ npm install deferred-runner
```

```
$ bower install deferred-runner
```

## How to use

```
drunner = new Whirlr

# Add 1st queue
drunner.addQueue (d) ->
  console.log 'queue 1'
  setTimeout ->
    d.resolve()
  , 100

# Add 2nd queue
drunner.addQueue (d) ->
  console.log 'queue 2'

  # add queue to last
  drunner.addQueue (d) ->
    console.log 'queue 3'
    d.resolve()
  d.resolve()

# stop runner execution
drunner.lock()
setTimeout ->
  console.log 'start'
  drunner.unlock()
, 100
```

`Result`
```
start
queue 1
queue 2
queue 3
```

## Run test

```
# if you don't install mocha
$ npm install -g mocha
# run tests
$ mocha --compilers coffee:coffee-script --reporter spec
```
