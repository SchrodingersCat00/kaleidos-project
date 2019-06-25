import Controller from '@ember/controller';

export default Controller.extend({
	isAddingNewMinister: false,
	isAddingMandate: false,
	isEditingMandatee: false,
	isManagingAlerts: false,
	isManagingDocumentTypes: false,
	isManagingUsers: false,
	isManagingSubcaseTypes: false,
	isManagingIseCodes: false,
	isManagingFunctions: false,
	isManagingSignature: false,

	actions: {
		toggleProperty(prop) {
			this.toggleProperty(prop);
		},
		async execute(hrId, contexts, hintsRegistry, editor) {
			// update hints in the hints registry
			console.log(hrId, contexts, hintsRegistry, editor)
		}
	
	}
});
