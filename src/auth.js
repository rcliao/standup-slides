export function setupAuth (app, authorizedOrganizations) {
    app.ports.login.subscribe(function() {
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
                    app.ports.loginFailure.send('User is not in the valid Github organization ' + authorizedOrganizations.join(','));
                }
                var user = result.user;
                console.log(user);
                app.ports.loginUser.send({
                    name: user.displayName,
                    photoURL: user.photoURL
                });
            });
        }).catch(function(error) {
            console.error(error);
        });
    });
}

function isOrg(authorizedOrganizations) {
    return function (org) {
        return authorizedOrganizations.some(authorizedOrg => {
            return org.login.toLowerCase() === authorizedOrg.toLowerCase();
        });
    };
}
