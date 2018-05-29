export function init () {
    const config = {
        apiKey: "AIzaSyBVYU5wYUV-qnk0ne2_rxJCZyFEFxAlEOs",
        authDomain: "standup-notes.firebaseapp.com",
        databaseURL: "https://standup-notes.firebaseio.com",
        projectId: "standup-notes",
        storageBucket: "standup-notes.appspot.com",
        messagingSenderId: "97550210236"
    };
    firebase.initializeApp(config);
}
