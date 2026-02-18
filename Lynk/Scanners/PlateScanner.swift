//
//  PlateScanner.swift
//  Lynk
//
//  Created by gülçin çetin on 18.02.2026.
//

import SwiftUI
import VisionKit

struct PlateScanner: UIViewControllerRepresentable {
    @Binding var scannedCode: String
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        // We look for text
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.text()],
            qualityLevel: .fast, // Faster recognition for large text like plates
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        try? scanner.startScanning()
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var parent: PlateScanner
        
        init(parent: PlateScanner) {
            self.parent = parent
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .text(let text):
                // Clean the text (Remove spaces and hyphens)
                let cleanText = text.transcript.uppercased().filter { $0.isLetter || $0.isNumber }
                
                // License plates are usually between 4 and 8 characters long
                if cleanText.count >= 4 && cleanText.count <= 8 {
                    parent.scannedCode = cleanText
                    parent.dismiss()
                }
            default:
                break
            }
        }
    }
}
