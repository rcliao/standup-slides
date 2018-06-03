import 'animate.css';
import './app.css';

import '@material/mwc-button';
import 'simplemde/dist/simplemde.min.css';

// Require index.html so it gets copied to dist
import './index.html';

import { render as renderEditor, cleanup as cleanupEditor} from './views/editor';
import FirebaseService from './services/firebase';
import ElmService from './services/elm';
import {NotesDAO} from './dao/firebase';
import * as Elm from './App.elm';

// constant configurations
const authorizedOrganizations = ['Edlio'];
const config = {
    apiKey: 'AIzaSyBVYU5wYUV-qnk0ne2_rxJCZyFEFxAlEOs',
    authDomain: 'standup-notes.firebaseapp.com',
    projectId: 'standup-notes'
};

const mountNode = document.getElementById('main');
const app = Elm.Main.embed(mountNode);

const elmService = new ElmService(app);
const firebaseService = new FirebaseService(config);
const db = firebaseService.db;
const notesDAO = new NotesDAO(db);

// routing for events to component and vice versa
elmService.on('login', () => {
    firebaseService.login(authorizedOrganizations)
        .then(user => {
            elmService.send('loginUser', user);
        })
        .catch(err => {
            console.error(err);
            elmService.send('loginUserFailure', err);
        });
});
elmService.on('getNotes', dateID => {
    notesDAO.getPersonalNote(dateID.id, dateID.username, data => {
        console.log(data);
    });
    notesDAO.getAllNotes(dateID.id, notes => {
        if (!notes) return;
        const allNotes = Object.keys(notes).map(name => {
            return notes[name];
        }).reduce((accu, note) => {
            return accu + '\n\n\n' + note;
        }, '');
        elmService.send('allNotes', allNotes);
    });
});
elmService.on('setPersonalNote', note => {
    notesDAO.setPersonalNote(note.id, note.username, note.content);
});
elmService.on('viewChange', viewName => {
    if (viewName === 'Notes') {
        // need animation frame to render after elm is done rendering
        requestAnimationFrame(function () { 
            renderEditor(value => {
                console.log('note change:', value);
                elmService.send('personalNote', value);
            });
        });
    } else {
        cleanupEditor();
    }
});
