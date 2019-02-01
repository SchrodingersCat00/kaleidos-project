import Controller from '@ember/controller';
import DefaultQueryParamsMixin from 'ember-data-table/mixins/default-query-params';
import { inject } from '@ember/service';
import { alias } from '@ember/object/computed';

export default Controller.extend(DefaultQueryParamsMixin, {
	agendaService: inject(),
	sessionService: inject(),
	allSubCasesSelected: false,

	selectedAgenda: alias('sessionService.currentAgenda'),

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
			this.get('model').forEach(subCase => {
				subCase.toggleProperty('selected');
			});
			this.toggleProperty('allSubCasesSelected');
		},

		navigateBackToAgenda() {
			// set model null to refresh the model at navigation.
			this.set('model', null);
			this.navigateBack();
		},

		async addSubcasesToAgenda() {
			let selectedAgenda = await this.get('selectedAgenda');
			let itemsToAdd = await this.get('model');
			let promise = Promise.all(itemsToAdd.map(async subCase => {
				if (subCase.selected) {
					await this.get('agendaService').createNewAgendaItem(selectedAgenda, subCase);
				}
			}));
			promise.then(() => {
				this.navigateBack();
			})
		}
	},

	async navigateBack() {
		this.transitionToRoute('agendas');
	}
});