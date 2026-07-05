import { LightningElement, track, wire } from 'lwc';
import { gql, graphql } from 'lightning/uiGraphQLApi';

export default class contactSearch extends LightningElement {
    @track selectedAccountId = '';
    @track searchName = '';
    @track accountOptions = [];
    @track contacts = [];

    columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Email', fieldName: 'Email' },
        { label: 'Phone', fieldName: 'Phone' },
        { label: 'Account Name', fieldName: 'AccountName' }
    ];

    get unifiedQuery() {
        const accountFilter = this.selectedAccountId ? `AccountId: { eq: \"${this.selectedAccountId}\" }` : '';
        const nameFilter = this.searchName ? `Name: { like: \"%${this.searchName}%\" }` : '';
        const combined = [accountFilter, nameFilter].filter(Boolean).join(', ');

        return gql`
            query {
                uiapi {
                    query {
                        Account(first: 50) {
                            edges {
                                node {
                                    Id
                                    Name { value }
                                }
                            }
                        }
                        Contact(${combined ? `where: { ${combined} },` : ''} first: 50) {
                            edges {
                                node {
                                    Id
                                    Name { value }
                                    Email { value }
                                    Phone { value }
                                    Account { Name { value } }
                                }
                            }
                        }
                    }
                }
            }
        `;
    }

    @wire(graphql, { query: '$unifiedQuery' })
    wiredGraphQL({ data, errors }) {
        if (data) {
            const queryData = data.uiapi.query;

            // Accounts
            const accountEdges = queryData.Account?.edges || [];
            this.accountOptions = accountEdges.map(edge => ({
                label: edge.node.Name?.value,
                value: edge.node.Id
            }));

            // Contacts
            const contactEdges = queryData.Contact?.edges || [];
            this.contacts = contactEdges.map(edge => ({
                Id: edge.node.Id,
                Name: edge.node.Name?.value,
                Email: edge.node.Email?.value,
                Phone: edge.node.Phone?.value,
                AccountName: edge.node.Account?.Name?.value
            }));

        } else if (errors) {
            console.error('GraphQL error:', errors);
        }
    }

    handleAccountChange(event) {
        this.selectedAccountId = event.detail.value;
    }

    handleNameChange(event) {
        this.searchName = event.target.value;
    }

    handleClearFilters() {
        this.selectedAccountId = '';
        this.searchName = '';
    }

    get showNoResultsMessage() {
        return this.contacts.length === 0;
    }

    get rawQueryText() {
        const accountFilter = this.selectedAccountId ? `AccountId: { eq: "${this.selectedAccountId}" }` : '';
        const nameFilter = this.searchName ? `Name: { like: "%${this.searchName}%" }` : '';
        const combined = [accountFilter, nameFilter].filter(Boolean).join(', ');

        return `
            query {
                uiapi {
                    query {
                        Account(first: 50) {
                            edges {
                                node {
                                    Id
                                    Name { value }
                                }
                            }
                        }
                        Contact(${combined ? `where: { ${combined} },` : ''} first: 50) {
                            edges {
                                node {
                                    Id
                                    Name { value }
                                    Email { value }
                                    Phone { value }
                                    Account { Name { value } }
                                }
                            }
                        }
                    }
                }
            }
        `.trim();
    }
}