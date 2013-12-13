Whirlr = require '../src/whirlr'
sinon = require 'sinon'
{ok} = require 'assert'

describe 'Whirlr', ->
  it 'should be called with order', (done) ->
    f1 = sinon.spy()
    f2 = sinon.spy()

    whirlr = new Whirlr
    whirlr.addQueue (d) ->
      f1()
      d.resolve()

    whirlr.addQueue (d) ->
      f2()
      d.resolve()
      done()

    whirlr.lock()
    whirlr.unlock()

  describe '#lock', ->
    it 'should lock event', ->
      whirlr = new Whirlr
      whirlr.lock()
      ok whirlr.locked()

  describe '#unlock', ->
    it 'should lock', ->
      whirlr = new Whirlr
      whirlr.lock()
      whirlr.unlock()
      ok ! whirlr.locked()

    it 'should restart event', (done) ->
      whirlr = new Whirlr
      whirlr.addQueue (d) ->
        d.resolve()
        done()

      whirlr.lock()
      whirlr.unlock()
      ok ! whirlr.locked()

  describe '#addQueue', ->
    it 'should add and start after lock', (done) ->
      whirlr = new Whirlr
      whirlr.addQueue (d) ->
        d.resolve()
        done()
      ok whirlr.locked()

    it 'should add queue to last', (done) ->
      f1 = sinon.spy()
      f2 = sinon.spy()
      whirlr = new Whirlr
      whirlr.addQueue (d) ->
        f1()
        d.resolve()

      whirlr.addQueue (d) ->
        f2()
        d.resolve()

      whirlr.addQueue (d) ->
        sinon.assert.callOrder(f1, f2)
        d.resolve()
        done()

  describe '#prependQueue', ->
    it 'should prepend queue to head', (done) ->
      f1 = sinon.spy()
      f2 = sinon.spy()
      whirlr = new Whirlr

      whirlr.addQueue (d) ->
        f1()
        d.resolve()

      whirlr.prependQueue (d) ->
        f2()
        d.resolve()

      whirlr.addQueue (d) ->
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

      whirlr = new Whirlr
      whirlr.addQueue f1_wrapped
      whirlr.addQueue f2_wrapped

      resolver = (d) ->
        sinon.assert.callOrder(f2, f1)
        d.resolve()
        done()

      resolver.priority = 0
      whirlr.addQueue resolver

      whirlr.sort (a, b) -> a.priority > b.priority
