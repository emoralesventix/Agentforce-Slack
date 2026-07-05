import { LightningElement } from 'lwc';

export default class LwcFatalErrorConsoleDemo extends LightningElement {
    throwFatal() {
        throw new Error('FATAL: uncaught error from button click');
    }
}