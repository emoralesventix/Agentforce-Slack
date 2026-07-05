import { LightningElement, api, wire } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import getAccountData from '@salesforce/apex/AccountPDFController.getAccountData';
import JSPDF from '@salesforce/resourceUrl/jsPDF';
import JSPDF_AUTOTABLE from '@salesforce/resourceUrl/jsPDFautoTable';

export default class MiGeneradorPDF extends LightningElement {
    @api recordId;
    jsPdfInitialized = false;
    accountData;

    @wire(getAccountData, { recordId: '$recordId' })
    wiredAccount({ error, data }) {
        if (data) {
            this.accountData = data;
            console.log('Account Data Loaded:', data);
        } else if (error) {
            console.error('Error loading account data:', error);
        }
    }

    // Load the library when the component renders
    renderedCallback() {
        if (this.jsPdfInitialized) {
            return;
        }
        this.jsPdfInitialized = true;

        Promise.all([
            loadScript(this, JSPDF),
            loadScript(this, JSPDF_AUTOTABLE)
        ])
            .then(() => {
                console.log('jsPDF and AutoTable loaded successfully');
            })
            .catch(error => {
                console.error('Error loading jsPDF or AutoTable', error);
            });
    }

    generarPDF() {
        if (!this.accountData) {
            alert('Please wait for the data to load.');
            return;
        }

        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        
        // --- DESIGN CONSTANTS ---
        const PRIMARY_COLOR = [22, 160, 133]; // #16A085
        const SECONDARY_COLOR = [44, 62, 80];  // #2C3E50
        const TEXT_COLOR = [50, 50, 50];       // Dark Grey
        const LIGHT_GREY = [240, 240, 240];

        const acc = this.accountData.account;
        const opps = this.accountData.opportunities || [];

        // --- HEADER ---
        // Colored Header Background
        doc.setFillColor(...PRIMARY_COLOR);
        doc.rect(0, 0, 210, 40, 'F');

        // Title
        doc.setTextColor(255, 255, 255);
        doc.setFontSize(24);
        doc.setFont('helvetica', 'bold');
        doc.text('Account Report', 20, 20);
        
        // Subtitle/Date
        doc.setFontSize(10);
        doc.setFont('helvetica', 'normal');
        const today = new Date().toLocaleDateString();
        doc.text(`Generated on: ${today}`, 20, 28);

        // Logo text (simulated logo)
        doc.setFontSize(14);
        doc.text('Agentforce', 170, 20, { align: 'right' });

        // --- ACCOUNT DETAILS SECTION ---
        let yPos = 55;
        
        doc.setTextColor(...SECONDARY_COLOR);
        doc.setFontSize(16);
        doc.setFont('helvetica', 'bold');
        doc.text(acc.Name || 'Unknown Account', 20, yPos);
        
        yPos += 10;
        doc.setDrawColor(200, 200, 200);
        doc.line(20, yPos, 190, yPos); // Horizontal separator
        yPos += 10;

        // Account Details Grid
        doc.setTextColor(...TEXT_COLOR);
        doc.setFontSize(11);
        doc.setFont('helvetica', 'normal');

        const details = [
            { label: 'Industry', value: acc.Industry || 'N/A' },
            { label: 'Phone', value: acc.Phone || 'N/A' },
            { label: 'Annual Revenue', value: acc.AnnualRevenue ? `$${acc.AnnualRevenue.toLocaleString()}` : 'N/A' },
            { label: 'Website', value: acc.Website || 'N/A' }
        ];

        let col = 0;
        const colWidth = 90;
        const startX = 20;
        
        details.forEach((item, index) => {
            if (index % 2 === 0 && index !== 0) {
                yPos += 8;
                col = 0;
            }
            
            const x = startX + (col * colWidth);
            doc.setFont('helvetica', 'bold');
            doc.text(`${item.label}:`, x, yPos);
            
            doc.setFont('helvetica', 'normal');
            doc.text(item.value, x + 35, yPos);
            
            col++;
        });

        // --- OPPORTUNITIES SECTION ---
        yPos += 20;

        doc.setTextColor(...SECONDARY_COLOR);
        doc.setFontSize(14);
        doc.setFont('helvetica', 'bold');
        doc.text('Related Opportunities', 20, yPos);
        yPos += 5;

        // AutoTable for Opportunities
        const oppData = opps.map(opp => [
            opp.Name,
            opp.StageName,
            opp.CloseDate || '',
            opp.Amount ? `$${opp.Amount.toLocaleString()}` : '$0'
        ]);

        if (oppData.length > 0) {
            doc.autoTable({
                startY: yPos,
                head: [['Opportunity Name', 'Stage', 'Close Date', 'Amount']],
                body: oppData,
                theme: 'grid',
                headStyles: {
                    fillColor: PRIMARY_COLOR,
                    textColor: [255, 255, 255],
                    fontStyle: 'bold'
                },
                columnStyles: {
                    0: { cellWidth: 70 }, // Name
                    3: { halign: 'right' } // Amount aligned right
                },
                alternateRowStyles: {
                    fillColor: LIGHT_GREY
                },
                styles: {
                    fontSize: 10,
                    cellPadding: 3
                }
            });
        } else {
            yPos += 10;
            doc.setFontSize(11);
            doc.setFont('helvetica', 'italic');
            doc.text('No opportunities found for this account.', 20, yPos);
        }

        // --- FOOTER ---
        const pageCount = doc.internal.getNumberOfPages();
        for (let i = 1; i <= pageCount; i++) {
            doc.setPage(i);
            doc.setFontSize(10);
            doc.setTextColor(150);
            doc.text(`Page ${i} of ${pageCount}`, 190, 285, { align: 'right' });
        }

        doc.save(`${acc.Name}_Report.pdf`);
    }
}