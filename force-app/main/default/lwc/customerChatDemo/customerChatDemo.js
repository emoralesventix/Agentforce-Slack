import { api, LightningElement } from 'lwc';

export default class CustomerChatDemo extends LightningElement {
    @api recordId;

    contactName = 'Dapsa Demo';
    contactChannelLabel = 'WhatsApp';

    agentName = 'Soporte';
    agentStatusLabel = 'N/A';

    draftMessage = '';

    messages = [
        {
            id: 'm1',
            direction: 'inbound',
            text:
                '¡Hola Fran! 👋 Soy Dapsito, el asistente de Dapsa.\n' +
                'Estoy para asistirte sin que tengas que dejar tu partidito de golf o lo que sea que estés haciendo 😁\n\n' +
                'Puedo ayudarte con:\n' +
                '• Hacer un nuevo pedido de combustible\n' +
                '• Conocer el estado de un pedido existente\n' +
                '• Conocer el estado de tu cuenta corriente\n\n' +
                '¿Qué tipo de combustible te gustaría pedir? Tenemos Nafta Super, Nafta Premium, Diesel y Euro Diesel.',
            timeLabel: '12:37 PM'
        },
        {
            id: 'm2',
            direction: 'outbound',
            text: 'Dame 40k de super',
            timeLabel: '12:38 PM'
        },
        {
            id: 'm3',
            direction: 'inbound',
            text:
                'Para tu pedido de 40.000 litros de Nafta Super:\n' +
                '• Total: $400.000 ARS\n\n' +
                '¡Buenas noticias! Banco Galicia te ofrece financiación para este pedido 🏦\n' +
                'Simulación de financiación:\n' +
                '• Monto a financiar: $400.000\n' +
                '• 3 cuotas (sistema Francés)\n' +
                '• Valor de cada cuota: $144.900\n' +
                '• TNA: 33%\n' +
                '• CFTEA: 38,20%\n' +
                '• Primera cuota: vence a 30 días\n\n' +
                '¿Querés financiarlo con Galicia o preferís pagar de la forma habitual?',
            timeLabel: '12:39 PM'
        }
    ];

    get headerSubtitle() {
        return `${this.contactChannelLabel} · ${this.agentStatusLabel}`;
    }

    get normalizedMessages() {
        return this.messages.map(message => ({
            ...message,
            isInbound: message.direction === 'inbound',
            isOutbound: message.direction === 'outbound',
            bubbleClass: message.direction === 'inbound' ? 'bubble bubble-in' : 'bubble bubble-out',
            rowClass: message.direction === 'inbound' ? 'message-row message-row-in' : 'message-row message-row-out'
        }));
    }

    renderedCallback() {
        const container = this.template.querySelector('[data-chat-scroll]');
        if (container) {
            container.scrollTop = container.scrollHeight;
        }
    }

    handleDraftChange(event) {
        this.draftMessage = event.target.value;
    }
}