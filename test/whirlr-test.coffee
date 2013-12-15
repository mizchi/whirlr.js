Whirlr = require '../src/whirlr'
sinon = require 'sinon'
Deferred = (require 'simply-deferred').Deferred
{ok} = require 'assert'

describe 'Whirlr', ->
  it 'should be called with order', (done) ->
    whirlr = new Whirlr
    whirlr.add (d) -> d.resolve()
    whirlr.add (d) ->
      d.resolve()
      done()

    whirlr.stop()
    whirlr.resume()

  describe '#stop', ->
    it 'should stop event', ->
      whirlr = new Whirlr
      whirlr.stop()
      ok whirlr.stopped()

  describe '#resume', ->
    it 'should stop', ->
      whirlr = new Whirlr
      whirlr.stop()
      whirlr.resume()
      ok whirlr.stopped()

    it 'should restart event', (done) ->
      whirlr = new Whirlr
      whirlr.add (d) ->
        d.resolve()
        done()

      whirlr.stop()
      setTimeout ->
        whirlr.resume()
      , 0

  describe '#add', ->
    it 'should add and start after stop', (done) ->
      whirlr = new Whirlr
      whirlr.add (d) ->
        d.resolve()
        done()
      ok whirlr.stopped()

    it 'should add queue to last', (done) ->
      f1 = sinon.spy()
      f2 = sinon.spy()
      whirlr = new Whirlr
      whirlr.add (d) ->
        f1()
        d.resolve()

      whirlr.add (d) ->
        f2()
        d.resolve()

      whirlr.add (d) ->
        sinon.assert.callOrder(f1, f2)
        d.resolve()
        done()

    it 'should run all without stop', (done) ->
      f1 = sinon.spy()
      f2 = sinon.spy()
      f3 = sinon.spy()
      whirlr = new Whirlr
      whirlr.add (d) ->
        f1()
        d.resolve()

      whirlr.add (d) ->
        f2()
        d.resolve()

      whirlr.add (d) ->
        f3()
        d.resolve()

      setTimeout ->
        ok f1.called
        ok f2.called
        ok f3.called
        done()
      , 10

    it 'should stop after stop', (done) ->
      f1 = sinon.spy()
      f2 = sinon.spy()
      f3 = sinon.spy()
      whirlr = new Whirlr

      whirlr.add (d) ->
        f1()
        d.resolve()

      whirlr.add (d) ->
        f2()

      whirlr.add (d) ->
        f3()

      setTimeout ->
        ok f1.called
        ok f2.called
        ok ! f3.called
        done()
      , 10

    it 'should run without callback', (done) ->
      whirlr = new Whirlr
      whirlr.add ->
        d = Deferred()
        d.done -> done()
        setTimeout ->
          d.resolve()
        , 0
        d

  describe '#unshift', ->
    it 'should prepend queue to head', (done) ->
      f1 = sinon.spy()
      f2 = sinon.spy()
      whirlr = new Whirlr

      whirlr.add (d) ->
        f1()
        d.resolve()

      whirlr.unshift (d) ->
        f2()
        d.resolve()

      whirlr.add (d) ->
        sinon.assert.callOrder(f2, f1)
        d.resolve()
        done()

  describe '#sort', ->
    it 'should sort by priority', (done) ->
      f1 = sinon.spy()
      f1_wrapped = (d) ->
        f1()
        d.resolve()
      f1_wrapped.priority = 1

      f2 = sinon.spy()
      f2_wrapped = (d) ->
        f2()
        d.resolve()
      f2_wrapped.priority = 5

      whirlr = new Whirlr
      whirlr.add f1_wrapped
      whirlr.add f2_wrapped

      resolver = (d) ->
        sinon.assert.callOrder(f2, f1)
        d.resolve()
        done()

      resolver.priority = 0
      whirlr.add resolver

      whirlr.sort (a, b) -> a.priority < b.priority

describe 'Whirlr.Task', ->
  it 'should add as Task', (done) ->
    whirlr = new Whirlr
    class Task extends Whirlr.Task
      execute: (d) ->
        setTimeout ->
          d.resolve()
        , 0
    whirlr.add new Task
    whirlr.add (d) =>
      d.done ->
        done()
      d.resolve()

  it 'should add as Task without calback args', (done) ->
    whirlr = new Whirlr
    class Task extends Whirlr.Task
      execute: ->
        Deferred().resolve()
    whirlr.add new Task
    whirlr.add (d) =>
      d.done ->
        done()
      d.resolve()

  it 'should add as Task without calback args', (done) ->
    f1 = sinon.spy()
    whirlr = new Whirlr
    class Task extends Whirlr.Task
      execute: ->
        d = Deferred()
        d.done -> f1()
    whirlr.add new Task
    whirlr.add (d) => d.resolve()
    setTimeout ->
      ok ! f1.called
      done()
    , 10
