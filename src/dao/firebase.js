export class NotesDAO {
    constructor (storage) {
        this.storage = storage;
    }

    setPersonalNote (id, username, content) {
        const personalNote = {};
        personalNote[username] = content;
        return this.storage.collection('notes')
            .doc(id)
            .set(personalNote, {merge: true});
    }

    getPersonalNote (id, username, cb) {
        return this.storage.collection('notes')
            .doc(id)
            .onSnapshot(doc => {
                cb(doc[username]);
            });
    }

    getAllNotes (id, cb) {
        return this.storage.collection('notes')
            .doc(id)
            .onSnapshot(doc => {
                cb(doc.data());
            });
    }
}
