import { module, test } from 'qunit';
import { setupTest } from 'ember-qunit';

module('Unit | Route | agenda/agendaitems', function(hooks) {
  setupTest(hooks);

  test('it exists', function(assert) {
    let route = this.owner.lookup('route:agenda/agendaitems');
    assert.ok(route);
  });
});