Deferred = $?.Deferred or (require 'simply-deferred').Deferred
class Whirlr
  constructor: ->
    @queues = []
    @_lock = Deferred().resolve()

  sort: (f) -> @queues.sort f

  stopped: -> @_lock.state() isnt 'resolved'

  stop: -> @unshift (d) ->

  resume: -> setTimeout (=> @_lock.resolve()), 0

  _next: =>
    if func = @queues.shift()
      @_lock = Deferred().done @_next
      func @_lock
    else @resume()

  _startIfReady: ->
    unless @stopped()
      @_lock = Deferred()
      setTimeout =>
        @_next()
      , 0

  unshift: (func) ->
    @queues.unshift func
    do @_startIfReady

  add: (deferred_func) ->
    @queues.push deferred_func
    do @_startIfReady

if module?.exports? then module.exports = Whirlr
else window.Whirlr = Whirlr
