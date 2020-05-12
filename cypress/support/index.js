// ***********************************************************
// This example support/index.js is processed and
// loaded automatically before your test files.
//
// This is a great place to put global configuration and
// behavior that modifies Cypress.
//
// You can change the location of this file or turn off
// automatically serving support files with the
// 'supportFile' configuration option.
//
// You can read more here:
// https://on.cypress.io/configuration
// ***********************************************************

/*global cy, Cypress*/
/// <reference types="Cypress" />

// Import commands.js using ES2015 syntax:
import './commands'
import './agenda-commands'
import './case-commands'
import './subcase-commands'
import './document-commands'
import './util/utility-commands'

Cypress.on('uncaught:exception', (err, runnable) => {
  return !err.message.includes('calling set on destroyed object')
});

Cypress.Commands.overwrite("type", (originalFn, subject, text, options) => {
  if(!options){
    options = {};
  }
  if(!options.delay){
    options.delay = 1;
  }
  return originalFn(subject, text, options);
});



// workaround for issue DOES NOT WORK!!
// CypressError: Timed out after waiting '60000ms' for your remote page to load.
// Your page did not fire its 'load' event within '60000ms'.
Cypress.on('window:before:load', function (win) {
  const original = win.EventTarget.prototype.addEventListener
  win.EventTarget.prototype.addEventListener = function () {
    if (arguments && arguments[0] === 'beforeunload') {
      return
    }
    return original.apply(this, arguments)
  }

  Object.defineProperty(win, 'onbeforeunload', {
    get: function () { },
    set: function () { }
  })
})

// Alternatively you can use CommonJS syntax:
// require('./commands')
