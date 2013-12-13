Deferred = $?.Deferred or (require 'simply-deferred').Deferred

module.exports = class DeferredRunner
  constructor: ->
    @queues = []
    @_lock = Deferred().resolve()

  sort: (f) ->
    @queues.sort f

  locked: -> @_lock.state() isnt 'resolved'

  lock: ->
    @prependQueue (d) ->

  unlock: ->
    @_lock.resolve()

  _next: =>
    if deferred_func = @queues.shift()
      deferred_func @_lock
      @_lock.done @_next
    else
      @_lock.resolve()

  _startIfReady: ->
    unless @locked()
      @_lock = Deferred()
      setTimeout =>
        @_next()
      , 0

  prependQueue: (deferred_func) ->
    @queues.unshift deferred_func
    do @_startIfReady

  addQueue: (deferred_func) ->
    @queues.push deferred_func
    do @_startIfReady
