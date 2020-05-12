/*global context, it, cy,beforeEach*/
/// <reference types="Cypress" />

import settings  from "../../../../selectors/settings.selectors";
import toolbar from "../../../../selectors/toolbar.selectors";
import modal from "../../../../selectors/modal.selectors";

context('Manage document tests', () => {
  beforeEach(() => {
    cy.server();
    cy.login('Admin');
    cy.visit('/');
    cy.route('/')
  });

  it('Should open the model behind manage document types', () => {
    cy.get(toolbar.settings).click();
    cy.url().should('include','instellingen/overzicht');
    cy.get(settings.manageDocumentTypes).click();
    cy.get(modal.createAnnouncement.modalDialog).should('be.visible');
  });

  it('Should open the model behind manage document types and close it', () => {
    cy.get(toolbar.settings).click();
    cy.url().should('include','instellingen/overzicht');
    cy.get(settings.manageDocumentTypes).click();
    cy.get(modal.createAnnouncement.modalDialog).should('be.visible');
    cy.get(modal.createAnnouncement.modalDialogCloseModal).click();
    cy.get(modal.createAnnouncement.modalDialog).should('not.be.visible');
  });
});
