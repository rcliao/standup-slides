import firebase from 'firebase/app';
import 'firebase/auth';
import 'firebase/firestore';

export default class Service {
    constructor (config) {
        firebase.initializeApp(config);
        const settings = {timestampsInSnapshots: true};
        this.db = firebase.firestore();
        this.db.settings(settings);
    }

    login (authorizedOrganizations) {
        return new Promise((resolve, reject) => {
            // IDEA: provider can be statically initialized
            const provider = new firebase.auth.GithubAuthProvider();
            // getting organization for authorization
            provider.addScope('read:org');

            firebase.auth().signInWithPopup(provider).then(function(result) {
                const token = result.credential.accessToken;
                fetch('https://api.github.com/user/orgs', {
                    headers: {
                        'Accept': 'application/vnd.github.moondragon-preview+json',
                        'Authorization': 'token ' + token
                    }
                })
                    .then(resp => resp.json())
                    .then(orgs => {
                        if (!orgs.some(isOrg(authorizedOrganizations))) {
                            // reject error
                            return reject('User is not in the valid Github organization ' + authorizedOrganizations.join(','));
                        }
                        var user = result.user;
                        resolve({
                            id: user.uid,
                            name: user.displayName,
                            photoURL: user.photoURL
                        });
                    });
            }).catch(reject);
        });
    }
}

function isOrg(authorizedOrganizations) {
    return function (org) {
        return authorizedOrganizations.some(authorizedOrg => {
            return org.login.toLowerCase() === authorizedOrg.toLowerCase();
        });
    };
}
