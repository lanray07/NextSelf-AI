import Foundation
import Observation
import StoreKit

@Observable
final class SubscriptionManager {
    private(set) var products: [Product] = []
    private(set) var selectedPlan: SubscriptionPlan = .free
    private(set) var isActive = false
    private let productIDs = ["nextself.premium.monthly", "nextself.premium.yearly", "nextself.elite.monthly"]

    func loadProducts() async {
        products = (try? await Product.products(for: productIDs)) ?? []
    }

    func purchase(_ plan: SubscriptionPlan) async {
        selectedPlan = plan
        isActive = plan != .free
    }

    func restore() async {
        isActive = selectedPlan != .free
    }
}
