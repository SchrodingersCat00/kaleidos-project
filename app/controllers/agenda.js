import Controller from '@ember/controller';
import { inject } from '@ember/service';
import { alias } from '@ember/object/computed';
import { computed } from '@ember/object';

export default Controller.extend({
	sessionService: inject(),
	queryParams: ['selectedAgenda'],
	selectedAgenda: null,
	creatingNewSession: false,
	selectedAnnouncement: null,
	createAnnouncement: false,
	selectedAgendaItem: null,
	isLoading: false,
	isPrintingDecisions: false,
	currentSession: alias('sessionService.currentSession'),
	agendas: alias('sessionService.agendas'),
	announcements: alias('sessionService.announcements'),
	currentAgenda: alias('sessionService.currentAgenda'),
	currentAgendaItems: alias('sessionService.currentAgendaItems'),

	agendaitemsClass: computed('selectedAgendaItem', 'selectedAnnouncement', 'createAnnouncement', function () {
		if (this.get('selectedAgendaItem') || this.get('selectedAnnouncement') || this.get('createAnnouncement')) {
			return "vlc-panel-layout__agenda-items";
		} else {
			return "vlc-panel-layout-agenda__detail vl-u-spacer-extended";
		}
	}),

	actions: {
		selectAgenda(agenda) {
			this.set('selectedAgendaItem', null);
			this.set("createAnnouncement", false);
			this.set("selectedAnnouncement", null);
			this.set('selectedAgenda', agenda.id);
		},

		navigateToSubCases() {
			this.transitionToRoute('subcases');
		},

		reloadRouteWithNewAgenda(selectedAgendaId) {
			const { currentSession } = this;
			this.transitionToRoute('agenda', currentSession.id, { queryParams: { selectedAgenda: selectedAgendaId } });
			this.send('refresh');
		},

		clearSelectedAgendaItem() {
			this.set("selectedAgendaItem", null);
			this.set("selectedAnnouncement", null);
		},

		navigateToNewAnnouncement(announcement) {
			this.set("createAnnouncement", false);
			this.set("selectedAgendaItem", null);
			this.set("selectedAnnouncement", announcement);
		},

		navigateToCreateAnnouncement() {
			this.set("createAnnouncement", true);
			this.set("selectedAgendaItem", null);
			this.set("selectedAnnouncement", null);
		},

		async printDecisions() {
			const isPrintingDecisions = this.get('isPrintingDecisions');

			if (!isPrintingDecisions) {
				const currentAgendaitems = await this.get('currentAgendaItems');
				let decisions = await Promise.all(currentAgendaitems.map(async item => {
					return await this.store.peekRecord('agendaitem', item.id).get('decision');
				}));
				decisions = decisions.filter(item => !!item);
				this.set('printedDecisions', decisions);
			}

			this.toggleProperty('isPrintingDecisions');
		},

		selectAgendaItem(agendaitem) {
			this.set("createAnnouncement", false);
			this.set("selectedAgendaItem", agendaitem);
			this.set("selectedAnnouncement", null);
		},

		selectAnnouncement(announcement) {
			this.set("createAnnouncement", false);
			this.set("selectedAgendaItem", null);
			this.set("selectedAnnouncement", announcement);
		},

		compareAgendas() {
			this.transitionToRoute('comparison');
		},

		loadingAgendaitems() {
			this.toggleProperty('isLoading');
		}
	}
});
