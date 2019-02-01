import EmberRouter from '@ember/routing/router';
import config from './config/environment';

const Router = EmberRouter.extend({
  location: config.locationType,
  rootURL: config.rootURL
});

Router.map(function () {
  this.route('agendas');
  this.route('cases', { path: '/dossiers' }, function () {
    this.route('create');
    this.route('case', { path: ':id' }, function () {
      this.route('subcases', { path: '/deeldossiers' }, function () {
        this.route('create');
        this.route('overview', { path: '' });
        this.route('subcase', { path: ':subcaseId' });
      });
    });
    this.route('overview', { path: '' });
  });
  this.route('comparison');
  this.route('home', { path: "/" });
  this.route('settings');
  this.route('subcases');
  this.route('mock-login');
});

export default Router;