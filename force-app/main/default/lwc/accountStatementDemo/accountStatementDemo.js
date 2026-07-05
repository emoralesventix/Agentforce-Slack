import { api, LightningElement } from 'lwc';
import dapsaLogoUrl from '@salesforce/resourceUrl/DapsaLogo';

export default class AccountStatementDemo extends LightningElement {
    @api recordId;

    currencyIsoCode = 'ARS';
    logoUrl = dapsaLogoUrl;

    orders = [
        {
            id: 'o-10021',
            title: 'Pedido #10021',
            channelLabel: 'WhatsApp',
            createdDateLabel: '06 May 2026 · 09:12',
            fuelLabel: 'Nafta Super',
            deliveredQuantityLabel: '39.200 L',
            deliveredAmount: 392000,
            paidAmount: 400000,
            deliveryDateLabel: '06 May 2026 · 14:35',
            paymentMethodLabel: 'eCheq',
            paymentDateLabel: '06 May 2026 · 08:55',
            notes: 'Entrega parcial por disponibilidad en planta.',
            events: [
                {
                    id: 'o-10021-e1',
                    type: 'payment',
                    title: 'Pago recibido',
                    subtitle: 'eCheq · $400.000 ARS',
                    dateLabel: '06 May 2026 · 08:55',
                    icon: 'utility:moneybag'
                },
                {
                    id: 'o-10021-e2',
                    type: 'order',
                    title: 'Pedido creado por WhatsApp',
                    subtitle: '40.000 L · Nafta Super',
                    dateLabel: '06 May 2026 · 09:12',
                    icon: 'utility:chat'
                },
                {
                    id: 'o-10021-e3',
                    type: 'delivery',
                    title: 'Entrega realizada',
                    subtitle: '39.200 L · Remito 0003-000182',
                    dateLabel: '06 May 2026 · 14:35',
                    icon: 'utility:truck'
                }
            ]
        },
        {
            id: 'o-10022',
            title: 'Pedido #10022',
            channelLabel: 'WhatsApp',
            createdDateLabel: '03 May 2026 · 17:40',
            fuelLabel: 'Diesel',
            deliveredQuantityLabel: '25.500 L',
            deliveredAmount: 280500,
            paidAmount: 275000,
            deliveryDateLabel: '04 May 2026 · 10:10',
            paymentMethodLabel: 'Transferencia',
            paymentDateLabel: '03 May 2026 · 16:58',
            notes: 'Ajuste por diferencial de precio en descarga.',
            events: [
                {
                    id: 'o-10022-e1',
                    type: 'payment',
                    title: 'Pago recibido',
                    subtitle: 'Transferencia · $275.000 ARS',
                    dateLabel: '03 May 2026 · 16:58',
                    icon: 'utility:moneybag'
                },
                {
                    id: 'o-10022-e2',
                    type: 'order',
                    title: 'Pedido creado por WhatsApp',
                    subtitle: '25.000 L · Diesel',
                    dateLabel: '03 May 2026 · 17:40',
                    icon: 'utility:chat'
                },
                {
                    id: 'o-10022-e3',
                    type: 'delivery',
                    title: 'Entrega realizada',
                    subtitle: '25.500 L · Remito 0003-000183',
                    dateLabel: '04 May 2026 · 10:10',
                    icon: 'utility:truck'
                }
            ]
        },
        {
            id: 'o-10023',
            title: 'Pedido #10023',
            channelLabel: 'WhatsApp',
            createdDateLabel: '28 Apr 2026 · 11:05',
            fuelLabel: 'Nafta Premium',
            deliveredQuantityLabel: '10.000 L',
            deliveredAmount: 125000,
            paidAmount: 0,
            deliveryDateLabel: '29 Apr 2026 · 08:20',
            paymentMethodLabel: 'Pendiente',
            paymentDateLabel: '—',
            notes: 'Sin pago registrado. Pendiente de conciliación.',
            events: [
                {
                    id: 'o-10023-e1',
                    type: 'payment',
                    title: 'Pago pendiente',
                    subtitle: 'Sin registro de pago',
                    dateLabel: '—',
                    icon: 'utility:moneybag'
                },
                {
                    id: 'o-10023-e2',
                    type: 'order',
                    title: 'Pedido creado por WhatsApp',
                    subtitle: '10.000 L · Nafta Premium',
                    dateLabel: '28 Apr 2026 · 11:05',
                    icon: 'utility:chat'
                },
                {
                    id: 'o-10023-e3',
                    type: 'delivery',
                    title: 'Entrega realizada',
                    subtitle: '10.000 L · Remito 0003-000171',
                    dateLabel: '29 Apr 2026 · 08:20',
                    icon: 'utility:truck'
                }
            ]
        }
    ];

