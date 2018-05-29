export function setupAuth (app, validOrgs) {
    app.ports.login.subscribe(function() {
        const provider = new firebase.auth.GithubAuthProvider();
        // getting organization for authorization
        provider.addScope('read:org');

        firebase.auth().signInWithPopup(provider).then(function(result) {
            // This gives you a GitHub Access Token. You can use it to access the GitHub API.
            const token = result.credential.accessToken;
            // TODO: use token to check for organization
            fetch('https://api.github.com/user/orgs', {
                headers: {
                    'Accept': 'application/vnd.github.moondragon-preview+json',
                    'Authorization': 'token ' + token
                }
            })
            .then(resp => resp.json())
            .then(orgs => {
                console.log(orgs);
                if (!orgs.some(isOrg(validOrgs))) {
                    // reject error
                    app.ports.loginFailure.send('User is not in the valid Github organization ' + validOrgs.join(','));
                }
                var user = result.user;
                console.log(user);
                app.ports.loginUser.send(user.displayName);
            });
        }).catch(function(error) {
            console.error(error);
        });
    });
}

