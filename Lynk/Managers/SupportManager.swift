//
//  SupportManager.swift
//  Lynk
//
//  Created by Gulcin on 15.06.2026.
//

import UIKit

enum SupportManager {
    static func openFeedbackEmail() {
        let email = "cgulcn777@gmail.com"
        
        let subject = "Lynk App Feedback".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
      
        let body = "Hi Gülçin,\n\nHere is my feedback on Lynk:\n\n".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: "mailto:\(email)?subject=\(subject)&body=\(body)") {
            // Since we are moving outside of a View context, we use the shared application instance safely
            DispatchQueue.main.async {
                UIApplication.shared.open(url)
            }
        }
    }
}
