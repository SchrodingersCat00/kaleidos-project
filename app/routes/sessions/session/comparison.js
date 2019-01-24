import Route from '@ember/routing/route';

export default Route.extend({
	model() {
		let session = this.modelFor('sessions.session');
		return this.store.query('agenda', {
			filter: {
				session: { id: session.id }
			},
			sort: '-name'
		})
	}
});