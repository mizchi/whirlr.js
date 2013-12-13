# Whirlr

Manage deferred event queues with `stop` and `resume` control

## Requirements

* jQuery or simply-deferred

## Install

```
$ npm install whirlr
```

```
$ bower install whirlr
```

## How to use

```
whirlr = new Whirlr

# Add 1st queue
whirlr.add (d) ->
  console.log 'queue 1'
  setTimeout ->
    d.resolve()
  , 100

# Add 2nd queue
whirlr.add (d) ->
  console.log 'queue 2'

  # add queue to last
  whirlr.add (d) ->
    console.log 'queue 3'
    d.resolve()
  d.resolve()

# stop runner execution
whirlr.stop()
setTimeout ->
  console.log 'start'
  whirlr.resume()
, 100
console.log 'loaded'
```

`Result`
```
loaded
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
