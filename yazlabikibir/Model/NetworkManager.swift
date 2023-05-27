//
//  NetworkManager.swift
//  yazlabikibir
//
//  Created by Can Öncü on 20.04.2023.
//

import Foundation
class NetworkManager : ObservableObject{
    @Published var posts = [Post]()
func fetchData(){
    if let url = URL(string: "https://www.dictionaryapi.com/api/v3/references/collegiate/json/voluminous?key=your-api-key"){
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { (data,response,error) in
            if error == nil {
                let decoder = JSONDecoder()
                if let safeData = data {
                    do{
                        let results = try decoder.decode(Results.self, from: safeData)
                        self.posts = results.meta
                    }
                    catch{
                        print(error)
                    }
                }
            }
               
            }
            task.resume()
        }
        }
    }

