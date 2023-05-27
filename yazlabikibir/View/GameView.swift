//
//  GameView.swift
//  yazlabikibir
//
//  Created by Can Öncü on 29.03.2023.
//

import SwiftUI
var adverseEnjoyement = 0

struct GameView: View {
    @ObservedObject var game = GameViewModel()
    @ObservedObject var networkManager = NetworkManager()
    
    func checkWordInTdk(word: String) {
          let urlString = "https://sozluk.gov.tr/gts?ara=\(word)"
          let url = URL(string: urlString)!
          let task = URLSession.shared.dataTask(with: url) { data, response, error in
              guard let data = data, error == nil else {
                  print(error?.localizedDescription ?? "Unknown error")
                  return
              }
              if let httpResponse = response as? HTTPURLResponse {
                  if httpResponse.statusCode == 200 {
                      do {
                          print(String(data: data, encoding: .utf8))
                          
                          let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                          if let stringData = String(data: data, encoding: .utf8) {
                              if stringData.contains("{\"error\":\"Sonuç bulunamadı\"}") {
                                  gamePoint -= 1
                                  adverseEnjoyement = adverseEnjoyement+1
                                  if adverseEnjoyement == 3 {
                                      print("Game Over")
                                    
                                                  
                                  }else {}
                                  
                                
                                  
                              } else {
                                  gamePoint += 1
                              }
                          }
                          
                          if let maddeValue = responseJSON?["madde"] {
                              
                              if let entries = maddeValue as? [[String: Any]], !entries.isEmpty {
                                  // Kelime TDK sözlüğünde bulundu
                                  gamePoint += 1
                                  print("Kelime TDK sözlüğünde var")
                                  blockTypeArray = [""]
                              } else if let entries = maddeValue as? [String: Any], !entries.isEmpty {
                                  // Kelime TDK sözlüğünde bulundu
                                  gamePoint += 1
                                  print("Kelime TDK sözlüğünde bulundu")
                                  blockTypeArray = [""]
                              } else {
                                  // Kelime TDK sözlüğünde bulunamadı
                                  print("Kelime TDK sözlüğünde yok")
                              }
                          } else {
                              // Kelime TDK sözlüğünde bulunamadı
                              print("Kelime TDK sözlüğünde bulunamadı")
                          }
                      } catch {
                          // JSON ayrıştırma hatası
                          print("JSON ayrıştırma hatası")
                      }
                  } else {
                      // Yanıt kodu hatalı
                      print("Yanıt kodu hatalı")
                  }
              }
          }
          task.resume()
      }


    
    var body: some View {
        VStack {
            Text(String(gamePoint))
                .font(.system(size: 24))
                .foregroundColor(.black)
            
            
            GeometryReader { (geometry: GeometryProxy) in
                self.drawBoard(boundingRect: geometry.size)
            }
            .gesture(game.getMoveGesture())
            
            VStack {
                Text(blockTypeArray.joined(separator: ""))
                    .font(.system(size: 24))
                    .foregroundColor(.black)
            }
            
            Button(action: {
                // Code to execute when the button is tapped
                checkWordInTdk(word: blockTypeArray.joined(separator: ""))
                print(blockTypeArray.joined(separator: ""))
                print("button tapped")
                blockTypeArray = [""]
            }) {
                Text("✓")
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.white)
                    .font(.system(size: 25))
                    .foregroundColor(.green)
                    .frame(width: 55, height: 25)
                    .cornerRadius(10)
            }
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 2)
            )
            .padding(.bottom, 20)
            .simultaneousGesture(TapGesture())
            
        }
        Button(action: {
            // Code to execute when the button is tapped
           
            blockTypeArray = [""]
        }) {
            Text("✘")
                .foregroundColor(.black)
                .padding()
                .background(Color.white)
                .font(.system(size: 25))
                .foregroundColor(.green)
                .frame(width: 55, height: 25)
                .cornerRadius(10)
        }
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black, lineWidth: 2)
        )
        .padding(.bottom, 20)
        .simultaneousGesture(TapGesture())
        
    
    }

    
    func drawBoard(boundingRect: CGSize)-> some View{
        let columns = self.game.numColumns
        let rows = self.game.numRows
        let blocksize = min(boundingRect.width/CGFloat(columns),boundingRect.height/CGFloat(rows))
        let xoffset = (boundingRect.width - blocksize*CGFloat(columns))/2
        let yoffset = (boundingRect.height - blocksize*CGFloat(rows))/2
        
        return ForEach(0...columns-1, id:\.self){ (column:Int) in
            ForEach(0...rows-1, id:\.self){ (row:Int) in
                Path { path in
                    let x = xoffset + blocksize * CGFloat(column)
                    let y = boundingRect.height - yoffset - blocksize*CGFloat(row+1)
                    let rect = CGRect(x: x, y: y, width: blocksize, height: blocksize)
                    path.addRect(rect)
                }
                .fill(self.game.gameBoard[column][row].color)
                .onTapGesture {
                    self.game.squareClicked(row: row, column: column)
                    
                }
            }
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
