import DS from 'ember-data';

const { Model, attr, hasMany, belongsTo } = DS;

export default Model.extend({
	date: attr('date'),
	value: attr('string'),
	remarks: hasMany('remark'),
	translationRequest: belongsTo('translation-request')
});