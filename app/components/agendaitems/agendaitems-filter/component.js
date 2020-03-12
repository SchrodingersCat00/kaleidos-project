import Component from '@ember/component';
import { task, timeout } from 'ember-concurrency';
import moment from 'moment';

export default Component.extend({
	classNames:["vl-form vl-u-spacer-extended-bottom-l"],
	classNameBindings: ["showAdvanced:vlc-box--padding-sides-only", "showAdvanced:vlc-box"],

	showAdvanced: false,
	searchText: null,
	ministerName: null,
	dateFrom: undefined,
	dateTo: undefined,
	announcementsOnly: false,
  popoverShown: false,

  init() {
		this._super(...arguments);

		if(this.dateFrom){
			this.set('dateFrom', moment(this.dateFrom).toDate());
		}
		if(this.dateTo){
			this.set('dateTo', moment(this.dateTo).toDate());
		}

    if (this.ministerName || this.dateFrom || this.dateTo || this.announcementsOnly)
      this.set('showAdvanced', true);
	},

	searchTask: task(function* () {
		yield timeout(600);
		this.filter({
			searchText: this.searchText,
			mandatees: this.ministerName,
			dateFrom: this.dateFrom && moment(this.dateFrom).utc().format(),
			dateTo: this.dateTo && moment(this.dateTo).utc().format(),
			announcementsOnly: this.announcementsOnly
		});
	}).restartable(),

	actions: {
		toggleAdvanced() {
			this.toggleProperty('showAdvanced');
		},
		selectDateFrom(date) {
			this.set('dateFrom', date);
			this.searchTask.perform();
		},
		selectDateTo(date) {
			this.set('dateTo', date);
			this.searchTask.perform();
		},
    openPopover() {
      this.set('popoverShown', true);
    },
    closePopover() {
      this.set('popoverShown', false);
    },
	}
});