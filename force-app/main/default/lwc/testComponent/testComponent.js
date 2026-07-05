import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class TestComponent extends NavigationMixin(LightningElement) {
    connectedCallback() {
        let url = 'https://www.google.com.ar'
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: 'https://www.google.com.ar'
            }
        },false);
        //window.open(url, '_self');
    }
}