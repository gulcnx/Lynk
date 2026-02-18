//
//  StoreManager.swift
//  Lynk
//
//  Created by gülçin çetin on 18.02.2026.
//

import Combine
import Foundation
import StoreKit

@MainActor
class StoreManager: ObservableObject {
    @Published var hasProAccess: Bool = false
    @Published var products: [Product] = []
    
    private let proID = "com.lynk.pro.monthly" // Must match your StoreKit file
    
    var updateListenerTask: Task<Void, Never>? = nil
    
    init() {
        updateListenerTask = Task {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    // Always finish a transaction to tell Apple it was successful
                    await transaction.finish()
                    await self.updateSubscriptionStatus()
                }
            }
        }
        
        Task {
            await updateSubscriptionStatus()
            await fetchProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    func fetchProducts() async {
        do {
            self.products = try await Product.products(for: [proID])
        } catch {
            print("Failed to fetch products: \(error)")
        }
    }
    
    func purchase() async {
        guard let product = products.first else { return }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    await updateSubscriptionStatus()
                }
            default: break
            }
        } catch {
            print("Purchase failed")
        }
    }
    
    func updateSubscriptionStatus() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == proID {
                    self.hasProAccess = true
                    return
                }
            }
        }
        self.hasProAccess = false
    }
}
