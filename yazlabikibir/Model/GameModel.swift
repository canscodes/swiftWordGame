//
//  GameModel.swift
//  yazlabikibir
//
//  Created by Can Öncü on 30.03.2023.
//

import SwiftUI
import Foundation


var gamePoint = 0
var blockType = ""
var blockTypeArray : [String] = []


func generateRandomLetters(rows: Int, columns: Int) -> [[String]] {
    var grid: [[String]] = []
    let letters = "abcdefghijklmnopqrstuvwxyz"

    for _ in 0..<rows {
        var row: [String] = []
        for _ in 0..<columns {
            let randomIndex = Int.random(in: 0..<letters.count)
            let letter = String(letters[letters.index(letters.startIndex, offsetBy: randomIndex)])
            row.append(letter)
        }
        grid.append(row)
    }

    return grid
}



// Example usage
let grid = generateRandomLetters(rows: 5, columns: 5)



class GameModel:ObservableObject{
    
    //var letters = ["A", "B", "C", "Ç", "D", "E", "F", "G", "Ğ", "H", "I", "İ", "J", "K", "L", "M", "N", "O", "Ö", "P", "R", "S", "Ş", "T", "U", "Ü", "V", "Y", "Z"]
    //let uretilen = arc4random_uniform(50)
    var numRows : Int
    var numColumns : Int
    @Published var gameBoard: [[GameBlock?]]
    @Published var tetromino: Tetromino?
    
    var timer: Timer?
    var speed: Double
    var rowLetters: [String]
    var columnLetters: [String]
    
    init(numRows: Int = 10, numColumns: Int = 8) {
        self.numRows = numRows
        self.numColumns = numColumns
        gameBoard = Array(repeating: Array(repeating: nil, count: numRows), count: numColumns)
        speed = 0.1
        rowLetters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
        columnLetters = ["0", "1", "2", "3", "4", "5", "6", "7"]
        resumeGame()
    }
    
    
   
    func blockClicked(row: Int, column: Int) {
        let rowLetter = rowLetters[row]
        let columnLetter = columnLetters[column]
        print("Column: \(columnLetter), Row: \(rowLetter)")

        if gameBoard[column][row] == nil {
            gameBoard[column][row] = GameBlock(blockType: BlockType.allCases.randomElement()!)
            if let block = gameBoard[column][row] {
                print("Block created at Column: \(columnLetter), Row: \(rowLetter), Type: \(block.blockType)")
            }
        } else {
            if let block = gameBoard[column][row] {
                print("Block removed from Column: \(columnLetter), Row: \(rowLetter), Type: \(block.blockType)")
                blockType = String(describing: block.blockType)
                //gamePoint = gamePoint+1
                blockTypeArray.append(blockType)
                print(blockTypeArray)
           
                
                
            }
            gameBoard[column][row] = nil
        }
    }
    
  //  init(numRows : Int = 10, numColumns : Int =  8){
    //    self.numRows = numRows
    //      self.numColumns = numColumns
    //      gameBoard = Array(repeating: Array(repeating: nil, count: numRows), count: numColumns)
    //      speed = 0.2
    //      resumeGame()
    //  }
    //func blockClicked(row :Int, column: Int){
     //   print("Column:\(column),Row : \(row)")
     //   if gameBoard[column][row] == nil {
   //         gameBoard[column][row] = GameBlock(blockType: BlockType.allCases.randomElement()!)
    //    }else{
    //         gameBoard[column][row] = nil
    //     }
    //  }
    func resumeGame(){
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: speed, repeats: true, block: runEngine)
        
    }
    func pauseGame(){
        timer?.invalidate()
        
    }
    
    func runEngine(timer: Timer){
        guard tetromino != nil else{
            print("spawning new tetromino")
            tetromino = Tetromino.createNewTetromino(numRows: 10, numColumns: 0)
           // tetromino = Tetromino(origin: BlockLocation(row: 9, column: 0), blockType: .i)
            if !isValidTetromino(testTetromino: tetromino!){
                print("GAME OVER!")
                let alertController = UIAlertController(title: "GAME OVER!", message: nil, preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(okAction)
                            UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
               

                pauseGame()
            }
            return
        }
        
        if moveTetrominoDown(){
            //print("moving tetromino down")
            return
        }
        print("placing tetromino")
        placeTetromino()
        
        
    }
    
    func dropTetromino(){
       // while(moveTetrominoDown())
    }
    
    func moveTetrominoRight()->Bool{
        return moveTetromino (rowOffset: 0, columnOffset: 1)
    }
    func moveTetrominoLeft()->Bool{
        return moveTetromino (rowOffset: 0, columnOffset: -1)
    }
    func moveTetrominoDown()->Bool{
        return moveTetromino (rowOffset: -1, columnOffset: 0)
    }
    
    func moveTetromino (rowOffset: Int,columnOffset: Int) ->Bool{
        guard let currentTetromino = tetromino else {return false}
        
        let newTetromino = currentTetromino.moveBy(row: rowOffset, column: columnOffset)
        if isValidTetromino(testTetromino: newTetromino){
            tetromino = newTetromino
            return true
            
        }
        return false
        
    }
    func isValidTetromino(testTetromino:Tetromino)-> Bool{
        for block in testTetromino.block{
            let row = testTetromino.origin.row + block.row
            if row<0 || row >= numRows {return false}
            let column = testTetromino.origin.column + block.column
            if column<0 || column >= numColumns {return false}
            if gameBoard[column][row] != nil {return false}
            
            
        }
        return true
    }
    
    
    func placeTetromino() {
        guard let currentTetromino = tetromino else {
            return
        }
        for block in currentTetromino.block {
            let row = currentTetromino.origin.row + block.row
            if row < 0 || row >= numRows {
                continue
            }
            let column = currentTetromino.origin.column + block.column
            if column < 0 || column >= numColumns {
                continue
            }
            let rowLetter = rowLetters[row]
            let columnLetter = columnLetters[column]
            gameBoard[column][row] = GameBlock(blockType: currentTetromino.blockType)
            print("Placed block at \(columnLetter)\(rowLetter)")
        }
        tetromino = nil
    }
}

    // func placeTetromino(){
        //   guard let currentTetromino = tetromino else{
            //      return
            //  }
        //  for block in currentTetromino.block{
            //    let row = currentTetromino.origin.row + block.row
            //    if row<0 || row >= numRows {continue }
            //    let column = currentTetromino.origin.column + block.column
            //    if column<0 || column >= numColumns {continue }
            //       gameBoard[column][row] = GameBlock(blockType: currentTetromino.blockType)
            
            //   }
        //   tetromino = nil
   // }
