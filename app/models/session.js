import DS from 'ember-data';

let { Model, attr } = DS;

export default Model.extend({
	plannedstart: attr("date"),
	startedAtTime: attr("date"),
	endedAtTime: attr('date'),
	number: attr('string')
});
