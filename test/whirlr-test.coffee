Whirlr = require '../src/whirlr'
sinon = require 'sinon'
{ok} = require 'assert'

describe 'Whirlr', ->
  it 'should be called with order', (done) ->
    f1 = sinon.spy()
    f2 = sinon.spy()

    whirlr = new Whirlr
    whirlr.add (d) ->
      f1()
      d.resolve()

    whirlr.add (d) ->
      f2()
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
      ok ! whirlr.stopped()

    it 'should restart event', (done) ->
      whirlr = new Whirlr
      whirlr.add (d) ->
        d.resolve()
        done()

      whirlr.stop()
      whirlr.resume()
      ok ! whirlr.stopped()

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
      whirlr.add f1_wrapped
      whirlr.add f2_wrapped

      resolver = (d) ->
        sinon.assert.callOrder(f2, f1)
        d.resolve()
        done()

      resolver.priority = 0
      whirlr.add resolver

      whirlr.sort (a, b) -> a.priority > b.priority
