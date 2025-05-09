//
//  TransactionView.swift
//  Financial
//
//  Created by KeeR ReeK on 09.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

enum TransactionRoute: Hashable {
    case detail(Transaction)
    case edit(Transaction)
}

struct TransactionListView: View {
    
    var coreDataService = CoreDataManager.shared
    @State private var path = NavigationPath()
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [],
        predicate: NSPredicate(format: "email != nil"),
        animation: .default
    ) private var user: FetchedResults<User>
    
    var body: some View {
        VStack(spacing: 16) {
            
            HStack {
                Text("yourBalance")
                    .font(.custom("Montserrat-Bold", size: 24))
                    .foregroundColor(.white)
                Spacer()
            }
            
            if let currentUser = user.first {
                BalanceCardView(user: currentUser)
            }
            
            HStack {
                Text("transactions")
                    .font(.custom("Montserrat-Bold", size: 24))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            TransactionListViewContent(path: $path)
        }
        .padding()
        .background(Color("BackroundColor"))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapGesture {
            UIApplication.shared.dismissKeyboard()
        }
    }
}
