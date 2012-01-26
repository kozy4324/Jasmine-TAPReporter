(function() {
  'use strict';
  var __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  (function(define) {
    return define([], function() {
      var TAPReporter;
      TAPReporter = (function(_super) {

        __extends(TAPReporter, _super);

        function TAPReporter(oncomplete) {
          this.oncomplete = oncomplete != null ? oncomplete : function(result) {
            return console.log(result);
          };
        }

        TAPReporter.prototype.reportRunnerResults = function(runner) {
          var count, desc, description, errorMessages, hasError, result, results, spec, suite, _i, _j, _k, _len, _len2, _len3, _ref, _ref2, _ref3,
            _this = this;
          results = [];
          count = 0;
          _ref = runner.suites();
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            suite = _ref[_i];
            _ref2 = suite.specs();
            for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
              spec = _ref2[_j];
              desc = [spec.description];
              suite = spec.suite;
              while (suite != null) {
                desc.push(suite.description);
                suite = suite.parentSuite;
              }
              description = desc.reverse().join(' > ');
              count++;
              hasError = false;
              errorMessages = [];
              _ref3 = spec.results().getItems();
              for (_k = 0, _len3 = _ref3.length; _k < _len3; _k++) {
                result = _ref3[_k];
                if (result.type === 'expect' && !result.passed()) {
                  errorMessages.push(result.trace.stack || result.message);
                  hasError = true;
                }
              }
              if (hasError) {
                results.push("not ok " + count + " - " + description);
                results.push('# ' + errorMessages.join('\n').replace(/\n/g, '\n# '));
              } else {
                results.push("ok " + count + " - " + description);
              }
            }
          }
          results.unshift("1.." + count);
          return typeof setTimeout === "function" ? setTimeout(function() {
            return _this.oncomplete(results.join('\n'));
          }, 50) : void 0;
        };

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
