(function() {
  'use strict';
  var __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  (function(define) {
    return define([], function() {
      var TAPReporter;
      TAPReporter = (function(_super) {
        var retrieveTodoDirective;

        __extends(TAPReporter, _super);

        function TAPReporter(print) {
          this.print = print;
          this.results_ = [];
          this.count = 0;
        }

        TAPReporter.prototype.getResults = function() {
          return this.results_;
        };

        TAPReporter.prototype.putResult = function(result) {
          this.results_.push(result);
          return typeof this.print === "function" ? this.print(result) : void 0;
        };

        TAPReporter.prototype.reportRunnerStarting = function(runner) {};

        TAPReporter.prototype.reportRunnerResults = function(runner) {
          return this.putResult("1.." + this.count);
        };

        TAPReporter.prototype.reportSuiteResults = function(suite) {};

        TAPReporter.prototype.reportSpecStarting = function(spec) {
          var parent, _results;
          parent = {
            parentSuite: spec.suite
          };
          _results = [];
          while ((parent = parent.parentSuite) != null) {
            if (parent.__skip_reason) {
              spec.results_.skipped = true;
              _results.push(spec.__skip_reason = parent.__skip_reason);
            } else {
              _results.push(void 0);
            }
          }
          return _results;
        };

        retrieveTodoDirective = function(spec) {
          var parent;
          if (spec.__todo_directive) return spec.__todo_directive;
          parent = {
            parentSuite: spec.suite
          };
          while ((parent = parent.parentSuite) != null) {
            if (parent.__todo_directive) return parent.__todo_directive;
          }
          return '';
        };

        TAPReporter.prototype.reportSpecResults = function(spec) {
          var directive, item, items, msg, results, _i, _j, _len, _len2, _results;
          directive = retrieveTodoDirective(spec);
          results = spec.results();
          items = results.getItems();
          for (_i = 0, _len = items.length; _i < _len; _i++) {
            item = items[_i];
            if (item.type === 'log') this.putResult("# " + item.values[0]);
          }
          if (results.skipped) {
            return this.putResult("ok " + (++this.count) + " - # SKIP " + (spec.__skip_reason || ''));
          } else if (results.passed()) {
            return this.putResult("ok " + (++this.count) + " - " + (spec.getFullName()) + directive);
          } else {
            this.putResult("not ok " + (++this.count) + " - " + (spec.getFullName()) + directive);
            _results = [];
            for (_j = 0, _len2 = items.length; _j < _len2; _j++) {
              item = items[_j];
              if (item.type === 'expect' && !item.passed()) {
                _results.push((function() {
                  var _k, _len3, _ref, _results2;
                  _ref = item.message.split(/\r\n|\r|\n/);
                  _results2 = [];
                  for (_k = 0, _len3 = _ref.length; _k < _len3; _k++) {
                    msg = _ref[_k];
                    _results2.push(this.putResult("# " + msg));
                  }
                  return _results2;
                }).call(this));
              }
            }
            return _results;
          }
        };

        TAPReporter.prototype.log = function(str) {
          return this.putResult("# " + str);
        };

        TAPReporter.todo = function(target, reason) {
          return target != null ? target.__todo_directive = " # TODO " + reason : void 0;
        };

        TAPReporter.skip = function(target, reason) {
          var _ref;
          if (target != null) {
            if ((_ref = target.results_) != null) _ref.skipped = true;
          }
          return target != null ? target.__skip_reason = reason : void 0;
        };

        TAPReporter.TAPReporter = TAPReporter;

        return TAPReporter;

      })(jasmine.Reporter);
      return TAPReporter;
    });
  })(typeof define !== 'undefined' ? define : typeof module !== 'undefined' ? function(deps, factory) {
    return module.exports = factory();
  } : function(deps, factory) {
    return this['TAPReporter'] = factory();
  });

}).call(this);
