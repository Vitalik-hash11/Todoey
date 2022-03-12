//
//  Item.swift
//  Todoey
//
//  Created by newbie on 12.03.2022.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var creationDate: Date = Date()
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
