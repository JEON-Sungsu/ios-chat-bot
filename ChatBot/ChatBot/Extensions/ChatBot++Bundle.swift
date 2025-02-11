//
//  ChatBot++Bundle.swift
//  ChatBot
//
//  Created by 김경록 on 1/3/24.
//

import Foundation

extension Bundle {
    static func getAPIKey(for openKey: String) -> String? {
        guard let url = Bundle.main.url(forResource: "ApiKeys", withExtension: "plist"),
              let data = try? Data(contentsOf: url) 
        else {
            print("Bundle 에서 ApiKeys.plist 를 찾을 수 없습니다.")
            return nil
        }
        
        do {
            if let dict = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String:String],
               let apiKey = dict[openKey] {
                return apiKey
            } 
            else {
                print("ApiKeys[(openKey)] 값을 찾을 수 없습니다.")
                return nil
            }
        } catch {
            print("ApiKeys 를 읽는 중 문제가 발생했습니다. (error)")
            return nil
        }
    }
}
