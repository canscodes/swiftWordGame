//
//  GameViewModel.swift
//  yazlabikibir
//
//  Created by Can Öncü on 29.03.2023.
//

import SwiftUI
import Combine
class GameViewModel:ObservableObject{
    
    @Published var gameModel = GameModel()
    var numRows : Int {gameModel.numRows}
    var numColumns : Int {gameModel.numColumns}
    var gameBoard: [[GameSquare]]{
        var board = gameModel.gameBoard.map{ $0.map(convertToSquare)}
        if let tetromino = gameModel.tetromino{
            for blockLocation in tetromino.block{
                board[blockLocation.column+tetromino.origin.column][blockLocation.row+tetromino.origin.row] = GameSquare(color: getColor(blockType: tetromino.blockType))
            }
        }
            return board
    }
    var anyCancellable: AnyCancellable?
    var lastMoveLocation: CGPoint?
    init(){
        anyCancellable = gameModel.objectWillChange.sink{
            self.objectWillChange.send()
        }
    }
    
    func convertToSquare(block:GameBlock?) -> GameSquare {
        
        if let blockType = block?.blockType {
               return GameSquare(color: getColor(blockType: blockType))
           } else {
               // handle the case where block?.blockType is nil
               return GameSquare(color: getColor(blockType: block?.blockType))
           }
        
    }
    func getColor(blockType:BlockType?)->Color{
        switch blockType {
        case .a:
            return .gameLightBlue
        case .b:
            return .gameDarkBlue
        case .c:
            return .gameOrange
        case .d:
            return .gameYellow
        case .e:
            return .gameGreen
        case .f:
            return .gamePurple
        case .g:
            return .gameRed
        case .h:
            return .gameLightBlue
        case .i:
            return .gameDarkBlue
        case .j:
            return .gameOrange
        case .k:
            return .gameYellow
        case .l:
            return .gameGreen
        case .m:
            return .gamePurple
        case .n:
            return .gameRed
        case .o:
            return .gameOrange
        case .p:
            return .gameDarkBlue
        case .r:
            return .gameGreen
        case .s:
            return .gamePurple
        case .t:
            return .gameDarkBlue
        case .u:
            return .gameYellow
        case .v:
            return .gameLightBlue
        case .y:
            return .gameDarkBlue
        case .z:
            return .gameOrangeShadow
        default:
                return .gameBlack
            
        }
    }
    func squareClicked(row:Int,column:Int){
        gameModel.blockClicked(row: row, column: column)
    }
    
    func getMoveGesture()->some Gesture{
        return DragGesture()
            .onChanged(onMoveChanged(value:))
            //.onEnded(onMoveEnded( :))
    }
    func onMoveChanged(value: DragGesture.Value){
        guard let start = lastMoveLocation else{
            lastMoveLocation = value.location
            return
        }
        let xDiff = value.location.x - start.x
        if xDiff > 10{
            print("moving right")
            let _ = gameModel.moveTetrominoRight()
            lastMoveLocation = value.location
            return
            
        }
        if xDiff < -10{
            //print("moving left")
            let _ = gameModel.moveTetrominoLeft()
            lastMoveLocation = value.location
            return
            
        }
        let yDiff = value.location.y - start.y
        if yDiff > 10{
            //print("moving down")
            let _ = gameModel.moveTetrominoDown()
            lastMoveLocation = value.location
            return
        }
        if yDiff < -10{
            //print("dropping")
            gameModel.dropTetromino()
            lastMoveLocation = value.location
            return
        }
    }
    
   // func onMoveEnded( : DragGesture.Value) {
   //lastMoveLocation = nil
   // }
}

struct GameSquare{
    var color:Color
}

