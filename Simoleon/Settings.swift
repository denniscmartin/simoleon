//
//  Settings.swift
//  Simoleon
//
//  Created by Dennis Concepción Martín on 19/07/2021.
//

import SwiftUI
import Purchases

struct Settings: View {
    @EnvironmentObject var subscriptionController: SubscriptionController
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: []) private var defaultCurrency: FetchedResults<DefaultCurrency>
    
    @State private var selectedDefaultCurrency = ""
    @State private var showingSubscriptionPaywall = false
    
    let currencyPairs: [String] = parseJson("CurrencyPairs.json")
    
    var body: some View {
        List {
            Section(header: Text("Subscription")) {
                NavigationLink("Information", destination: SubscriberInfo())
                if !subscriptionController.isActive {
                    Text("Subscribe")
                        .onTapGesture { showingSubscriptionPaywall = true }
                }
            }
            
            Section(header: Text("Preferences")) {
                if subscriptionController.isActive {
                    Picker("Default currency", selection: $selectedDefaultCurrency) {
                        ForEach(currencyPairs.sorted(), id: \.self) { currencyPair in
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
                        Image(systemName: "envelope.circle.fill")
                            .renderingMode(.original)
                            .imageScale(.large)
                        
                        Text("Contact")
                    }
                }
            }
            
            Section(header: Text("About")) {
                Link("Website", destination: URL(string: "https://dennistech.io")!)
                Link("Privacy Policy", destination: URL(string: "https://dennistech.io")!)
            }
        }
        .onAppear(perform: onAppear)
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Settings")
        .sheet(isPresented: $showingSubscriptionPaywall) {
            Subscription(showingSubscriptionPaywall: $showingSubscriptionPaywall)
                .environmentObject(subscriptionController)
        }
        .if(UIDevice.current.userInterfaceIdiom == .phone) { content in
            NavigationView { content }
        }
    }
    
    private func onAppear() {
        // Set initial value of the picker
        if selectedDefaultCurrency == "" {
            self.selectedDefaultCurrency = defaultCurrency.first?.pair ?? "USD/GBP"
        } else {
            setCoreData()
        }
    }
    
    private func setCoreData() {
        if self.defaultCurrency.isEmpty {  // If it's empty -> add record
            let defaultCurrency = DefaultCurrency(context: viewContext)
            defaultCurrency.pair = selectedDefaultCurrency
            
            do {
                try viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        } else {  // If not, update record
            self.defaultCurrency.first?.pair = selectedDefaultCurrency
            try? viewContext.save()
        }
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
            .environmentObject(SubscriptionController())
    }
}