    get totalDeliveredAmount() {
        return this.orders.reduce((sum, order) => sum + (order.deliveredAmount || 0), 0);
    }

    get totalPaidAmount() {
        return this.orders.reduce((sum, order) => sum + (order.paidAmount || 0), 0);
    }

    get totalDeliveredLabel() {
        return `${this.formatCurrency(this.totalDeliveredAmount)} ${this.currencyIsoCode}`;
    }

    get totalPaidLabel() {
        return `${this.formatCurrency(this.totalPaidAmount)} ${this.currencyIsoCode}`;
    }

    get netBalanceAmount() {
        return this.totalPaidAmount - this.totalDeliveredAmount;
    }

    get netBalanceLabel() {
        const formattedAmount = this.formatCurrency(Math.abs(this.netBalanceAmount));
        const sign = this.netBalanceAmount > 0 ? '+' : this.netBalanceAmount < 0 ? '-' : '';
        return `${sign}${formattedAmount} ${this.currencyIsoCode}`;
    }

    get balanceLabel() {
        const amount = this.netBalanceAmount;
        const formattedAmount = this.formatCurrency(Math.abs(amount));
        if (amount > 0) {
            return `Saldo a favor: ${formattedAmount} ${this.currencyIsoCode}`;
        }
        if (amount < 0) {
            return `Saldo en contra: ${formattedAmount} ${this.currencyIsoCode}`;
        }
        return 'Saldo: $0';
    }

    get balanceVariant() {
        if (this.netBalanceAmount > 0) {
            return 'success';
        }
        if (this.netBalanceAmount < 0) {
            return 'error';
        }
        return 'base';
    }

    get balancePillClass() {
        const base = 'pill';
        if (this.balanceVariant === 'success') {
            return `${base} pill-success`;
        }
        if (this.balanceVariant === 'error') {
            return `${base} pill-error`;
        }
        return `${base} pill-neutral`;
    }

    get normalizedOrders() {
        return this.orders.map(order => {
            const orderBalanceAmount = (order.paidAmount || 0) - (order.deliveredAmount || 0);
            const formattedBalanceAmount = this.formatCurrency(Math.abs(orderBalanceAmount));
            const orderBalanceLabel =
                orderBalanceAmount > 0
                    ? `A favor ${formattedBalanceAmount} ${this.currencyIsoCode}`
                    : orderBalanceAmount < 0
                      ? `En contra ${formattedBalanceAmount} ${this.currencyIsoCode}`
                      : `Saldo $0 ${this.currencyIsoCode}`;

            const orderBalanceVariant = orderBalanceAmount > 0 ? 'success' : orderBalanceAmount < 0 ? 'error' : 'base';
            const orderBalancePillClass =
                orderBalanceVariant === 'success'
                    ? 'pill pill-success'
                    : orderBalanceVariant === 'error'
                      ? 'pill pill-error'
                      : 'pill pill-neutral';

            return {
                ...order,
                orderBalanceAmount,
                orderBalanceLabel,
                orderBalanceVariant,
                orderBalancePillClass,
                deliveredAmountLabel: `${this.formatCurrency(order.deliveredAmount)} ${this.currencyIsoCode}`,
                paidAmountLabel: `${this.formatCurrency(order.paidAmount)} ${this.currencyIsoCode}`,
                events: (order.events || []).map(eventItem => ({
                    ...eventItem,
                    isPayment: eventItem.type === 'payment',
                    isDelivery: eventItem.type === 'delivery',
                    isOrder: eventItem.type === 'order'
                }))
            };
        });
    }

    formatCurrency(value) {
        const safeValue = Number.isFinite(value) ? value : 0;
        return new Intl.NumberFormat('es-AR', {
            style: 'currency',
            currency: this.currencyIsoCode,
            maximumFractionDigits: 0
        }).format(safeValue);
    }
}