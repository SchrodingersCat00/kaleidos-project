import Mixin from '@ember/object/mixin';
import { inject } from '@ember/service';
import { hash } from 'rsvp';

export default Mixin.create({
	sessionService: inject(),
	agendaService: inject(),

	async parseAgendaItems(agenda, session, definite) {
		const agendaitems = (await agenda.get('agendaitems')).filter((item) => !item.get('subcase.showAsRemark'));

		const announcements = agendaitems.filter((item) => item.get('showAsRemark'))

		const groups = await this.agendaService.newSorting(session, agenda.get('id'));
		const { lastPrio, firstAgendaItem } = await this.agendaService.parseGroups(groups, agendaitems);

		return { groups, firstAgendaItem, announcements, lastPrio };
	},

	async model(params) {
		const definite = params.definite;
		const session = await this.modelFor('print-overviews');
		const agenda = await this.modelFor(`print-overviews.${this.type}`);
		const { groups, announcements, lastPrio } = await this.parseAgendaItems(agenda, session, definite);

		return hash({
			currentAgenda: agenda,
			groups,
			announcements,
			lastPrio,
			meeting: session
		});
	},
});