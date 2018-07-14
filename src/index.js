import 'animate.css';
import './app.css';

// Require index.html so it gets copied to dist
import './index.html';

import FirebaseService from './services/firebase';
import ElmService from './services/elm';
import {NotesDAO} from './dao/firebase';
import {authorizedOrganizations, config} from './configs';

import * as Elm from './App.elm';

// constant configurations

const mountNode = document.getElementById('main');
const app = Elm.Main.embed(mountNode);

const elmService = new ElmService(app);
const firebaseService = new FirebaseService(config);
const db = firebaseService.db;
const notesDAO = new NotesDAO(db);

// routing for events to component and vice versa
elmService.on('jsLogin', () => {
    firebaseService.login(authorizedOrganizations)
        .then(user => {
            elmService.send('jsLoginUser', user);
        })
        .catch(err => {
            console.error(err);
            elmService.send('jsLoginUserFailure', err);
        });
});
elmService.on('jsGetPersonalNotes', dateID => {
    notesDAO.getPersonalNote(dateID.id, dateID.username, data => {
        elmService.send('jsPersonalNote', data || '');
    });
});
elmService.on('jsGetAllNotes', dateID => {
    notesDAO.getAllNotes(dateID.id, notes => {
        if (!notes) return;
        const allNotes = Object.keys(notes)
            .map(name => {
                return notes[name];
            })
            .reduce((accu, note) => {
                return accu + '\n\n\n\n' + note;
            }, '# Stand-up Notes');
        elmService.send('jsAllNotes', allNotes);
    });
});
elmService.on('jsSetPersonalNote', note => {
    console.log(note);
    notesDAO.setPersonalNote(note.id, note.username, note.content);
});

// needing to use window space ecause browser warning about the fullscreen must
// be initiated from the JavaScript click event
window.requestFullScreen = function() {
    const dom = document.querySelector('.slides-container');
    if (!dom) {
        console.error("SELECTOR: \".slides-container\" is not found for full screen request. Skipping.");
        return;
    }
    if(dom.requestFullscreen) {
        dom.requestFullscreen();
    } else if(dom.mozRequestFullScreen) {
        dom.mozRequestFullScreen();
    } else if(dom.webkitRequestFullscreen) {
        dom.webkitRequestFullscreen();
    } else if(dom.msRequestFullscreen) {
        dom.msRequestFullscreen();
    }
};
