Deferred = $?.Deferred or (require 'simply-deferred').Deferred

class Whirlr
  constructor: ->
    @queues = []
    @_lock = Deferred().resolve()

  sort: (f) ->
    @queues.sort f

  stopped: -> @_lock.state() isnt 'resolved'

  stop: ->
    @unshift (d) ->

  resume: ->
    @_lock.resolve()

  _next: =>
    if deferred_func = @queues.shift()
      deferred_func @_lock
      @_lock.done @_next
    else
      @_lock.resolve()

  _startIfReady: ->
    unless @stopped()
      @_lock = Deferred()
      setTimeout =>
        @_next()
      , 0

  unshift: (deferred_func) ->
    @queues.unshift deferred_func
    do @_startIfReady

  add: (deferred_func) ->
    @queues.push deferred_func
    do @_startIfReady

if module?.exports? then module.exports = Whirlr
else
  window.Whirlr = Whirlr
