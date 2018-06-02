export default class Service {
    constructor (app) {
        this.app = app;
    }

    on (eventName, cb) {
        this.app.ports[eventName].subscribe(cb);
    }

    send (eventName, data) {
        this.app.ports[eventName].send(data);
    }
}
