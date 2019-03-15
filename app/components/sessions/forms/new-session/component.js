
import Component from '@ember/component';
import { inject } from '@ember/service';
import $ from 'jquery';

export default Component.extend({
	store: inject(),
	today: new Date(), 

	actions: {
		async createNewSession() {
			let generatedNumber = 4;// generated by fair dice roll, guaranteed to be random
			
			let newMeeting = this.store.createRecord('meeting', {
				plannedStart: this.get('startDate'),
				number: generatedNumber,
				created: new Date()
			});

			newMeeting.save().then(async (meeting) => {
				let agenda = this.store.createRecord('agenda', {
					name: "Ontwerpagenda",
					isFinal: false,
					createdFor: meeting,
          created: new Date()
        });

				await agenda.save();
				await $.get('/session-service/assignNewSessionNumbers');
				this.cancelForm();
			});
		},

		selectStartDate(val) {
			this.set('startDate', val);
		},

		cancelForm(event) {
			this.cancelForm(event);
		},
	}
});
