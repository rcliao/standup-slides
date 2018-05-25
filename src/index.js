'use strict';

import '@webcomponents/webcomponentsjs/webcomponents-bundle';
import 'wired-elements';
import './app.css';

// Require index.html so it gets copied to dist
import './index.html';

const Elm = require('./App.elm');
const mountNode = document.getElementById('main');

// The third value on embed are the initial values for incomming ports into Elm
const app = Elm.Main.embed(mountNode);
