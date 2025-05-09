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


struct BalanceCardView: View {
    
    @ObservedObject var user: User
    
    var body: some View {
        ZStack(alignment: .leading) {
            Image("cardBalance")
                .resizable()
                .scaledToFill()
                .clipped()
            VStack(alignment: .leading) {
                Spacer()
                if abs(user.balance) > 999999999999 {
                    ScrollView(.horizontal) {
                        Text(balanceFormatted)
                            .font(.custom("Montserrat-SemiBold", size: 36))
                            .foregroundColor(.white)
                            .padding(.leading, 30)
                            .padding(.top, 40)
                            .clipped()
                    }
                    .clipped()
                    .mask(
                        RoundedRectangle(cornerRadius: 1)
                            .frame(width: UIScreen.main.bounds.width - 32 - 60)
                    )
                } else {
                    Text(balanceFormatted)
                        .font(.custom("Montserrat-SemiBold", size: 36))
                        .foregroundColor(.white)
                        .padding(.leading, 30)
                        .padding(.top, 40)
                }
                Spacer()
                Text("02/24")
                    .font(.custom("Montserrat-SemiBold", size: 11))
                    .foregroundColor(.white)
                    .padding(.leading, 30)
                    .padding(.bottom, 29)
            }
        }
        .frame(maxWidth: UIScreen.main.bounds.width - 32)
        .frame(height: 200)
        .offset(y: -15)
    }
    
    var balanceFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.decimalSeparator = "."
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: user.balance)) ?? "0.00"
    }
}
