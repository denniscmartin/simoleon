//
//  CurrencySelector.swift
//  Simoleon
//
//  Created by Dennis Concepción Martín on 18/07/2021.
//

import SwiftUI
import Purchases

struct CurrencySelector: View {
    @Binding var currencyPair: String
    @Binding var showingCurrencySelector: Bool
    @EnvironmentObject var subscriptionController: SubscriptionController
    
    @State private var searchCurrency = ""
    @State private var searching = false
    @State private var showingSubscriptionPaywall = false
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Search ...", text: $searchCurrency) { startedEditing in
                if startedEditing {
                         withAnimation {
                             searching = true
                         }
                     }
                } onCommit: {
                    withAnimation {
                        searching = false
                    }
                }
                
                Section(header: Text("All currencies")) {
                    ForEach(currencyPairs(), id: \.self) { currencyPair in
                        Button(action: { select(currencyPair) }) {
                            CurrencyRow(currencyPair: currencyPair)
                        }
                    }
                }
            }
            .gesture(DragGesture()
                 .onChanged({ _ in
                    UIApplication.shared.dismissKeyboard()
                    searching = false
                 })
             )
            .navigationTitle("Currencies")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: { showingCurrencySelector = false })
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    if searching {
                         Button("OK") {
                            searchCurrency = ""
                             withAnimation {
                                searching = false
                                UIApplication.shared.dismissKeyboard()
                             }
                         }
                     }
                }
            }
        }
        .sheet(isPresented: $showingSubscriptionPaywall) {
            Subscription(showingSubscriptionPaywall: $showingSubscriptionPaywall)
        }
    }
    
    private func currencyPairs() -> [String] {
        let currencyPairs: [String] = parseJson("CurrencyPairs.json")
        
        if searchCurrency.isEmpty {
            return currencyPairs
        } else {
            return currencyPairs.filter { $0.contains(searchCurrency.uppercased()) }
        }
    }
    
    
    private func select(_ currencyPair: String) {
        if subscriptionController.isActive {
            self.currencyPair = currencyPair
            showingCurrencySelector = false
        } else {
            showingSubscriptionPaywall = true
        }
    }
}


struct CurrencySelector_Previews: PreviewProvider {
    static var previews: some View {
        CurrencySelector(currencyPair: .constant("USD/GBP"), showingCurrencySelector: .constant(false))
            .environmentObject(SubscriptionController())
    }
}
