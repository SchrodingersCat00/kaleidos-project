import Component from '@ember/component';
import { computed } from '@ember/object';
import { inject } from '@ember/service';
import moment from 'moment';

export default Component.extend({
	store: inject(),

	dateObjectsToEnable: computed('store', function () {
		return this.store.findAll('meeting', {});
	}),

	actions: {
		selectStartDate(val) {
			this.set('startDate', val);
		},

		async assignToMeeting(subcase) {
			const { startDate, dateObjectsToEnable } = this;
			const meetings = await dateObjectsToEnable;

			const meetingToAssignTo = meetings.find(meeting =>
				moment(meeting.get('plannedStart')).utc().format() == moment(startDate).utc().format());

			const selectedSubcase = this.store.peekRecord('subcase', subcase.get('id'));
			if (selectedSubcase && meetingToAssignTo) {
				selectedSubcase.set('requestedForMeeting', meetingToAssignTo);
				selectedSubcase.save().then(subcase => {
					this.assignSubcasePhase(subcase);
					this.cancel();
				});
			}
		},

		cancel() {
			this.cancel();
		}
	},

	async assignSubcasePhase(subcase) {
		const phasesCodes = await this.store.query('subcase-phase-code', { filter: { label: 'Ingediend voor agendering' } });
		const phaseCode = phasesCodes.get('firstObject');
		if (phaseCode) {
			const phase = this.store.createRecord('subcase-phase', {
				date: moment().utc().toDate(),
				code: phaseCode,
				subcase: subcase
			});
			phase.save();
		}
	}
});
