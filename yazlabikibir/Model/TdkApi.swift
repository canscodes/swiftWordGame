import Foundation

func searchForWord(word: String) -> Bool {
    let encodedWord = word.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    let urlString = "https://sozluk.gov.tr/gts?ara=\(encodedWord)"
    let url = URL(string: urlString)!
    let semaphore = DispatchSemaphore(value: 0)
    var found = false
    
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        defer { semaphore.signal() }
        guard let data = data, error == nil else {
            print(error?.localizedDescription ?? "Unknown error")
            return
        }
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 200 {
                do {
                    let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    if let entries = responseJSON["madde"] as? [[String: Any]] {
                        if entries.count > 0 {
                            found = true
                        }
                    }
                } catch {
                    print("JSON parsing error")
                }
            } else {
                print("HTTP error \(httpResponse.statusCode)")
            }
        }
    }
    task.resume()
    semaphore.wait()
    return found
}

// Example usage:
let isWordFound = searchForWord(word: "köpek")


