//
//  Model.swift
//  Zonky Stats
//
//  Created by lgergel on 15/11/2017.
//  Copyright © 2017 Lukas Gergel. All rights reserved.
//

import RealmSwift


// API response models
struct Loan {
    let id: String
    let datePublished: String
    let covered: Bool
}

struct Loans {
    var items: [Loan]
}

extension Loan {
    private enum Keys: String, SerializableKey {
        case id
        case datePublished
        case covered
    }
    
    init(serialized: SerializableD){
        id = ""
        datePublished = serialized.value(forKey: Keys.datePublished)!
        covered = true
    }
    
    public func key() -> String {
        return String(self.datePublished.prefix(7) + "-01")
    }
}

extension Loans {
    private enum Keys: String, SerializableKey {
        case id
        case datePublished
        case covered
    }
    
    init(serialization: Serializable) {
        items = [Loan]()
        var l: Loan
        for i in 0..<serialization.count {
            l = Loan(serialized: serialization[i])
            items.append(l)
        }
    }
}

// App specific models
struct AgregatedLoans {
    let interval: String
    var loans: Int
    var covered: Int
}

extension AgregatedLoans {
    init(interval: String) {
        self.interval = interval
        self.loans = 0
        self.covered = 0
    }
}

final class AgregatedLoansObject: Object {
    @objc dynamic var key = ""
    @objc dynamic var interval:Date?
    @objc dynamic var loans = 0
    @objc dynamic var covered = 0
    override static func primaryKey() -> String? {
        return "key"
    }
}


public protocol Persistable {
    associatedtype ManagedObject: RealmSwift.Object
    init(managedObject: ManagedObject)
    func managedObject() -> ManagedObject
}

extension AgregatedLoans: Persistable {
    public init(managedObject: AgregatedLoansObject) {
        interval = (managedObject.interval?.toMonthBeg())!
        loans = managedObject.loans
        covered = managedObject.covered
    }
    public func managedObject() -> AgregatedLoansObject {
        let o = AgregatedLoansObject()
        o.interval = Date.from(interval)
        o.loans = loans
        o.covered = covered
        o.key = (o.interval?.toMonthBeg())!
        return o
    }
}
