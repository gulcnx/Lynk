//
//  VINScanner.swift
//  Lynk
//
//  Created by gülçin çetin on 9.02.2026.
//

import SwiftUI
import VisionKit

struct VINScanner: UIViewControllerRepresentable {
    // This binding sends the scanned text back to your form
    @Binding var scannedCode: String
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        // We only look for Text (not QR codes)
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.text()],
            qualityLevel: .balanced,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        
        // Start the scanner immediately
        try? scanner.startScanning()
        
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var parent: VINScanner
        
        init(parent: VINScanner) {
            self.parent = parent
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .text(let text):
                // Clean the text (VINs are 17 chars, uppercase, no O/I/Q usually)
                let cleanText = text.transcript.uppercased().filter { $0.isLetter || $0.isNumber }
                
                // Simple validation: VINs are usually 17 chars
                if cleanText.count >= 11 { // Allow shorter ones just in case
                    parent.scannedCode = cleanText
                    // Close the scanner automatically
                    parent.dismiss()
                }
            default:
                break
            }
        }
    }
}
