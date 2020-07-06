//
//  User.swift
//  TaskKeeper
//
//  Created by Светлана Шардакова on 06.07.2020.
//  Copyright © 2020 Светлана Шардакова. All rights reserved.
//

import Foundation
import Firebase

struct AppUser {
    
    let uid: String
    let email: String
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email!
    }
}
