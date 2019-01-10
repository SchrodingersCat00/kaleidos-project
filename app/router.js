import EmberRouter from '@ember/routing/router';
import config from './config/environment';

const Router = EmberRouter.extend({
  location: config.locationType,
  rootURL: config.rootURL
});

Router.map(function() {
  this.route('agenda');
  this.route('files', { path : '/dossiers' });
  this.route('home', { path: '/' });
  this.route('settings');
  this.route('sessions', {path: '/zittingen'});
});

export default Router;
