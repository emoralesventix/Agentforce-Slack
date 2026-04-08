public with sharing class OpportunitiesPdfReportService {
    public static Id generateAndAttachPdf(Id recordId) {
        if (recordId == null) {
            throw new IllegalArgumentException('recordId is required');
        }

        Id accountId = resolveAccountId(recordId);
        Account acc = [
            SELECT Id, Name, Phone, Industry, AnnualRevenue, Website, Owner.Name,
                   BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry
            FROM Account
            WHERE Id = :accountId
            LIMIT 1
        ];

        List<Opportunity> opps = [
            SELECT Id, Name, StageName, Amount, CloseDate
            FROM Opportunity
            WHERE AccountId = :accountId
            ORDER BY CloseDate DESC
            LIMIT 200
        ];

        String html = buildHtml(acc, opps);
        Blob pdfBlob = Test.isRunningTest() ? Blob.valueOf('PDF TEST') : Blob.toPdf(html);

        String baseName = 'Opportunities_Report_' + sanitizeFileName(acc.Name);
        String fileName = baseName + '.pdf';

        ContentVersion cv = new ContentVersion();
        cv.Title = baseName;
        cv.PathOnClient = fileName;
        cv.VersionData = pdfBlob;
        cv.IsMajorVersion = true;
        cv.FirstPublishLocationId = recordId;
        insert cv;

        ContentVersion inserted = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Id = :cv.Id
        ];

        return inserted.ContentDocumentId;
    }

    private static Id resolveAccountId(Id recordId) {
        Schema.SObjectType sType = recordId.getSObjectType();
        if (sType == Account.SObjectType) {
            return recordId;
        }
        if (sType == Opportunity.SObjectType) {
            return [
                SELECT AccountId
                FROM Opportunity
                WHERE Id = :recordId
                LIMIT 1
            ].AccountId;
        }
        throw new IllegalArgumentException('Pass an Account Id (recommended) or an Opportunity Id.');
    }

    private static String buildHtml(Account acc, List<Opportunity> opps) {
        List<String> parts = new List<String>();

        parts.add('<html><head><meta charset="utf-8" /></head>');
        parts.add('<body style="font-family:Arial,Helvetica,sans-serif;font-size:12px;color:#111;">');

        parts.add('<h1 style="font-size:20px;margin:0 0 10px 0;">Opportunities Report</h1>');
        parts.add('<div style="display:flex;justify-content:space-between;gap:16px;margin-bottom:14px;">');

        parts.add('<div style="border:1px solid #e5e7eb;border-radius:8px;padding:10px 12px;">');
        parts.add('<div><b>' + esc(acc.Name) + '</b></div>');
        parts.add('<div style="color:#666;">' + esc(acc.Industry) + '</div>');
        parts.add('<div style="color:#666;">Owner: ' + esc(acc.Owner != null ? acc.Owner.Name : null) + '</div>');
        parts.add('<div style="margin-top:6px;">');
        if (acc.Phone != null) parts.add('Phone: ' + esc(acc.Phone) + '<br/>');
        if (acc.Website != null) parts.add('Website: ' + esc(acc.Website) + '<br/>');
        if (acc.AnnualRevenue != null) parts.add('Annual Revenue: ' + String.valueOf(acc.AnnualRevenue) + '<br/>');
        parts.add('</div>');
        parts.add('</div>');

        parts.add('<div style="border:1px solid #e5e7eb;border-radius:8px;padding:10px 12px;">');
        parts.add('<div style="color:#666;">Generated: ' + Datetime.now().format('yyyy-MM-dd HH:mm') + '</div>');
        parts.add('<div style="color:#666;margin-top:8px;">');
        String fullAddress = joinAddress(
            acc.BillingStreet,
            acc.BillingCity,
            acc.BillingState,
            acc.BillingPostalCode,
            acc.BillingCountry
        );
        if (!String.isBlank(fullAddress)) {
            parts.add(esc(fullAddress));
        }
        parts.add('</div>');
        parts.add('</div>');

        parts.add('</div>'); // header

        parts.add('<table style="width:100%;border-collapse:collapse;">');
        parts.add('<thead><tr>');
        parts.add('<th style="background:#f3f6fb;text-align:left;border:1px solid #ddd;padding:8px;vertical-align:top;">Opportunity</th>');
        parts.add('<th style="background:#f3f6fb;text-align:left;border:1px solid #ddd;padding:8px;vertical-align:top;white-space:nowrap;">Stage</th>');
        parts.add('<th style="background:#f3f6fb;text-align:right;border:1px solid #ddd;padding:8px;vertical-align:top;white-space:nowrap;">Amount</th>');
        parts.add('<th style="background:#f3f6fb;text-align:left;border:1px solid #ddd;padding:8px;vertical-align:top;white-space:nowrap;">Close Date</th>');
        parts.add('</tr></thead><tbody>');

        if (opps.isEmpty()) {
            parts.add('<tr><td colspan="4" style="border:1px solid #ddd;padding:8px;vertical-align:top;color:#666;">No opportunities found.</td></tr>');
        } else {
            for (Opportunity o : opps) {
                parts.add('<tr>');
                parts.add('<td style="border:1px solid #ddd;padding:8px;vertical-align:top;">' + esc(o.Name) + '</td>');
                parts.add('<td style="border:1px solid #ddd;padding:8px;vertical-align:top;white-space:nowrap;">' + esc(o.StageName) + '</td>');
                parts.add('<td style="border:1px solid #ddd;padding:8px;vertical-align:top;white-space:nowrap;text-align:right;">' + String.valueOf(o.Amount) + '</td>');
                parts.add(
                    '<td style="border:1px solid #ddd;padding:8px;vertical-align:top;white-space:nowrap;">' +
                    (o.CloseDate != null ? String.valueOf(o.CloseDate) : '') +
                    '</td>'
                );
                parts.add('</tr>');
            }
        }

        parts.add('</tbody></table>');
        parts.add('</body></html>');
        return String.join(parts, '');
    }

    private static String joinAddress(
        String street,
        String city,
        String state,
        String postal,
        String country
    ) {
        List<String> parts = new List<String>();
        if (!String.isBlank(street)) parts.add(street);
        if (!String.isBlank(city)) parts.add(city);
        if (!String.isBlank(state)) parts.add(state);
        if (!String.isBlank(postal)) parts.add(postal);
        if (!String.isBlank(country)) parts.add(country);
        return String.join(parts, ', ');
    }

    private static String esc(String value) {
        if (value == null) return '';
        // Manual HTML escaping to avoid depending on a specific String method availability.
        String s = value;
        s = s.replace('&', '&amp;');
        s = s.replace('<', '&lt;');
        s = s.replace('>', '&gt;');
        s = s.replace('\"', '&quot;');
        s = s.replace('\'', '&#39;');
        return s;
    }

    private static String sanitizeFileName(String name) {
        if (String.isBlank(name)) return 'Account';
        String s = name.trim();
        // Keep it simple: replace potentially problematic characters.
        s = s.replaceAll('[^A-Za-z0-9_\\- ]', '_');
        s = s.replaceAll('\\s+', '_');
        return s.left(80);
    }
}