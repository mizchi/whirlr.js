DeferredQueue = require '../src/dqueue'
Deferred = (require 'simply-deferred').Deferred
sinon = require 'sinon'

describe 'DeferredQueue', ->
  it 'should be called with order', (done) ->
    f1 = sinon.spy()
    f2 = sinon.spy()

    popupQueue = new DeferredQueue

    popupQueue.addQueue ->
      d = Deferred()
      setTimeout ->
        f1()
        d.resolve()
      , 10
      d.promise()

    popupQueue.addQueue ->
      d = Deferred()
      setTimeout ->
        f2()
        d.resolve()
        sinon.assert.callOrder(f1, f2)
        done()
      , 20
      d.promise()

    popupQueue.popStart()
