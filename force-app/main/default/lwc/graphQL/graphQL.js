import { LightningElement, wire, track } from 'lwc';
import { gql, graphql } from 'lightning/uiGraphQLApi';

// GraphQL Data Table Component

export default class GraphqlMultipleObjects extends LightningElement {
    @track industryFilter = '';
    @track minEmployees = 0;
    @track maxEmployees = 10000;
    
    // Data for datatable
    allAccounts = [];
    errors = undefined;
    
    // Pagination properties
    @track after = null;
    @track pageNumber = 1;
    @track pageSize = 5;
    @track totalCount = 0;
    @track endCursor = null;
    @track hasNextPage = false;
    @track hasPreviousPage = false;
    
    // Industry options for dropdown with exact possible values
    industryOptions = [
        { label: 'All Industries', value: '' },
        { label: 'Agriculture', value: 'Agriculture' },
        { label: 'Apparel', value: 'Apparel' },
        { label: 'Banking', value: 'Banking' },
        { label: 'Biotechnology', value: 'Biotechnology' },
        { label: 'Chemicals', value: 'Chemicals' },
        { label: 'Communications', value: 'Communications' },
        { label: 'Construction', value: 'Construction' },
        { label: 'Consulting', value: 'Consulting' },
        { label: 'Education', value: 'Education' },
        { label: 'Electronics', value: 'Electronics' },
        { label: 'Energy', value: 'Energy' },
        { label: 'Engineering', value: 'Engineering' },
        { label: 'Entertainment', value: 'Entertainment' },
        { label: 'Environmental', value: 'Environmental' },
        { label: 'Finance', value: 'Finance' },
        { label: 'Food & Beverage', value: 'Food & Beverage' },
        { label: 'Government', value: 'Government' },
        { label: 'Healthcare', value: 'Healthcare' },
        { label: 'Hospitality', value: 'Hospitality' },
        { label: 'Insurance', value: 'Insurance' },
        { label: 'Machinery', value: 'Machinery' },
        { label: 'Manufacturing', value: 'Manufacturing' },
        { label: 'Media', value: 'Media' },
        { label: 'Not For Profit', value: 'Not For Profit' },
        { label: 'Recreation', value: 'Recreation' },
        { label: 'Retail', value: 'Retail' },
        { label: 'Shipping', value: 'Shipping' },
        { label: 'Technology', value: 'Technology' },
        { label: 'Telecommunications', value: 'Telecommunications' },
        { label: 'Transportation', value: 'Transportation' },
        { label: 'Utilities', value: 'Utilities' },
        { label: 'Other', value: 'Other' }
    ];
    
    // Columns for tree grid (shared by Account parent rows and Contact child rows)
    columns = [
        { 
            label: 'Name', 
            fieldName: 'Name', 
            type: 'text',
            cellAttributes: { alignment: 'left' }
        },
        { 
            label: 'Phone', 
            fieldName: 'Phone', 
            type: 'phone' 
        },
        { 
            label: 'Industry', 
            fieldName: 'Industry', 
            type: 'text' 
        },
        { 
            label: 'Employees', 
            fieldName: 'NumberOfEmployees', 
            type: 'number' 
        },
        { 
            label: 'City', 
            fieldName: 'BillingCity', 
            type: 'text' 
        },
        { 
            label: 'State', 
            fieldName: 'BillingState', 
            type: 'text' 
        },
        { 
            label: 'Birthday', 
            fieldName: 'Birthday', 
            type: 'text'
        }
    ];

    // Contact columns for child records
    contactColumns = [
        { 
            label: 'Contact Name', 
            fieldName: 'Name', 
            type: 'text',
            cellAttributes: { alignment: 'left' }
        },
        { 
            label: 'Title', 
            fieldName: 'Title', 
            type: 'text' 
        },
        { 
            label: 'Email', 
            fieldName: 'Email', 
            type: 'email' 
        },
        { 
            label: 'Phone', 
            fieldName: 'Phone', 
            type: 'phone' 
        },
        { 
            label: 'Birthday', 
            fieldName: 'Birthday', 
            type: 'text'
        }
    ];

