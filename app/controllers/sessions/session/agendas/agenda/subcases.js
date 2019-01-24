import Controller from '@ember/controller';
import DefaultQueryParamsMixin from 'ember-data-table/mixins/default-query-params';

export default Controller.extend(DefaultQueryParamsMixin, {
	allSubCasesSelected: false,

	actions: {
		selectSubCase(subcase, event) {
			if (event) {
				event.stopPropagation();
			}
			if (subcase.selected) {
				subcase.set('selected', false);
			} else {
				subcase.set('selected', true);
			}
		},

		selectAllSubCases() {
			let allSelected = this.get('allSubCasesSelected');
			this.get('model').forEach(subCase => {
				subCase.set('selected', !allSelected);
			});
			this.set('allSubCasesSelected', !allSelected);
		},

		navigateBackToAgenda() {
			this.transitionToRoute('sessions.session.agendas.agenda.agendaitems');
		},

		addSubcasesToAgenda() {
			let selectedAgenda = this.get('selectedAgenda');
			let itemsToAdd = this.get('model');
			itemsToAdd.forEach(async subCase => {
				if (subCase.selected) {
					let agendaitem = this.store.createRecord('agendaitem', {
						extended: false,
						dateAdded: new Date(),
						subcase: subCase,
						agenda: selectedAgenda
					})
					await agendaitem.save()
				}
			});
		}
	}
});