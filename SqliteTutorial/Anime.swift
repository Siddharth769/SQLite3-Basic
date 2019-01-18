//
//  Anime.swift
//  SqliteTutorial
//
//  Created by siddharth on 18/01/19.
//  Copyright © 2019 clarionTechnologies. All rights reserved.
//

import Foundation
import UIKit

class Anime {
    var id: Int
    var name: String
    var ratings: Int
    
    init(id: Int, name: String, ratings: Int){
        self.id = id
        self.name = name
        self.ratings = ratings
    }
}