    // GraphQL query with industry and employee filters + pagination
    @wire(graphql, {
        query: gql`
            query getAccounts($industryFilter: Picklist!, $minEmployees: Int!, $maxEmployees: Int!, $after: String) {
                uiapi {
                    query {
                        Account(
                            first: 5
                            after: $after
                            where: {
                                and: [
                                    { Industry: { like: $industryFilter } }
                                    { NumberOfEmployees: { gte: $minEmployees } }
                                    { NumberOfEmployees: { lte: $maxEmployees } }
                                ]
                            }
                        ) {
                            edges {
                                node {
                                    Id
                                    Name {
                                        value
                                    }
                                    Phone {
                                        value
                                    }
                                    Industry {
                                        value
                                    }
                                    NumberOfEmployees {
                                        value
                                    }
                                    BillingCity {
                                        value
                                    }
                                    BillingState {
                                        value
                                    }
                                    Contacts(first: 5) {
                                        edges {
                                            node {
                                                Id
                                                Name {
                                                    value
                                                }
                                                Email {
                                                    value
                                                }
                                                Phone {
                                                    value
                                                }
                                                Title {
                                                    value
                                                }
                                                Birthdate {
                                                    value
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            pageInfo {
                                hasNextPage
                                hasPreviousPage
                                startCursor
                                endCursor
                            }
                            totalCount
                        }
                    }
                }
            }
        `,
        variables: '$variables'
    })
    // Helper method to format birthdate or return "not informed"
    formatBirthday(birthdate) {
        if (!birthdate || !birthdate.value) {
            return 'not informed';
        }
        // Format date as "MMM DD, YYYY" (e.g., "Jan 15, 1990")
        const date = new Date(birthdate.value);
        if (isNaN(date.getTime())) {
            return 'not informed';
        }
        return date.toLocaleDateString('en-US', { 
            year: 'numeric', 
            month: 'short', 
            day: '2-digit' 
        });
    }

    graphqlQuery({ data, errors }) {
        console.log('GraphQL Query Result:', { data, errors });
        
        this.errors = errors;
        if (errors) {
            console.error('GraphQL Errors:', errors);
            this.allAccounts = [];
            this.totalCount = 0;
            return;
        }
        
        if (!data || !data.uiapi || !data.uiapi.query || !data.uiapi.query.Account) {
            console.log('No data structure found');
            this.allAccounts = [];
            this.totalCount = 0;
            this.hasNextPage = false;
            this.hasPreviousPage = false;
            this.endCursor = null;
            return;
        }
        
        const accountData = data.uiapi.query.Account;
        
        if (!accountData.edges || accountData.edges.length === 0) {
            console.log('No edges found in Account data');
            this.allAccounts = [];
            this.totalCount = accountData.totalCount || 0;
            const pageInfo = accountData.pageInfo || {};
            this.hasNextPage = pageInfo.hasNextPage || false;
            this.hasPreviousPage = pageInfo.hasPreviousPage || false;
            this.endCursor = pageInfo.endCursor || null;
            return;
        }
        
        try {
            this.allAccounts = accountData.edges.map((edge) => {
                const node = edge.node;
                return {
                    Id: node.Id,
                    Name: node.Name?.value || '',
                    Phone: node.Phone?.value || '',
                    Industry: node.Industry?.value || '',
                    NumberOfEmployees: node.NumberOfEmployees?.value || 0,
                    BillingCity: node.BillingCity?.value || '',
                    BillingState: node.BillingState?.value || '',
                    Birthday: 'not informed', // Accounts don't have Birthdate
                    Contacts: (node.Contacts?.edges || []).map(contactEdge => {
                        const contactNode = contactEdge.node;
                        let birthdayValue = 'not informed';
                        if (contactNode.Birthdate && contactNode.Birthdate.value) {
                            try {
                                const date = new Date(contactNode.Birthdate.value);
                                if (!isNaN(date.getTime())) {
                                    birthdayValue = date.toLocaleDateString('en-US', { 
                                        year: 'numeric', 
                                        month: 'short', 
                                        day: '2-digit' 
                                    });
                                }
                            } catch (e) {
                                console.warn('Error formatting birthday:', e);
                            }
                        }
                        return {
                            Id: contactNode.Id,
                            Name: contactNode.Name?.value || '',
                            Email: contactNode.Email?.value || '',
                            Phone: contactNode.Phone?.value || '',
                            Title: contactNode.Title?.value || '',
                            Birthday: birthdayValue
                        };
                    })
                };
            });
            
            // Update pagination info
            this.totalCount = accountData.totalCount || 0;
            const pageInfo = accountData.pageInfo || {};
            this.hasNextPage = pageInfo.hasNextPage || false;
            this.hasPreviousPage = pageInfo.hasPreviousPage || false;
            this.endCursor = pageInfo.endCursor || null;
            
            console.log('Processed Accounts:', this.allAccounts);
            console.log('Pagination Info:', {
                totalCount: this.totalCount,
                hasNextPage: this.hasNextPage,
                hasPreviousPage: this.hasPreviousPage,
                endCursor: this.endCursor
            });
        } catch (error) {
            console.error('Error processing accounts:', error);
            this.allAccounts = [];
            this.totalCount = 0;
            this.hasNextPage = false;
            this.hasPreviousPage = false;
            this.endCursor = null;
        }
    }

