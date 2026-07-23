import { LightningElement, api, wire } from 'lwc';
import getAccountContacts from '@salesforce/apex/AccountController.getAccountContacts';

export default class AccountsCard extends LightningElement {
    /** Id of the Account record (supplied by the record page or parent component). */
    @api recordId;

    contacts = [];
    isLoading = false;
    error;

    @wire(getAccountContacts, { recordId: '$recordId' })
    wiredContacts({ data, error }) {
        if (data) {
            this.contacts = data.map(row => ({
                id:    row.contactId,
                name:  row.name,
                title: row.title,
                role:  row.role,
                link:  '/' + row.contactId
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error?.body?.message ?? 'Unknown error loading contacts.';
            this.contacts = [];
        }
    }

    get hasContacts() {
        return this.contacts && this.contacts.length > 0;
    }

    get hasError() {
        return !!this.error;
    }

    handleExpand() {
        this.dispatchEvent(new CustomEvent('expand'));
    }

    handleAccountClick(event) {
        event.preventDefault();
        const contactId = event.currentTarget.dataset.id;
        this.dispatchEvent(new CustomEvent('accountselect', { detail: { contactId } }));
    }

    handleMenuToggle(event) {
        const contactId = event.currentTarget.dataset.id;
        this.dispatchEvent(new CustomEvent('menutoggle', { detail: { contactId } }));
    }
}