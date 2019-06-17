import DS from 'ember-data';

let { Model, attr, belongsTo, hasMany } = DS;

export default Model.extend({
	text: attr('string'),
	created: attr('date'),
	author: belongsTo('user'),
	agendaitem: belongsTo('agendaitem'),
	answers: hasMany('remark', { polymorphic: true })
});