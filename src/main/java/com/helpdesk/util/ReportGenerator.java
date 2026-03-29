package com.helpdesk.util;

import com.itextpdf.text.Chunk;
import com.itextpdf.text.Document;
import com.itextpdf.text.Font;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import com.helpdesk.model.Ticket;

import java.io.OutputStream;
import java.util.List;

/**
 * ReportGenerator — Generates PDF reports using iText 5.
 * Requires itextpdf-5.5.13.jar in WEB-INF/lib.
 */
public class ReportGenerator {

    /**
     * Generate a PDF table of ticket data and write it to the given output stream.
     * Columns: Ticket ID, Title, Priority, Status, Created At
     *
     * @param tickets List of tickets to include in the report
     * @param out     OutputStream to write the PDF to (e.g. response.getOutputStream())
     * @throws Exception if PDF generation fails
     */
    public static void generateTicketReport(List<Ticket> tickets,
                                            OutputStream out) throws Exception {
        Document doc = new Document();
        PdfWriter.getInstance(doc, out);
        doc.open();

        // Title
        Font titleFont = new Font(Font.FontFamily.HELVETICA, 18, Font.BOLD);
        doc.add(new Paragraph("Helpdesk Ticket Report", titleFont));
        doc.add(new Paragraph("Total Tickets: " + tickets.size()));
        doc.add(Chunk.NEWLINE);

        // Table with 5 columns
        PdfPTable table = new PdfPTable(5);
        table.setWidthPercentage(100);
        table.setWidths(new float[]{1f, 3f, 1.5f, 1.5f, 2f});

        // Table header
        table.addCell("Ticket ID");
        table.addCell("Title");
        table.addCell("Priority");
        table.addCell("Status");
        table.addCell("Created At");

        // Table rows
        for (Ticket t : tickets) {
            table.addCell(String.valueOf(t.getTicketId()));
            table.addCell(t.getTitle());
            table.addCell(t.getPriority());
            table.addCell(t.getStatus());
            table.addCell(t.getCreatedAt() != null ? t.getCreatedAt().toString() : "N/A");
        }

        doc.add(table);
        doc.close();
    }

    // ── QUICK TEST ───────────────────────────────────────────
    public static void main(String[] args) {
        try {
            // Create mock tickets
            Ticket t1 = new Ticket();
            t1.setTicketId(1); t1.setTitle("Printer offline");
            t1.setPriority("HIGH"); t1.setStatus("OPEN");
            t1.setCreatedAt(new java.sql.Timestamp(System.currentTimeMillis()));

            Ticket t2 = new Ticket();
            t2.setTicketId(2); t2.setTitle("VPN not working");
            t2.setPriority("MEDIUM"); t2.setStatus("IN_PROGRESS");
            t2.setCreatedAt(new java.sql.Timestamp(System.currentTimeMillis()));

            List<Ticket> tickets = List.of(t1, t2);

            // Write PDF to file
            java.io.FileOutputStream fos = new java.io.FileOutputStream("test_report.pdf");
            generateTicketReport(tickets, fos);
            fos.close();

            System.out.println("✅ PDF generated: test_report.pdf (" + tickets.size() + " tickets)");
        } catch (Exception e) {
            System.out.println("❌ PDF generation failed: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
