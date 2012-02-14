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
          this.currentSpec = null;
        }

        TAPReporter.prototype.getResults = function() {
          return this.results_;
        };

        TAPReporter.prototype.reportRunnerStarting = function(runner) {};

        TAPReporter.prototype.reportRunnerResults = function(runner) {
          var plan;
          plan = "1.." + this.count;
          this.results_.push(plan);
          return typeof this.print === "function" ? this.print(plan) : void 0;
        };

        TAPReporter.prototype.reportSuiteResults = function(suite) {};

        TAPReporter.prototype.reportSpecStarting = function(spec) {
          var parent, _results;
          this.currentSpec = spec;
          parent = spec.suite;
          _results = [];
          while (parent != null) {
            if (parent.__skip_reason) {
              spec.results_.skipped = true;
              spec.__skip_reason = parent.__skip_reason;
            }
            _results.push(parent = parent.parentSuite);
          }
          return _results;
        };

        retrieveTodoDirective = function(spec) {
          var parent;
          if (spec.__todo_directive) return spec.__todo_directive;
          parent = spec.suite;
          while (parent != null) {
            if (parent.__todo_directive) return parent.__todo_directive;
            parent = parent.parentSuite;
          }
          return '';
        };

        TAPReporter.prototype.reportSpecResults = function(spec) {
          var buf, directive, item, line, msg, msgs, _i, _j, _k, _l, _len, _len2, _len3, _len4, _ref, _ref2;
          this.count++;
          buf = [];
          directive = retrieveTodoDirective(this.currentSpec);
          _ref = spec.results().getItems();
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            item = _ref[_i];
            if (item.type === 'log') buf.push("# " + item.values[0]);
          }
          if (spec.results().skipped) {
            buf.push("ok " + this.count + " - # SKIP " + (spec.__skip_reason || ''));
          } else if (spec.results().passed()) {
            buf.push("ok " + this.count + " - " + (spec.getFullName()) + directive);
          } else {
            buf.push("not ok " + this.count + " - " + (spec.getFullName()) + directive);
            msgs = [];
            _ref2 = spec.results().getItems();
            for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
              item = _ref2[_j];
              if (item.type === 'expect' && !item.passed()) {
                msgs = msgs.concat(item.message.split(/\r\n|\r|\n/));
              }
            }
            for (_k = 0, _len3 = msgs.length; _k < _len3; _k++) {
              msg = msgs[_k];
              buf.push("# " + msg);
            }
          }
          for (_l = 0, _len4 = buf.length; _l < _len4; _l++) {
            line = buf[_l];
            this.results_.push(line);
            if (typeof this.print === "function") this.print(line);
          }
          return this.currentSpec = null;
        };

        TAPReporter.prototype.log = function(str) {
          this.results_.push("# " + str);
          return typeof this.print === "function" ? this.print("# " + str) : void 0;
        };

        TAPReporter.prototype.todo = function(reason, target) {
          target = target || this.currentSpec || jasmine.getEnv().currentSuite || {};
          return target.__todo_directive = " # TODO " + reason;
        };

        TAPReporter.prototype.skip = function(reason, target) {
          target = target || this.currentSpec || jasmine.getEnv().currentSuite || {};
          if (target.results_) target.results_.skipped = true;
          return target.__skip_reason = reason;
        };

        TAPReporter.todo = function(target, reason) {
          if (target == null) target = {};
          return target.__todo_directive = " # TODO " + reason;
        };

        TAPReporter.skip = function(target, reason) {
          if (target == null) target = {};
          if (target.results_) target.results_.skipped = true;
          return target.__skip_reason = reason;
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
