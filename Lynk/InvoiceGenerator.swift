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

    static func generateInvoice(for service: Service) -> URL? {
        // 1. Create the standard A4 size
        let pageWidth = 595.2
        let pageHeight = 841.8
        
        // 2. Create the Renderer
        let renderer = ImageRenderer(content: InvoiceView(service: service))
        renderer.proposedSize = ProposedViewSize(width: pageWidth, height: pageHeight)
        
        // 3. Define file path
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("Invoice_\(service.title).pdf")
        
        // 4. Create PDF Context
        guard let consumer = CGDataConsumer(url: tempURL as CFURL),
              let pdfContext = CGContext(consumer: consumer, mediaBox: nil, nil)
        else {
            return nil
        }
        
        pdfContext.beginPDFPage(nil)
        
        renderer.render { size, renderInContext in
            renderInContext(pdfContext)
        }
        
        pdfContext.endPDFPage()
        pdfContext.closePDF()
        
        return tempURL
    }
}

// Visual Design of the PDF
struct InvoiceView: View {
    let service: Service
    
    // 👇 Tap into the data we saved in SettingsView!
    @AppStorage("userLogoData") private var userLogoData: Data = Data()
    @AppStorage("userName") private var userName: String = "User"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // --- HEADER ---
            HStack {
                Text("INVOICE")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(.black)
                Spacer()
                
                // 👇 Dynamic Logo Logic
                if !userLogoData.isEmpty, let uiImage = UIImage(data: userLogoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 150, maxHeight: 60) // Keeps logo a reasonable size
                } else {
                    Image(systemName: "car.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.gray)
                }
            }
            
            Divider()
            
            // --- TWO COLUMNS: CLIENT & VEHICLE ---
            HStack(alignment: .top, spacing: 50) {
                // Col 1: Client
                VStack(alignment: .leading) {
                    Text("Billed To:")
                        .font(.headline)
                        .foregroundStyle(.gray)
                    Text(service.vehicle?.client?.name ?? "Valued Client")
                        .font(.title3)
                        .bold()
                    Text(service.vehicle?.client?.email ?? "")
                    Text(service.vehicle?.client?.phoneNumber ?? "")
                }
                
                Spacer()
                
                // Col 2: Vehicle
                VStack(alignment: .trailing) {
                    Text("Vehicle Serviced:")
                        .font(.headline)
                        .foregroundStyle(.gray)
                    
                    if let vehicle = service.vehicle {
                        Text("\(String(vehicle.year)) \(vehicle.make) \(vehicle.model)")
                            .font(.title3)
                            .bold()
                        Text("Color: \(vehicle.color)")
                        if let vin = vehicle.vin, !vin.isEmpty {
                            Text("VIN: \(vin)")
                                .font(.caption)
                                .monospaced()
                        }
                    } else {
                        Text("Unknown Vehicle")
                    }
                }
            }
            .padding(.vertical)
            
            // --- SERVICE TABLE ---
            VStack(spacing: 0) {
                // Table Header
                HStack {
                    Text("Service Description").bold()
                    Spacer()
                    Text("Date").bold()
                    Spacer()
                    Text("Amount").bold()
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                
                // Table Row
                HStack {
                    Text(service.title)
                    Spacer()
                    Text(service.date.formatted(date: .numeric, time: .omitted))
                    Spacer()
                    Text(service.price, format: .currency(code: "USD"))
                }
                .padding()
                
                Divider()
            }
            
            // --- TOTAL ---
            HStack {
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Total Due")
                        .font(.headline)
                    Text(service.price, format: .currency(code: "USD"))
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(.green)
                }
            }
            .padding(.top, 20)
            
            Spacer()
            
            // --- FOOTER ---
            VStack(spacing: 5) {
                Text("Thank you for your business!")
                    .font(.headline)
                // 👇 Automatically uses the name they typed in settings!
                Text("Please make checks payable to \(userName)")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 50)
        }
        .padding(50)
        .background(.white)
        .foregroundStyle(.black) // Force text black for printing
        .frame(width: 595.2, height: 841.8) // A4 Size
    }
}
