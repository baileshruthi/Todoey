//
//  Category.swift
//  Todoey
//
//  Created by iw02 on 01/03/18.
//  Copyright © 2018 iw02. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var colour: String = ""
    let items = List<Item>()
   // let array = Array<Int>()
    
}