    get variables() {
        // When industryFilter is empty, use a pattern that matches any industry
        // Using '%' might not work, so we'll use a pattern that matches anything
        const industryValue = this.industryFilter ? `%${this.industryFilter}%` : '%';
        
        const vars = {
            industryFilter: industryValue,
            minEmployees: Number(this.minEmployees) || 0,
            maxEmployees: Number(this.maxEmployees) || 10000,
            after: this.after || null
        };
        console.log('GraphQL Variables:', vars);
        console.log('Current filters - Industry:', this.industryFilter, 'Min Employees:', this.minEmployees, 'Max Employees:', this.maxEmployees);
        return vars;
    }

    get accounts() {
        if (!this.allAccounts || this.allAccounts.length === 0) {
            return [];
        }
        
        // Transform data for tree grid - create flat array with parent-child structure
        const treeData = [];
        
        this.allAccounts.forEach(account => {
            // Add account as parent row
            treeData.push({
                ...account,
                _children: account.Contacts || [],
                _isExpanded: false
            });
        });
        
        return treeData;
    }

    // Event handlers for filters
    handleIndustryChange(event) {
        this.industryFilter = event.target.value;
    }

    handleMinEmployeesChange(event) {
        this.minEmployees = parseInt(event.target.value, 10);
    }

    handleMaxEmployeesChange(event) {
        this.maxEmployees = parseInt(event.target.value, 10);
    }

    // Pagination methods
    handleNextPage() {
        if (this.hasNextPage) {
            this.after = this.endCursor;
            this.pageNumber++;
        }
    }

    handlePreviousPage() {
        if (this.hasPreviousPage) {
            this.after = null;
            this.pageNumber = Math.max(1, this.pageNumber - 1);
        }
    }

    handleFirstPage() {
        this.after = null;
        this.pageNumber = 1;
    }

    // Tree grid event handlers
    handleRowAction(event) {
        console.log('Row action:', event.detail);
    }

    handleRowSelection(event) {
        console.log('Row selection:', event.detail);
    }

    handleRowCollapse(event) {
        console.log('Row collapsed:', event.detail);
    }

    handleRowExpand(event) {
        console.log('Row expanded:', event.detail);
    }

    // Helper methods
    resetFilters() {
        this.industryFilter = '';
        this.minEmployees = 0;
        this.maxEmployees = 10000;
        this.after = null;
        this.pageNumber = 1;
    }

    get hasData() {
        return this.accounts && this.accounts.length > 0;
    }

    get isLoading() {
        return this.graphqlQuery.loading;
    }

    get hasError() {
        return this.errors;
    }

    get paginationInfo() {
        return {
            pageNumber: this.pageNumber,
            totalCount: this.totalCount,
            hasNextPage: this.hasNextPage,
            hasPreviousPage: this.hasPreviousPage,
            showingCount: this.allAccounts.length
        };
    }

    get canGoNext() {
        return this.hasNextPage;
    }

    get canGoPrevious() {
        return this.hasPreviousPage || this.pageNumber > 1;
    }

    get isFirstPage() {
        return this.pageNumber === 1;
    }

    get cannotGoPrevious() {
        return !this.canGoPrevious;
    }

    get cannotGoNext() {
        return !this.canGoNext;
    }

    get graphqlQueryDisplay() {
        return `query getAccounts(
  $industryFilter: Picklist! = "${this.industryFilter ? `%${this.industryFilter}%` : '%'}"
  $minEmployees: Int! = ${this.minEmployees}
  $maxEmployees: Int! = ${this.maxEmployees}
  $after: String = ${this.after ? `"${this.after}"` : 'null'}
) {
  uiapi {
    query {
      Account(
        first: 5
        after: $after
        where: {
          and: [
            { Industry: { like: $industryFilter } }
            { NumberOfEmployees: { gte: $minEmployees } }
            { NumberOfEmployees: { lte: $maxEmployees } }
          ]
        }
      ) {
        edges {
          node {
            Id
            Name { value }
            Phone { value }
            Industry { value }
            NumberOfEmployees { value }
            BillingCity { value }
            BillingState { value }
            Contacts(first: 5) {
              edges {
                node {
                  Id
                  Name { value }
                  Email { value }
                  Phone { value }
                  Title { value }
                  Birthdate { value }
                }
              }
            }
          }
        }
        pageInfo {
          hasNextPage
          hasPreviousPage
          startCursor
          endCursor
        }
        totalCount
      }
    }
  }
}`;
    }
}