//}
struct GameBlock{
    var blockType:BlockType
    
}
enum BlockType: CaseIterable{

    case a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,r,s,t,u,v,y,z

}
let blockVar = Int.random(in: 0...7)
struct Tetromino{
    var origin : BlockLocation
    var blockType :BlockType
    var block : [BlockLocation]{
        return Tetromino.getBlocks(blockType: blockType)

    }
    
    func moveBy(row: Int, column: Int) -> Tetromino{
        let newOrigin = BlockLocation(row: origin.row+row, column: origin.column+column)
        return Tetromino(origin: newOrigin, blockType: blockType)
    }
    static func getBlocks(blockType: BlockType) -> [BlockLocation]{
        switch blockType {
        case .a:
            return [
                BlockLocation(row: 0, column: 0)
                
            ]
           case .b:
            return [
                BlockLocation(row: 0, column: 1)
                
            ]
           case .c:
            return [
                BlockLocation(row: 0, column: 2)
                
            ]
           case .d:
            return [
                BlockLocation(row: 0, column: 3)
                
            ]
           case .e:
            return [
                BlockLocation(row: 0, column: 4)
                
            ]
           case .f:
            return [
                BlockLocation(row: 0, column: 5)
                
            ]
           case .g:
            return [
                BlockLocation(row: 0, column: 6)
                
            ]
           case .h:
            return [
                BlockLocation(row: 0, column: 7)
                
            ]
           case .i:
            return [
                BlockLocation(row: 0, column: 0)
                
            ]
           case .j:
            return [
                BlockLocation(row: 0, column: 1)
                
            ]
           case .k:
            return [
                BlockLocation(row: 0, column: 2)
                
            ]
           case .l:
            return [
                BlockLocation(row: 0, column: 3)
                
            ]
           case .m:
            return [
                BlockLocation(row: 0, column: 4)
                
            ]
           case .n:
            return [
                BlockLocation(row: 0, column: 5)
                
            ]
           case .o:
            return [
                BlockLocation(row: 0, column: 6)
                
            ]
           case .p:
            return [
                BlockLocation(row: 0, column: 7)
                
            ]
           
           case .r:
            return [
                BlockLocation(row: 0, column: 0)
                
            ]
           case .s:
            return [
                BlockLocation(row: 0, column: 1)
                
            ]
           case .t:
            return [
                BlockLocation(row: 0, column: 2)
                
            ]
           case .u:
            return [
                BlockLocation(row: 0, column: 3)
                
            ]
           case .v:
            return [
                BlockLocation(row: 0, column: 4)
                
            ]
          case .y:
         return [
             BlockLocation(row: 0, column: 5)
             
         ]
           
           case .z:
               
            return [
                BlockLocation(row: 0, column: 6)
                
            ]


        }
        
    }
    static func createNewTetromino(numRows:Int, numColumns:Int) -> Tetromino{
        let blockType = BlockType.allCases.randomElement()!
        var maxRow = 0
        for block in getBlocks(blockType: blockType){
            maxRow = max(maxRow, block.row)
            
        }
        
        let origin = BlockLocation(row: numRows - 1 - maxRow, column: (numColumns-1)/2)
        print(origin)
        return Tetromino(origin: origin, blockType: blockType)
    }
    
}
struct BlockLocation{
    var row : Int
    var column : Int
    
}
struct Block {
    let location: BlockLocation
    var name: String // Add a name property
    
    init(location: BlockLocation, name: String) {
        self.location = location
        self.name = name
    }
}
