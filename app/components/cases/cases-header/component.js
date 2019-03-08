import Component from '@ember/component';

export default Component.extend({
	classNames:["vlc-page-header"],
	isAddingCase: false,
	actions: {
		toggleAddingCase() {
			this.toggleProperty('isAddingCase');
		}
	}
});
