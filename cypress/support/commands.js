/* eslint-disable no-undef */
import 'cypress-file-upload';


Cypress.Commands.add('login',login);
Cypress.Commands.add('logout',logout);

Cypress.Commands.add('setDateInFlatpickr', setDateInFlatpickr);

Cypress.Commands.add('clickReverseTab', clickReverseTab);
Cypress.Commands.add('clickAgendaitemTab', clickAgendaitemTab);

Cypress.Commands.add('verifyAlertSuccess', verifyAlertSuccess);
Cypress.Commands.add('resetDB', resetDB);


/**
 * Goes to the mock-login page and selects the profile that matches the given name
 *
 * @param {String} name the profile to log in with, case sensitive
 */
function login(name){
  cy.server();
  cy.route('POST', '/mock/sessions').as('mockLogin');
  cy.visit('mock-login');
  cy.get('.grid', { timeout: 12000 }).within(() => {
    cy.contains(name).click()
      .wait('@mockLogin');
  });
}

/**
 * Logs out the current user and end the mocked session
 *
 */
function logout(){
  cy.server();
  cy.route('DELETE', '/mock/sessions/current').as('mockLogout');
  cy.visit('');
  cy.contains('Afmelden', { timeout: 12000 }).click({force: true});
  cy.wait('@mockLogout');
}

/**
 * Sets the date and time in an **open vl-flatpickr**
 *
 * @param {Object} date the Cypress.moment with the date to set
 * @param {number} plusMonths The positive amount of months from today to advance in the vl-flatpickr
 */
function setDateInFlatpickr(date, plusMonths) {
  cy.get('.flatpickr-months').within(() => {
    for (let n = 0; n < plusMonths; n++) {
      cy.get('.flatpickr-next-month').click();
    }
  });
  cy.get('.flatpickr-days').within(() => {
    cy.get('.flatpickr-day').not('.prevMonthDay').not('.nextMonthDay').contains(date.date()).click();
  });
  cy.get('.flatpickr-time').within(() => {
    cy.get('.flatpickr-hour').type(date.hour());
    cy.get('.flatpickr-minute').type(date.minutes());
  });
}

/**
 * Clicks on the specified reverse tab for navigating
 * @if class="vlc-tabs-reverse"
 *
 * @param {String} tabName The name of the tab to click on, case sensitive
 */
function clickReverseTab(tabName){
  cy.get('.vlc-tabs-reverse', { timeout: 12000 }).should('exist').within(() =>{
    // cy.wait(1000);
    cy.contains(tabName).click();
  });
}

/**
 * Clicks on the specified agendaitem tab for navigating
 * @if class="vlc-tabs"
 *
 * @param {String} tabName The name of the tab to click on, case sensitive
 */
function clickAgendaitemTab(tabName){
  cy.get('.vl-tabs', { timeout: 12000 }).should('exist').within(() =>{
    cy.wait(1000); //tabs are not loaded...
    cy.contains(tabName).click();
  });
}

/**
 * Watch if the verification alert popup appears on successful network calls
 * use in a .then() of the sent request
 *
 */
function verifyAlertSuccess() {
  cy.get('.toasts-container', { timeout: 12000 }).contains('Gelukt').should('be.visible');
}

function resetDB() {
  const kaleidosProject = Cypress.env('KALEIDOS_PROJECT');
  const env = {
    COMPOSE_FILE: kaleidosProject + '/docker-compose.yml:' +
      kaleidosProject + '/docker-compose.development.yml:' +
      kaleidosProject + '/docker-compose.test.yml:' +
      kaleidosProject + '/docker-compose.override.yml'
  };

  cy.exec('docker-compose stop triplestore elasticsearch file', { env })
    .exec(`rm -rf ${kaleidosProject}/testdata`)
    .exec(`unzip -o ${kaleidosProject}/testdata.zip -d ${kaleidosProject}`)
    .exec('docker-compose up -d', { env })
    .exec('docker-compose restart cache resource', { env })
    .wait(5000)
}