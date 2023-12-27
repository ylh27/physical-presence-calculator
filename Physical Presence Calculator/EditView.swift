//
//  EditView.swift
//  Physical Presence Calculator
//
//  Created by Lehan Yang on 12/27/23.
//

import SwiftUI

struct EditView: View {
    let travel: Travel
    
    var body: some View {
        Text(travel.title)
    }
}

#Preview {
    EditView(travel: Travel())
}
