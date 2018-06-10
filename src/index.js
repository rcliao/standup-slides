import 'animate.css';
import './app.css';

import '@material/mwc-button';
import 'simplemde/dist/simplemde.min.css';

// Require index.html so it gets copied to dist
import './index.html';

import { render as renderEditor, cleanup as cleanupEditor} from './views/editor';
import { render as renderSlides } from './views/slides';
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
            // randomize presentation order
            .map(a => [Math.random(), a])
            .sort((a, b) => a[0] - b[0])
            .map(a => a[1])
            .reduce((accu, note) => {
                return accu + '\n\n\n\n' + note;
            }, '# Stand-up Notes');
        elmService.send('jsAllNotes', allNotes);
    });
});
elmService.on('jsSetPersonalNote', note => {
    notesDAO.setPersonalNote(note.id, note.username, note.content);
});
elmService.on('jsViewChange', viewName => {
    if (viewName === 'Notes') {
        // need animation frame to render after elm is done rendering
        requestAnimationFrame(function () { 
            renderEditor(value => {
                elmService.send('jsPersonalNote', value);
            });
        });
    } else {
        cleanupEditor();
    }
    if (viewName === 'StandUp') {
        requestAnimationFrame(function() {
            renderSlides();
        });
    }
});
window.requestFullScreen = function() {
    const dom = document.querySelector('.reveal');
    if (!dom) {
        console.error("SELECTOR: \".reveal\" is not found for full screen request. Skipping.");
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
