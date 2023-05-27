//
//  PostData.swift
//  yazlabikibir
//
//  Created by Can Öncü on 20.04.2023.
//

import Foundation
struct Results :Decodable{
    let meta : [Post]
}
struct Post : Decodable, Identifiable{
    var idd : String{
        return id
    }
    let id : String
    let uuid : String
}
