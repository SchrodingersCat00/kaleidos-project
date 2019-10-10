import Route from '@ember/routing/route';
import SortedAgendaItemsRouteMixin from 'fe-redpencil/mixins/sorted-agenda-items-route-mixin';

export default Route.extend(SortedAgendaItemsRouteMixin, {
	type: 'decisions',
	include: 'decisions',

	queryParams: {
		definite: { refreshModel: false }
	}
});	