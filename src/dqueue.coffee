Deferred = $?.Deferred or (require 'simply-deferred').Deferred

module.exports = class DeferredQueue
  constructor: ->
    @head = Deferred()
    @cur = @head

  addQueue: (deferred_func) ->
    @cur = @cur.pipe deferred_func

  popStart: ->
    @head.resolve()
    @head = Deferred()
