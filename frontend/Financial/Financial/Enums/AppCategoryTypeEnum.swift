//
//  AppCategoryTypeEnum.swift
//  Financial
//
//  Created by KeeR ReeK on 11.05.2025.
//  Copyright (c) 2025 Financial

import Foundation


enum AppCategoryTypeCosts {
    case Products
    case Devices
    case CafesRestaurants
    case UtilitiesHome
    case Entertainment
    case Transports
    case Animals
    case BeautyHealth
    case ClothingAccessories
    case Charity
    case OtherSourcesOfCosts
    
    static func fromServerKey(_ key: String) -> AppCategoryTypeCosts {
        switch key.lowercased() {
        case "products": return .Products
        case "devices": return .Devices
        case "cafes_restaurants": return .CafesRestaurants
        case "utilities_home": return .UtilitiesHome
        case "entertainment": return .Entertainment
        case "transports": return .Transports
        case "animals": return .Animals
        case "beauty_health": return .BeautyHealth
        case "clothing_accessories": return .ClothingAccessories
        case "charity": return .Charity
        default : return .OtherSourcesOfCosts
        }
    }
    
    var localizedName: String {
        switch self {
        case .Products:
            return NSLocalizedString("products", comment: "Назва категорії Продукти")
        case .Devices:
            return NSLocalizedString("devices", comment: "Назва категорії Девайси")
        case .CafesRestaurants:
            return NSLocalizedString("cafes_restaurants", comment: "Назва категорії Кафе")
        case .UtilitiesHome:
            return NSLocalizedString("utilities_home", comment: "Назва категорії Утиліти")
        case .Entertainment:
            return NSLocalizedString("entertainment", comment: "Назва категорії розваги")
        case .Transports:
            return NSLocalizedString("transports", comment: "Назва категорії транспорт")
        case .Animals:
            return NSLocalizedString("animals", comment: "Назва категорії тварини")
        case .BeautyHealth:
            return NSLocalizedString("beauty_health", comment: "Назва категорії косметика")
        case .ClothingAccessories:
            return NSLocalizedString("clothing_accessories", comment: "Назва категорії одяг")
        case .Charity:
            return NSLocalizedString("charity", comment: "Назва категорії благодійність")
        case .OtherSourcesOfCosts:
            return NSLocalizedString("other_sources_of_costs", comment: "Назва категорії інші витрати")
            
        }
    }
}

enum AppCategoryTypeIncomes {
    case Business
    case Payments
    case Other_sources_of_income
    
    static func fromServerKey(_ key: String) -> AppCategoryTypeIncomes {
        switch key.lowercased() {
        case "business": return .Business
        case "payments": return .Payments
        default: return .Other_sources_of_income
        }
    }
    
    var localizedName: String {
        switch self {
        case .Business:
            return NSLocalizedString("business", comment: "Назва категорії бізнес")
        case .Payments:
            return NSLocalizedString("payments", comment: "Назва категорії виплати")
        default:
            return NSLocalizedString("other_sources_of_income", comment: "Назва категорії інші доходи")
        }
    }
}
