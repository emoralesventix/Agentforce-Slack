import { LightningElement } from 'lwc';
import dapsaLogoUrl from '@salesforce/resourceUrl/DapsaLogo';

export default class StationPerformanceDashboardDemo extends LightningElement {
    logoUrl = dapsaLogoUrl;
    currencyIsoCode = 'ARS';
    asOfLabel = 'As of 06/05/2026 11:00';

    kpi = {
        revenueMtd: 4000000,
        revenueMtdLabel: 'ARS 4M',
        totalSalesCount: 9,
        conversationsCountLabel: '5,8k',
        onTimeDeliveryRate: 0.942,
        onTimeDeliveryRateLabel: '94,2%',
        stockoutIncidents: 2,
        stockoutIncidentsLabel: '2',
        complaintsRate: 0.018,
        complaintsRateLabel: '1,8%',
        avgDeliveryDelayMinutes: 12,
        avgDeliveryDelayMinutesLabel: '12 min'
    };

    salesByDay = [
        { dayLabel: '08/03', value: 320, display: '320k' },
        { dayLabel: '10/03', value: 640, display: '640k' },
        { dayLabel: '17/03', value: 680, display: '680k' },
        { dayLabel: '18/03', value: 630, display: '630k' },
        { dayLabel: '20/03', value: 350, display: '350k' },
        { dayLabel: '21/03', value: 290, display: '290k' },
        { dayLabel: '23/03', value: 870, display: '870k' },
        { dayLabel: '27/04', value: 340, display: '340k' }
    ];

    deliveriesOnTimeByDay = [
        { dayLabel: '18/04', value: 88 },
        { dayLabel: '19/04', value: 91 },
        { dayLabel: '20/04', value: 93 },
        { dayLabel: '21/04', value: 92 },
        { dayLabel: '22/04', value: 94 },
        { dayLabel: '23/04', value: 95 },
        { dayLabel: '24/04', value: 93 },
        { dayLabel: '25/04', value: 96 },
        { dayLabel: '26/04', value: 94 }
    ];

    conversationsByDay = [
        { dayLabel: '18/04', value: 420 },
        { dayLabel: '19/04', value: 510 },
        { dayLabel: '20/04', value: 560 },
        { dayLabel: '21/04', value: 590 },
        { dayLabel: '22/04', value: 640 },
        { dayLabel: '23/04', value: 710 },
        { dayLabel: '24/04', value: 760 },
        { dayLabel: '25/04', value: 820 },
        { dayLabel: '26/04', value: 790 }
    ];

    salesTodayByHour = [
        { hourLabel: '08', value: 0 },
        { hourLabel: '09', value: 1 },
        { hourLabel: '10', value: 2 },
        { hourLabel: '11', value: 1 },
        { hourLabel: '12', value: 2 },
        { hourLabel: '13', value: 3 },
        { hourLabel: '14', value: 4 },
        { hourLabel: '15', value: 3 },
        { hourLabel: '16', value: 5 }
    ];

    topStations = [
        { id: 's1', name: 'Dapsa Palermo', revenue: 980000, liters: 74200, onTimeRate: 0.96 },
        { id: 's2', name: 'Dapsa Pilar', revenue: 860000, liters: 65100, onTimeRate: 0.93 },
        { id: 's3', name: 'Dapsa Rosario Centro', revenue: 790000, liters: 60450, onTimeRate: 0.95 },
        { id: 's4', name: 'Dapsa Córdoba Norte', revenue: 640000, liters: 48700, onTimeRate: 0.92 },
        { id: 's5', name: 'Dapsa Mendoza Sur', revenue: 520000, liters: 40100, onTimeRate: 0.90 }
    ];

    get semaphores() {
        return [
            {
                id: 'sem-on-time',
                title: 'On-time (7d)',
                value: this.kpi.onTimeDeliveryRateLabel,
                dotClass: this.kpi.onTimeDeliveryRate >= 0.94 ? 'dot dot-green' : this.kpi.onTimeDeliveryRate >= 0.9 ? 'dot dot-yellow' : 'dot dot-red'
            },
            {
                id: 'sem-stockouts',
                title: 'Quiebres stock (MTD)',
                value: this.kpi.stockoutIncidentsLabel,
                dotClass: this.kpi.stockoutIncidents <= 1 ? 'dot dot-green' : this.kpi.stockoutIncidents <= 3 ? 'dot dot-yellow' : 'dot dot-red'
            },
            {
                id: 'sem-complaints',
                title: 'Reclamos / entregas',
                value: this.kpi.complaintsRateLabel,
                dotClass: this.kpi.complaintsRate <= 0.015 ? 'dot dot-green' : this.kpi.complaintsRate <= 0.03 ? 'dot dot-yellow' : 'dot dot-red'
            }
        ];
    }

    get maxSalesByDay() {
        return Math.max(...this.salesByDay.map(item => item.value));
    }

    get salesBars() {
        const max = this.maxSalesByDay || 1;
        return this.salesByDay.map(item => ({
            ...item,
            heightPct: Math.round((item.value / max) * 100),
            style: `height: ${Math.max(6, Math.round((item.value / max) * 100))}%;`
        }));
    }

    get deliveriesSparklinePoints() {
        return this.buildSparklinePoints(this.deliveriesOnTimeByDay.map(item => item.value), 260, 60, 6);
    }

    get conversationsSparklinePoints() {
        return this.buildSparklinePoints(this.conversationsByDay.map(item => item.value), 260, 60, 6);
    }

    get salesTodaySparklinePoints() {
        return this.buildSparklinePoints(this.salesTodayByHour.map(item => item.value), 260, 60, 6);
    }

    buildSparklinePoints(values, width, height, padding) {
        const safeValues = (values || []).map(v => (Number.isFinite(v) ? v : 0));
        if (safeValues.length === 0) {
            return '';
        }

        const min = Math.min(...safeValues);
        const max = Math.max(...safeValues);
        const span = Math.max(1, max - min);

        const innerWidth = width - padding * 2;
        const innerHeight = height - padding * 2;

        return safeValues
            .map((value, index) => {
                const x = padding + (innerWidth * index) / Math.max(1, safeValues.length - 1);
                const y = padding + innerHeight - (innerHeight * (value - min)) / span;
                return `${x.toFixed(1)},${y.toFixed(1)}`;
            })
            .join(' ');
    }

    formatCurrency(value) {
        const safeValue = Number.isFinite(value) ? value : 0;
        return new Intl.NumberFormat('es-AR', {
            style: 'currency',
            currency: this.currencyIsoCode,
            maximumFractionDigits: 0
        }).format(safeValue);
    }

    get normalizedStations() {
        return this.topStations.map(station => ({
            ...station,
            revenueLabel: `${this.formatCurrency(station.revenue)} ${this.currencyIsoCode}`,
            litersLabel: `${new Intl.NumberFormat('es-AR').format(station.liters)} L`,
            onTimeLabel: `${Math.round(station.onTimeRate * 1000) / 10}%`
        }));
    }
}