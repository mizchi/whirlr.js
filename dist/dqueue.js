// Generated by CoffeeScript 1.6.3
(function() {
  var Deferred, DeferredQueue,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Deferred = (typeof $ !== "undefined" && $ !== null ? $.Deferred : void 0) || (require('simply-deferred')).Deferred;

  module.exports = DeferredQueue = (function() {
    function DeferredQueue() {
      this._next = __bind(this._next, this);
      this.queues = [];
      this._lock = Deferred().resolve();
    }

    DeferredQueue.prototype.sort = function(f) {
      return this.queues.sort(f);
    };

    DeferredQueue.prototype.locked = function() {
      return this._lock.state() !== 'resolved';
    };

    DeferredQueue.prototype.lock = function() {
      return this.prependQueue(function(d) {});
    };

    DeferredQueue.prototype.unlock = function() {
      return this._lock.resolve();
    };

    DeferredQueue.prototype._next = function() {
      var deferred_func;
      if (deferred_func = this.queues.shift()) {
        deferred_func(this._lock);
        return this._lock.done(this._next);
      } else {
        return this._lock.resolve();
      }
    };

    DeferredQueue.prototype._startIfReady = function() {
      var _this = this;
      if (!this.locked()) {
        this._lock = Deferred();
        return setTimeout(function() {
          return _this._next();
        }, 0);
      }
    };

    DeferredQueue.prototype.prependQueue = function(deferred_func) {
      this.queues.unshift(deferred_func);
      return this._startIfReady();
    };

    DeferredQueue.prototype.addQueue = function(deferred_func) {
      this.queues.push(deferred_func);
      return this._startIfReady();
    };

    return DeferredQueue;

  })();

}).call(this);