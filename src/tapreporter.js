(function() {
  'use strict';
  var __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  (function(define) {
    return define([], function() {
      var TAPReporter;
      TAPReporter = (function(_super) {

        __extends(TAPReporter, _super);

        function TAPReporter(print) {
          this.print = print;
          this.results_ = [];
          this.count = 0;
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

        TAPReporter.prototype.reportSpecStarting = function(spec) {};

        TAPReporter.prototype.reportSpecResults = function(spec) {
          var buf, item, line, msg, msgs, _i, _j, _k, _len, _len2, _len3, _ref, _results;
          this.count++;
          buf = [];
          if (spec.results().passed()) {
            buf.push("ok " + this.count + " - " + (spec.getFullName()));
          } else {
            buf.push("not ok " + this.count + " - " + (spec.getFullName()));
            msgs = [];
            _ref = spec.results().getItems();
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              item = _ref[_i];
              if (item.type === 'expect' && !item.passed()) {
                msgs = msgs.concat(item.message.split(/\r\n|\r|\n/));
              }
            }
            for (_j = 0, _len2 = msgs.length; _j < _len2; _j++) {
              msg = msgs[_j];
              buf.push("# " + msg);
            }
          }
          _results = [];
          for (_k = 0, _len3 = buf.length; _k < _len3; _k++) {
            line = buf[_k];
            this.results_.push(line);
            _results.push(typeof this.print === "function" ? this.print(line) : void 0);
          }
          return _results;
        };

        TAPReporter.prototype.log = function(str) {};

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
