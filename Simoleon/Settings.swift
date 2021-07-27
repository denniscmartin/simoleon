//
//  Settings.swift
//  Simoleon
//
//  Created by Dennis Concepción Martín on 19/07/2021.
//

import SwiftUI
import Purchases

struct Settings: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: []) private var defaultCurrency: FetchedResults<DefaultCurrency>
    
    @State private var selectedDefaultCurrency = ""
    @State private var showingSubscriptionPaywall = false
    @State private var entitlementIsActive = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    @State private var searchCurrency = ""
    
    let currencyPairs: [String] = parseJson("CurrencyPairs.json")
    
    var body: some View {
        List {
            Section(header: Text("Preferences")) {
                if entitlementIsActive {
                    Picker("Default currency", selection: $selectedDefaultCurrency) {
                        SearchBar(placeholder: "Search...", text: $searchCurrency)
                            .padding(5)
                        
                        ForEach(searchResults, id: \.self) { currencyPair in
                            Text(currencyPair)
                        }
                    }
                } else {
                    LockedCurrencyPicker()
                        .contentShape(Rectangle())
                        .onTapGesture { showingSubscriptionPaywall = true }
                }
            }
            
            Section(header: Text("Stay in touch")) {
                Link(destination: URL(string: "https://itunes.apple.com/app/id1576390953?action=write-review")!) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(Color(.systemRed))
                            .imageScale(.large)

                        Text("Rate Simoleon")
                    }
                }
                
                Link(destination: URL(string: "https://twitter.com/dennisconcep")!) {
                    HStack {
                        Image("TwitterLogo")
                            .resizable()
                            .frame(width: 30, height: 30)
                        
                        Text("Developer's Twitter")
                    }
                }
                
                Link(destination: URL(string: "https://dennistech.io/contact")!) {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(Color(.systemIndigo))
                            .imageScale(.large)
                        
                        Text("Contact")
                    }
                }
            }
            
            Section(header: Text("About")) {
                Link(destination: URL(string: "https://dennistech.io")!) {
                    Text("Website")
                }
                
                Link(destination: URL(string: "https://dennistech.io/privacy-policy")!) {
                    Text("Privacy Policy")
                }
                
                Link(destination: URL(string: "https://dennistech.io/terms-of-use")!) {
                    Text("Terms of Use")
                }
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("Ok")))
        }
        .onAppear {
            checkEntitlement()
            /*
             if selectedDefaultCurrency is empty:
             * View is appearing for the first time
             * Set initial default curency for picker
             else:
             * View is appearing after user selected another default currency
             * Save it to core data
             */
            if selectedDefaultCurrency == "" {
                selectedDefaultCurrency = defaultCurrency.first?.pair ?? "USD/GBP"
            } else {
                setCoreData()
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Settings")
        .sheet(isPresented: $showingSubscriptionPaywall, onDismiss: checkEntitlement) {
            SubscriptionPaywall(showingSubscriptionPaywall: $showingSubscriptionPaywall)
        }
        .if(UIDevice.current.userInterfaceIdiom == .phone) { content in
            NavigationView { content }
        }
    }
    
    /*
     If searched currency string is empty:
     * Show all currencies
     else:
     * Show filtered list of currencies containing searched currency string
     */
    var searchResults: [String] {
        if searchCurrency.isEmpty {
            return currencyPairs.sorted()
        } else {
            return currencyPairs.filter { $0.contains(searchCurrency.uppercased()) }
        }
    }
    
     
    // Save default currency to core data
    private func setCoreData() {
        if defaultCurrency.isEmpty {  // If it's empty -> add record
            let defaultCurrency = DefaultCurrency(context: viewContext)
            defaultCurrency.pair = selectedDefaultCurrency
            
            do {
                try viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        } else {  // If not, update record
            defaultCurrency.first?.pair = selectedDefaultCurrency
            try? viewContext.save()
        }
    }
    
    // Check if user subscription is active
    private func checkEntitlement() {
        #if targetEnvironment(simulator)
        // We're in simulator
        entitlementIsActive = true
        #else
        // We're in physical device
        Purchases.shared.purchaserInfo { (purchaserInfo, error) in
            if purchaserInfo?.entitlements["all"]?.isActive == true {
                entitlementIsActive = true
            } else {
                entitlementIsActive = false
            }
            
            if let error = error as NSError? {
                alertTitle = error.localizedDescription
                alertMessage = error.localizedFailureReason ?? ""
                showingAlert = true
            }
        }
        #endif
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
