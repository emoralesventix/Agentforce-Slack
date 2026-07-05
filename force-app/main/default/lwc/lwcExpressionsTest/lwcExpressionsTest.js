import { LightningElement, track } from 'lwc';

export default class LwcExpressionsTest extends LightningElement {

    firstName = 'John';
    lastName = 'Garcia';

    @track loggedIn = true;

    user = {
        profile: {
            theme: null,
            plan: 'Pro'
        }
    };

    @track items = [
        { id: 1, name: 'Laptop Pro',  price: 1200, inStock: true  },
        { id: 2, name: 'Mouse Erg.',  price: 89,   inStock: false },
        { id: 3, name: 'Mech. Keyboard', price: 240, inStock: true },
        { id: 4, name: 'Monitor 4K',  price: 650,  inStock: true  },
        { id: 5, name: 'Webcam HD',   price: 120,  inStock: false },
    ];

    @track lastClicked = null;

    get loginButtonLabel() {
        return this.loggedIn ? 'Log out' : 'Log in';
    }

    get loginButtonVariant() {
        return this.loggedIn ? 'destructive' : 'brand';
    }

    get minInStockPrice() {
        const inStock = this.items.filter(i => i.inStock);
        return inStock.length ? Math.min(...inStock.map(i => i.price)) : 'N/A';
    }

    get enrichedItems() {
        return this.items.map(item => ({
            ...item,
            cssClass: item.inStock ? 'item-btn item-btn--stock' : 'item-btn item-btn--nostock',
            stockLabel: item.inStock ? '✅ In stock' : '❌ Out of stock'
        }));
    }

    get itemEventHandlers() {
        return { click: this.handleItemClick };
    }

    toggleLogin() {
        this.loggedIn = !this.loggedIn;
    }

    handleItemClick(event) {
        const itemId = parseInt(event.currentTarget.dataset.id, 10);
        const found = this.items.find(i => i.id === itemId);
        this.lastClicked = found ? found.name : 'Unknown';
    }
}