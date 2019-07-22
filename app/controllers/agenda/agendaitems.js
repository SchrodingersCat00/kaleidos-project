import Controller from '@ember/controller';
import { computed } from '@ember/object';
import { inject } from '@ember/service';
import { alias } from '@ember/object/computed';

export default Controller.extend({
	queryParams: ["filter"],

	routing: inject('-routing'),
	filter: null,
	sessionService: inject(),
	selectedAgendaItem: alias('sessionService.selectedAgendaItem'),

	agendaitemsClass: computed('routing.currentRouteName', function () {
		const { routing } = this;
		if (routing.get('currentRouteName') === "agenda.agendaitems.agendaitem") {
			return "vlc-panel-layout__agenda-items";
		} else {
			return "vlc-panel-layout-agenda__detail vl-u-bg-porcelain";
		}
	}),
	
	actions: {
		selectAgendaItem(agendaitem) {
			this.set('sessionService.selectedAgendaItem', agendaitem);
			this.transitionToRoute('agenda.agendaitems.agendaitem', agendaitem.get('id'));
		},
		searchAgendaItems(value) {
			this.set('filter', value);
		},
	}
});
