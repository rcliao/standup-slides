'use strict';

import './app.css';

// Require index.html so it gets copied to dist
import './index.html';

const Elm = require('./App.elm');
const mountNode = document.getElementById('main');

// The third value on embed are the initial values for incomming ports into Elm
const app = Elm.Main.embed(mountNode);

app.ports.login.subscribe(function() {
    console.log('trying to login');
    app.ports.loginUser.send('fake-login-user');
});
