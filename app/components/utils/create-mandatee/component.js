import Component from '@ember/component';
import { inject } from '@ember/service';
import moment from 'moment';

export default Component.extend({
	store: inject(),
	selectedPerson: null,
	selectedDomains: [],
	today: moment().utc().toDate(),
	title: null,

	actions: {
		personSelected(person) {
			this.set('selectedPerson', person);
		},

		selectStartDate(val) {
			this.set('startDate', val);
		},

		chooseDomain(domains) {
			this.set('selectedDomains', domains);
		},

		closeModal() {
			this.closeModal();
		},

		async createMandatee() {
			this.set('isLoading', true);

			const newMandatee = this.store.createRecord('mandatee', {
				title: this.get('title'),
				start: moment(this.get('startDate')).utc().toDate(),
				governmentDomains: this.get('selectedDomains'),
				person: await this.get('selectedPerson'),
				end: null
			});
			newMandatee.save().then(() => {
				this.set('isLoading', false);
				this.clearValues();
			});
		}
	},

	clearValues() {
		this.set('selectedPerson', null);
		this.set('title', null);
		this.set('startDate', null);
		this.set('endDate', null);
		this.set('selectedDomains', []);
	}
});