/**
 * @license
 * sinatra.js
 * https://github.com/websperts/sinatra.js
 *
 * Copyright (c) 2014 websperts <hello@websperts.com>
 * Licensed under the MIT license.
 * https://github.com/websperts/sinatra.js/blob/master/LICENSE
 */

;(function(root, factory) {
    if (typeof define === 'function' && define.amd) {
        define(function() {
            return factory(root);
        });
    } else {
        root.sinatra = factory(root);
    }
})(this, function(root, undefined) {

    'use strict';

    var sinatra = {

        routes: {},
        errorCallback: null,
        placeholders: /(:\w+)/gi,

        on: function(request, callback) {
            if (typeof callback === 'function') {
                if (sinatra.placeholders.test(request)) {
                    request = request.replace(sinatra.placeholders, function() {
                        return '([^\/]+)';
                    });
                }
                sinatra.routes[request] = callback;
            }
            return this;
        },

        off: function(request) {
            if (request in sinatra.routes) {
                delete sinatra.routes[request];
            }
            return this;
        },

        error: function(callback) {
            sinatra.errorCallback = callback;
            return this;
        },

        change: function() {
            var matches = (root.location.hash || '#').match('^#\!?(.*)$');
            if (matches) {
                var request = matches[1] || '';
                if (request.length === 0) {
                    request = '/';
                }
                for (var route in sinatra.routes) {
                    var matches = request.match('^' + route + '$');
                    if (matches) {
                        var args = [request];
                        matches.shift();
                        matches.forEach(function(match) {
                            args.push(match);
                        });
                        var handle = sinatra.routes[route];
                        handle.apply(this, args);
                        return;
                    }
                }
                if (typeof sinatra.errorCallback === 'function') {
                    sinatra.errorCallback.apply(this, [request]);
                }
            }
        },

        reset: function() {
            sinatra.routes = {};
        },

        run: function() {
            if (!('onhashchange' in root)) {
                root.setInterval(function() {
                    sinatra.change();
                }, 100);
            } else if (root.addEventListener) {
                root.addEventListener('hashchange', sinatra.change, false);
            } else if (root.attachEvent) {
                root.attachEvent('onhashchange', sinatra.change);
            }
            sinatra.change();
        }

    };

    return sinatra;

});
