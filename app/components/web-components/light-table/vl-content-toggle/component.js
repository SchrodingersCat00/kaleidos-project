import Component from '@ember/component';
import { computed } from '@ember/object';
import { inject } from '@ember/service';
import moment from 'moment';

export default Component.extend({
	store: inject(),
	classNames: ["vl-checkbox--switch__wrapper"],
	value: null,
	isLoading: false,

	key: computed('row', 'value', 'column', function () {
		return this.column.get('valuePath');
	}),

	async addNewsItem(subcase, agendaitem, value) {
		const news = this.store.createRecord("newsletter-info", {
			subcase: subcase,
			created: moment().utc().toDate(),
			title: await agendaitem.get('shortTitle'),
			subtitle: await agendaitem.get('title'),
      inNewsletter: value
		});
		await news.save();
	},

	actions: {
		async valueChanged(row) {
			const { key } = this;
			this.toggleProperty('isLoading');
			this.toggleProperty('value');

			let itemToUpdate;
			if (key === "forPress") {
				itemToUpdate = row.content;
				itemToUpdate.set(`${this.key}`, (await this.value));
			} else if (key === "subcase.newsletterInfo.inNewsletter") {
				const subcase = await row.content.get('subcase');
				itemToUpdate = await subcase.get('newsletterInfo');
				if (itemToUpdate) {
					itemToUpdate.set(`inNewsletter`, (await this.value));
				} else {
					itemToUpdate = await this.addNewsItem((await row.get('subcase')), row, this.value);
				}
			}
			if (itemToUpdate) {
				await itemToUpdate.save();
				await row.content.reload();
			}
			this.toggleProperty('isLoading');
		}
	}
});