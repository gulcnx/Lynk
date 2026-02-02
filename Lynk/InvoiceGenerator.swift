//
//  InvoiceGenerator.swift
//  Lynk
//
//  Created by gülçin çetin on 2.02.2026.
//

import SwiftUI
import PDFKit

@MainActor
struct InvoiceGenerator {
    static func generateInvoice(for project: Project) -> URL? {
        // 1. Create the standard A4 size
        let pageWidth = 595.2
        let pageHeight = 841.8
        
        // 2. Create the Renderer with specific size constraints
        let renderer = ImageRenderer(content: InvoiceView(project: project))
        renderer.proposedSize = ProposedViewSize(width: pageWidth, height: pageHeight)
        
        // 3. Define where to save the file
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("Invoice_\(project.title).pdf")
        
        // 4. Create a PDF Context destination
        guard let consumer = CGDataConsumer(url: tempURL as CFURL),
              let pdfContext = CGContext(consumer: consumer, mediaBox: nil, nil)
        else {
            print("Could not create PDF context")
            return nil
        }
        
        // 5. Begin the PDF Page
        pdfContext.beginPDFPage(nil)
        
        // 6. The Magic: Tell ImageRenderer to draw into our PDF Context
        renderer.render { size, renderInContext in
            // Move the context to the right position if needed (usually 0,0 is fine)
            renderInContext(pdfContext)
        }
        
        // 7. Close and Save
        pdfContext.endPDFPage()
        pdfContext.closePDF()
        
        return tempURL
    }
}

// Visual Design of the PDF
struct InvoiceView: View {
    let project: Project
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            Text("INVOICE")
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(.blue)
            
            Divider()
            
            // Client Details
            VStack(alignment: .leading) {
                Text("Billed To:")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Text(project.client?.name ?? "Unknown Client")
                    .font(.title2)
                    .bold()
                Text(project.client?.email ?? "")
            }
            .padding(.vertical)
            
            // Project Details Table
            VStack(spacing: 0) {
                HStack {
                    Text("Description").bold()
                    Spacer()
                    Text("Hours").bold()
                    Spacer()
                    Text("Rate").bold()
                    Spacer()
                    Text("Total").bold()
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                
                HStack {
                    Text(project.title)
                    Spacer()
                    Text(String(format: "%.1f", project.hoursWorked))
                    Spacer()
                    Text("$\(String(format: "%.2f", project.hourlyRate))")
                    Spacer()
                    Text("$\(String(format: "%.2f", project.totalFee))")
                }
                .padding()
                
                Divider()
            }
            
            Spacer()
            
            // Footer
            Text("Thank you for your business!")
                .font(.caption)
                .italic()
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(50) // Margins
        .background(.white) // Vital: PDF needs a background color
        // 👇 CRITICAL FIX: Force the view to be A4 size
        .frame(width: 595.2, height: 841.8)
    }
}
