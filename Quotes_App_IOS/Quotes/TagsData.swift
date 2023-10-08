//
//  TagsData.swift
//  Quotes
//
//  Created by Alon Rozmarin on 03/10/2023.
//

import Foundation
import SwiftData

@Model
class TagsData {
    var tagsList: [String]
    
    init(tags: [String]) {
        self.tagsList = tags
    }
}
