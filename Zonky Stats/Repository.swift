//
//  Repository.swift
//  Zonky Stats
//
//  Created by lgergel on 15/11/2017.
//  Copyright © 2017 Lukas Gergel. All rights reserved.
//
import Foundation
import RealmSwift

struct DataResponse {
    let loans: [AgregatedLoans]?
    let error: String?
    
    init(_ loans: [AgregatedLoans]?, _ error: String? = nil) {
        self.loans = loans
        self.error = error
    }
}


class Repository {

// private var realm: Realm?
// realm throw an exception when initialised in another (main) thread
//    init(realm: Reaml){
//        self.realm = realm
//    }
//

    func fetchMarketspaceData(apiRequest: ApiRequest<MarketplaceResource>, withCompletion completion: @escaping (DataResponse) -> Void) {
        DispatchQueue.global(qos: .background).async {
        autoreleasepool {
            let realm = try! Realm()
            let p = NSPredicate(format: "interval >= %@ AND interval < %@", apiRequest.resource.from as CVarArg, apiRequest.resource.to as CVarArg)
        
            let loans = realm.objects(AgregatedLoansObject.self).filter(p).sorted(byKeyPath: "interval")
        
            if loans.count > 88 {
                var aloans: [AgregatedLoans] = [AgregatedLoans]()
        
                for (_, element) in loans.enumerated(){
                    aloans.append(AgregatedLoans(managedObject: element))
                }
        
                let stats = DataResponse(aloans)
                DispatchQueue.main.async {
                    completion(stats)
                }
            }
            else {
                apiRequest.load { (response: (Loans?, String?)) -> Void  in
                    
                    if let error = response.1{
                        completion(DataResponse(nil, error))
                        return
                    }
                    
                    if let loans = response.0 {
                        var aloans: [AgregatedLoans] = [AgregatedLoans]()
                        for l in 0..<loans.items.count {
                            let key: String = String(loans.items[l].key())
                            if let _ = aloans.index(where: {String($0.interval) == key}) {
                            } else {
                                aloans.append(AgregatedLoans(interval: key))
                            }
                            if let offset = aloans.index(where: {String($0.interval) == key}) {
                                aloans[offset].loans = aloans[offset].loans + 1
                                if (loans.items[l].covered) {
                                    aloans[offset].covered = aloans[offset].covered + 1
                                }
                            }
                        }
            
                        //aloans = aloans.sorted(by: {$0.interval < $1.interval })
                        let realm = try! Realm()
                        try! realm.write {
                            for (_, elem) in aloans.enumerated() {
                                realm.add(elem.managedObject(), update: true)
                            }
                        }
            
                        let stats = DataResponse(aloans)
                        DispatchQueue.main.async {
                            completion(stats)
                        }
                    }
                }
            }
        }}
    }
}
