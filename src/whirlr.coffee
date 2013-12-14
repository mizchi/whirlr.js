Deferred = $?.Deferred or (require 'simply-deferred').Deferred

defer = (f) ->
  if requestAnimationFrame?
    requestAnimationFrame f
  else
    setTimeout f, 0

class Whirlr
  constructor: ->
    @queues = []
    @_lock = Deferred().resolve()

  sort: (f) -> @queues.sort f

  stopped: -> @_lock.state() isnt 'resolved'

  stop: -> @unshift (d) ->

  resume: -> defer => @_lock.resolve()

  _next: =>
    if func = @queues.shift()
      if func.length > 0
        @_lock = Deferred().done @_next
        func @_lock
      else
        @_lock = do func
        @_lock.done @_next
    else @resume()

  _startIfReady: ->
    unless @stopped()
      @_lock = Deferred()
      defer @_next

  unshift: (func) ->
    @queues.unshift func
    do @_startIfReady

  add: (func) ->
    @queues.push func
    do @_startIfReady

if module?.exports? then module.exports = Whirlr
else window.Whirlr = Whirlr
