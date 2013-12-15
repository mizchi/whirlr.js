# Whirlr

[![Build Status](https://drone.io/github.com/mizchi/whirlr.js/status.png)](https://drone.io/github.com/mizchi/whirlr.js/latest)

Control sequencial deferred events for with lock and resume.


## Goal

* Wait user input and resume.
* Pool action events after current one
* Handle them with jQuery.Deferred API

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

```coffee-script

whirlr = new Whirlr

# Add 1st queue
whirlr.add (d) ->
  console.log 'queue 1'
  d.resolve()

# Add 2nd queue
whirlr.add (d) ->
  console.log 'queue 2'
  d.resolve()

# stop runner execution
whirlr.stop()
whirlr.resume()
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

## API

### Whirlr#add(function_or_task)

Add function to last for waiting queue.

```coffee-script
whirlr = new Whirlr
whirlr.add (d) -> setTimeout (-> d.resolve()), 100
whirlr.add (d) -> setTimeout (-> d.resolve()), 100
whirlr.add (d) -> setTimeout (-> d.resolve()), 100
```

Use external deferred.

```coffee-script
whirlr = new Whirlr
whirlr.add ->
  Deferred().resolve()
```

Add as task class.

```coffee-script
class MyTask extends Whirlr.Task
  execute: (d)-> d.resolve()
whirlr = new Whirlr
whirlr.add new MyTask
```

### Whirlr#unshift(function_or_task)

Add event queue to head.

(I will rename it...)

```coffee-script
whirlr = new Whirlr
whirlr.add (d) ->
  setTimeout ->
    console.log 'A'
    d.resolve()
  , 100
whirlr.unshift (d) ->
  setTimeout ->
    console.log 'B'
    d.resolve()
  , 100
# B -> A
```

### Whirlr#stop()

Stop whirlr.

```coffee-script
whirlr = new Whirlr
whirlr.add (d) ->
  setTimeout ->
    console.log 'A'
    d.resolve()
  , 100
whirlr.add (d) ->
  setTimeout ->
    console.log 'B'
    d.resolve()
  , 100
whirlr.stop()
whirlr.resume()
console.log whirlr.stopped() #=> true
console.log whirlr.resuming() #=> true
console.log 'C'

# C -> A -> B
```

## Run tests

```
# if you don't install mocha
$ npm install -g mocha

# run tests
$ mocha --compilers coffee:coffee-script --reporter spec
```

## Thanks to:
* Guys at Quipper 
