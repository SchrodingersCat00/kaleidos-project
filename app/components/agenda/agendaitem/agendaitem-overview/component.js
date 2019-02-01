import Component from '@ember/component';
import { inject } from '@ember/service';
import { computed } from '@ember/object';
import { alias } from '@ember/object/computed';

export default Component.extend({
	sessionService: inject(),
	currentAgenda: alias('sessionService.currentAgenda'),
	currentSession: null,
	classNames: ["agenda-item-container"],
	tagName: "div",
	isShowingDetail: false,
	agendaitemToShowOptionsFor: null,
	isShowingExtendModal: false,
	currentAgendaItem: null,
	activeAgendaItemSection: 'details',

	isPostPonable: computed('sessionService.agendas', function () {
		let agendas = this.get('sessionService.agendas')
		if (agendas && agendas.length > 1) {
			return true;
		} else {
			return false;
		}
	}),

	lastDefiniteAgenda: computed('sessionService.definiteAgendas', function () {
		return this.get('sessionService.definiteAgendas.firstObject');
	}),

	actions: {
		showDetail() {
			this.set('isShowingDetail', !this.get('isShowingDetail'))
		},

		async toggleModal(agendaitem) {
			if (agendaitem) {
				let postponedToSession = await agendaitem.get('postPonedToSession');
				if (agendaitem.extended) {
					agendaitem.set('extended', false);
					agendaitem.save();
				} else if (postponedToSession) {
					agendaitem.set('postPonedToSession', null);
					agendaitem.save();
				} else {
					this.set('currentAgendaItem', agendaitem);
					this.toggleProperty('isShowingExtendModal');
				}
			}
		},

		async extendAgendaItem(agendaitem) {
			let currentSession = this.get('currentSession');
			if (currentSession) {
				agendaitem.set('postPonedToSession', currentSession);
			} else {
				agendaitem.set('extended', true);
			}

			agendaitem.save().then(() => {
				this.set('currentSession', null);
				this.set('isShowingExtendModal', false);
			});

		},

		chooseSession(session) {
			this.set('currentSession', session);
		},

		deleteItem(agendaitem) {
			agendaitem.destroyRecord().then(() => {
				this.set('agendaitem', null);
			});
		},

		toggleShowMore(agendaitem) {
			if (agendaitem.showDetails) {
				agendaitem.save();
			}
			agendaitem.toggleProperty("showDetails");
		},

		setAgendaItemSection(section) {
			this.set("activeAgendaItemSection", section);
		}
	}
});