'use strict';

import 'animate.css';
import './app.css';

import '@material/mwc-button';
import 'simplemde/dist/simplemde.min.css';

// Require index.html so it gets copied to dist
import './index.html';

import { setupAuth } from './auth';
import { setupEditor } from './view';
import { init } from './service';

const authorizedOrganizations = ['Edlio'];

const Elm = require('./App.elm');
const mountNode = document.getElementById('main');

// The third value on embed are the initial values for incomming ports into Elm
const app = Elm.Main.embed(mountNode);

setupAuth(app, authorizedOrganizations);
setupEditor(app);
init();
