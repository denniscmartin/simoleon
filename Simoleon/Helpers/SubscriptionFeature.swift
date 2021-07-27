//
//  SubscriptionFeature.swift
//  Simoleon
//
//  Created by Dennis Concepción Martín on 26/07/2021.
//

import SwiftUI

struct SubscriptionFeature: View {
    var symbol: String
    var colour: Color
    var title: LocalizedStringKey
    var description: LocalizedStringKey
    
    var body: some View {
        HStack(alignment:.top) {
            Image(systemName: symbol)
                .foregroundColor(colour)
                .font(.title)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                
                Text(description)
            }
        }
    }
}

struct SubscriptionFeature_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionFeature(
            symbol: "star.circle.fill",
            colour: Color(.systemYellow),
            title: "Favorite Currencies",
            description: "Save your favorite currencies to access them quickly."
        )
    }
}
