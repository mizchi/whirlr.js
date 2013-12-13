DeferredRunner = require '../src/deferred-runner'
Deferred = (require 'simply-deferred').Deferred
sinon = require 'sinon'
{ok} = require 'assert'

describe 'DeferredRunner', ->
  it 'should be called with order', (done) ->
    f1 = sinon.spy()
    f2 = sinon.spy()

    dqueue = new DeferredRunner
    dqueue.addQueue (d) ->
      f1()
      d.resolve()

    dqueue.addQueue (d) ->
      f2()
      d.resolve()
      done()

    dqueue.lock()
    dqueue.unlock()

  describe '#lock', ->
    it 'should lock event', ->
      dqueue = new DeferredRunner
      dqueue.lock()
      ok dqueue.locked()

  describe '#unlock', ->
    it 'should lock', ->
      dqueue = new DeferredRunner
      dqueue.lock()
      dqueue.unlock()
      ok ! dqueue.locked()

    it 'should restart event', (done) ->
      dqueue = new DeferredRunner
      dqueue.addQueue (d) ->
        d.resolve()
        done()

      dqueue.lock()
      dqueue.unlock()
      ok ! dqueue.locked()

  describe '#addQueue', ->
    it 'should add and start after lock', (done) ->
      dqueue = new DeferredRunner
      dqueue.addQueue (d) ->
        d.resolve()
        done()
      ok dqueue.locked()

    it 'should add queue to last', (done) ->
      f1 = sinon.spy()
      f2 = sinon.spy()
      dqueue = new DeferredRunner
      dqueue.addQueue (d) ->
        f1()
        d.resolve()

      dqueue.addQueue (d) ->
        f2()
        d.resolve()

      dqueue.addQueue (d) ->
        sinon.assert.callOrder(f1, f2)
        d.resolve()
        done()

  describe '#prependQueue', ->
    it 'should prepend queue to head', (done) ->
      f1 = sinon.spy()
      f2 = sinon.spy()
      dqueue = new DeferredRunner

      dqueue.addQueue (d) ->
        f1()
        d.resolve()

      dqueue.prependQueue (d) ->
        f2()
        d.resolve()

      dqueue.addQueue (d) ->
        sinon.assert.callOrder(f2, f1)
        d.resolve()
        done()

  describe '#sort', ->
    it 'should sort by priority', ->
      f1 = sinon.spy()
      f2 = sinon.spy()

      f1_wrapped = (d) ->
        f1()
        d.resolve()
      f1_wrapped.priority = 1

      f2_wrapped = (d) ->
        f2()
        d.resolve()

      f2_wrapped.priority = 5

      dqueue = new DeferredRunner
      dqueue.addQueue f1_wrapped
      dqueue.addQueue f2_wrapped

      resolver = (d) ->
        sinon.assert.callOrder(f2, f1)
        d.resolve()
        done()

      resolver.priority = 0
      dqueue.addQueue resolver

      dqueue.sort (a, b) -> a.priority > b.priority
