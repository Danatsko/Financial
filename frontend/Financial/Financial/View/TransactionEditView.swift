//
//  TransactionEditView.swift
//  Financial
//
//  Created by KeeR ReeK on 09.05.2025.
//  Copyright (c) 2025 Financial

import SwiftUI

private enum StyleConstants {
    static let textFieldBackgroundColor = Color("TextFieldBackround")
    static let primaryTextColor = Color.white
    static let cornerRadius: CGFloat = 30
    static let defaultPadding: CGFloat = 16
    
    static func boldFont(size: CGFloat) -> Font {
        .custom("Montserrat-Bold", size: size)
    }
    
    static func semiBoldFont(size: CGFloat) -> Font {
        .custom("Montserrat-SemiBold", size: size)
    }
}

struct TransactionEditView: View {
    
    @ObservedObject var viewModel: TransactionEditViewModel
    @EnvironmentObject var appState: AppState
    
    private var customInputFont: Font {
        viewModel.customFont
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                headerTitle
                
                amountField
                
                titleField
                
                descriptionEditor
                
                categoryPicker
                
                paymentMethodPicker
                
                datePickerField
                
                swipeToConfirmButton
                
                Spacer()
            }
            .padding(StyleConstants.defaultPadding)
        }
        .navigationBarBackButtonHidden()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BackroundColor").edgesIgnoringSafeArea(.all))
        .onTapGesture {
            dismissKeyboard()
        }
    }
    
    // MARK: - Subviews
    
    private var headerTitle: some View {
        Text("editing")
            .font(StyleConstants.boldFont(size: 24))
            .foregroundColor(StyleConstants.primaryTextColor)
    }
    
    private var amountField: some View {
        ZStack {
            StyleConstants.textFieldBackgroundColor
                .cornerRadius(StyleConstants.cornerRadius)
            
            CurrencyFieldView(value: $viewModel.amount, formatter: viewModel.formatter)
                .foregroundColor(StyleConstants.primaryTextColor)
                .font(StyleConstants.semiBoldFont(size: 23))
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(minHeight: 48)
                .padding(.horizontal, StyleConstants.defaultPadding)
        }
        .frame(height: 60)
    }
    
    private var titleField: some View {
        TextField("", text: $viewModel.title, prompt:
                    Text("title")
                        .foregroundColor(StyleConstants.primaryTextColor.opacity(0.7))
                        .font(customInputFont)
        )
        .foregroundColor(StyleConstants.primaryTextColor)
        .font(customInputFont)
        .padding(StyleConstants.defaultPadding)
        .frame(minHeight: 48)
        .background(StyleConstants.textFieldBackgroundColor)
        .cornerRadius(StyleConstants.cornerRadius)
    }
    
    private var descriptionEditor: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $viewModel.descriptionText)
                .frame(height: 100)
                .scrollContentBackground(.hidden)
                .padding(EdgeInsets(top: StyleConstants.defaultPadding - 5, leading: StyleConstants.defaultPadding - 5, bottom: StyleConstants.defaultPadding - 5, trailing: StyleConstants.defaultPadding - 5))
                .background(StyleConstants.textFieldBackgroundColor)
                .foregroundColor(StyleConstants.primaryTextColor)
                .font(StyleConstants.semiBoldFont(size: 18))
                .cornerRadius(StyleConstants.cornerRadius)
            
            if viewModel.descriptionText.isEmpty {
                Text("description")
                    .foregroundColor(StyleConstants.primaryTextColor.opacity(0.7))
                    .font(StyleConstants.semiBoldFont(size: 18))
                    .padding(EdgeInsets(top: StyleConstants.defaultPadding, leading: StyleConstants.defaultPadding, bottom: 0, trailing: 0))
                    .allowsHitTesting(false)
            }
        }
    }
    
    private func pickerRow<SelectionValue: Hashable, Content: View>(
        titleKey: LocalizedStringKey,
        selection: Binding<SelectionValue>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack {
            Text(titleKey)
                .foregroundColor(StyleConstants.primaryTextColor)
                .font(customInputFont)
            Spacer()
            Picker("", selection: selection) {
                content()
            }
            .pickerStyle(MenuPickerStyle())
            .tint(StyleConstants.primaryTextColor) // Колір стрілки пікера
        }
        .padding(StyleConstants.defaultPadding)
        .frame(minHeight: 48)
        .background(StyleConstants.textFieldBackgroundColor)
        .cornerRadius(StyleConstants.cornerRadius)
    }
    
    private var categoryPicker: some View {
        pickerRow(titleKey: "category", selection: $viewModel.pickedCategory) {
            ForEach(viewModel.selectoryCategory(), id: \.self) { category in
                Text(category)
                    .font(customInputFont)
                    .foregroundColor(StyleConstants.primaryTextColor)
            }
        }
    }
    
    private var paymentMethodPicker: some View {
        pickerRow(titleKey: "paymentMethod", selection: $viewModel.pickedPayment) {
            ForEach(viewModel.paymentArray, id: \.self) { paymentMethod in
                Text(paymentMethod)
                    .font(customInputFont)
                    .foregroundColor(StyleConstants.primaryTextColor)
            }
        }
    }
    
    private var datePickerField: some View {
        HStack {
            Text("date")
                .foregroundColor(StyleConstants.primaryTextColor)
                .font(customInputFont)
                .padding(.leading)
            
            DatePicker("", selection: $viewModel.dateCreate, in: viewModel.minDate...viewModel.maxDate, displayedComponents: .date)
                .labelsHidden()
                .tint(StyleConstants.primaryTextColor)
                .preferredColorScheme(.dark)
        }
        .padding(.trailing)
        .frame(minHeight: 48)
        .background(StyleConstants.textFieldBackgroundColor)
        .cornerRadius(StyleConstants.cornerRadius)
    }
    
    private var swipeToConfirmButton: some View {
        SwipeToConfirmView() {
            Task {
                let result = await viewModel.updateTransaction()
                if !result.0, result.1 == "logout" {
                    await MainActor.run {
                        appState.isLoggedIn = false
                    }
                    CoreDataManager.shared.deleteUser()
                }
            }
            
            Task {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                await MainActor.run {
                    if !viewModel.path.isEmpty {
                        viewModel.path.removeLast(viewModel.path.count)
                    }
                    viewModel.resetForm()
                }
            }
        }
        .disabled(!viewModel.isFormValid)
        .opacity(viewModel.isFormValid ? 1.0 : 0.5)
    }
    
    // MARK: - Helper Methods
    
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
