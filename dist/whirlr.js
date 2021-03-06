// Generated by CoffeeScript 1.6.3
(function() {
  var Deferred, Whirlr, defer, _ref,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Deferred = (typeof $ !== "undefined" && $ !== null ? $.Deferred : void 0) || (require('simply-deferred')).Deferred;

  defer = function(f) {
    if (typeof requestAnimationFrame !== "undefined" && requestAnimationFrame !== null) {
      return requestAnimationFrame(f);
    } else {
      return setTimeout(f, 0);
    }
  };

  Whirlr = (function() {
    function Whirlr() {
      this._next = __bind(this._next, this);
      this.clear();
    }

    Whirlr.prototype.sort = function(f) {
      return this.queues.sort(f);
    };

    Whirlr.prototype.stopped = function() {
      return this._lock.state() !== 'resolved';
    };

    Whirlr.prototype.stop = function() {
      return this.unshift(new Whirlr.LockTask);
    };

    Whirlr.prototype.resume = function() {
      var _this = this;
      return defer(function() {
        return _this._lock.resolve();
      });
    };

    Whirlr.prototype._next = function() {
      var func;
      if (func = this.queues.shift()) {
        if (func._execute) {
          func = func._execute.bind(func);
        }
        if (func.length > 0) {
          this._lock = Deferred().done(this._next);
          return func(this._lock);
        } else {
          this._lock = func();
          if (this._lock.then == null) {
            throw 'task does not runnable';
          }
          return this._lock.done(this._next);
        }
      } else {
        return this.done();
      }
    };

    Whirlr.prototype.done = function() {};

    Whirlr.prototype.clear = function() {
      var _ref;
      if ((_ref = this._lock) != null) {
        if (typeof _ref.reject === "function") {
          _ref.reject();
        }
      }
      this.queues = [];
      return this._lock = Deferred().resolve();
    };

    Whirlr.prototype._startIfReady = function() {
      if (!this.stopped()) {
        this._lock = Deferred();
        return defer(this._next);
      }
    };

    Whirlr.prototype.unshift = function(func) {
      this.queues.unshift(func);
      return this._startIfReady();
    };

    Whirlr.prototype.add = function(func) {
      this.queues.push(func);
      return this._startIfReady();
    };

    return Whirlr;

  })();

  Whirlr.Task = (function() {
    function Task() {}

    Task.prototype._execute = function() {
      if (this.execute.length > 0) {
        this.lock = Deferred();
        this.execute(this.lock);
        return this.lock;
      } else {
        return this.lock = this.execute();
      }
    };

    Task.prototype.execute = function() {};

    return Task;

  })();

  Whirlr.LockTask = (function(_super) {
    __extends(LockTask, _super);

    function LockTask() {
      _ref = LockTask.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    LockTask.prototype.execute = function(d) {};

    LockTask.prototype.unlock = function() {
      return this.lock.resolve();
    };

    return LockTask;

  })(Whirlr.Task);

  if ((typeof module !== "undefined" && module !== null ? module.exports : void 0) != null) {
    module.exports = Whirlr;
  } else {
    window.Whirlr = Whirlr;
  }

}).call(this);
