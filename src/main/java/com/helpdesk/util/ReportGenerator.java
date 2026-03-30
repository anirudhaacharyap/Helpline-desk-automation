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


}
