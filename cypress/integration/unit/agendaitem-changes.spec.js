/*global context, before, it, cy*/
/// <reference types="Cypress" />

context('Agendaitem changes tests', () => {

  before(() => {
    cy.server();
    cy.resetDB();
    cy.login('Admin');
  });

  it('should add an agendaitem to an agenda and should highlight as added', () => {
    const caseTitle = 'testId=' + currentTimestamp() + ': ' + 'Cypress test dossier 1';
    const plusMonths = 1;
    const agendaDate = currentMoment().add('month', plusMonths).set('date', 2).set('hour', 20).set('minute', 20);
    const subcaseTitle1 = caseTitle + ' test stap 1';
    const subcaseTitle2 = caseTitle + ' test stap 2';
    const file = {folder: 'files', fileName: 'test', fileExtension: 'pdf', newFileName: 'test pdf', fileType: 'Nota'};
    const files = [file];
    cy.createCase(false, caseTitle);
    cy.addSubcase('Nota',
      subcaseTitle1,
      'Cypress test voor het testen van toegevoegde documenten',
      'In voorbereiding',
      'Principiële goedkeuring m.h.o. op adviesaanvraag');
    cy.openCase(caseTitle);
    cy.addSubcase('Nota',
      subcaseTitle2,
      'Cypress test voor het testen van toegevoegde agendapunten',
      'In voorbereiding',
      'Principiële goedkeuring m.h.o. op adviesaanvraag');
    cy.createAgenda('Elektronische procedure', plusMonths, agendaDate, 'Zaal oxford bij Cronos Leuven');

    // when toggling show changes  the agendaitem with a document added should show
    cy.openAgendaForDate(agendaDate);
    cy.addAgendaitemToAgenda(subcaseTitle1, false);

    cy.setFormalOkOnAllItems();
    cy.approveDesignAgenda();

    cy.addDocumentsToAgendaItem(subcaseTitle1, files);
    cy.toggleShowChanges(true);
    cy.agendaItemExists(subcaseTitle1);

    // when toggling show changes  the agendaitem added since current agenda should show
    cy.addAgendaitemToAgenda(subcaseTitle2, false);
    cy.toggleShowChanges(true);
    cy.agendaItemExists(subcaseTitle2);

    cy.setFormalOkOnAllItems();
    cy.approveDesignAgenda();

    // when toggling show changes  the agendaitem with a new document version should show
    cy.addNewDocumentVersionToAgendaItem(subcaseTitle1, file.newFileName , file);
    cy.wait(1000); //Computeds are not reloaded yet , maybe 
    cy.toggleShowChanges(true);
    cy.agendaItemExists(subcaseTitle1);

  });
});

function currentMoment() {
  return Cypress.moment();
}

function currentTimestamp() {
  return Cypress.moment().unix();
}