import Component from '@ember/component';

export default Component.extend({
  actions: {
    typeChanged(type) {
      this.typeChanged(type);
    },

    choosePhase(phase) {
      this.phaseChanged(phase);
    }
  }
});
