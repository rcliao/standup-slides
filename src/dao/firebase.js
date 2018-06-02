export class Store {
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

    getPersonalNote (id, username) {
        return this.storage.collection('notes')
            .doc(id)
            .get()
            .then(doc => {
                return doc[username];
            });
    }

    getAllNotes (id) {
        return this.storage.collection('notes')
            .doc(id)
            .get();
    }
}
