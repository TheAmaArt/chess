import 'package:chess_1/components/dead_piece.dart';
import 'package:chess_1/components/square.dart';
import 'package:chess_1/helper/helper_methods.dart';
import 'package:chess_1/values/colors.dart';
import 'package:flutter/material.dart';
import 'package:chess_1/components/piece.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
//A 2 Dimensional list representing the Chessboard
// With each position possibly containing a chess piece
  late List<List<ChessPiece?>> board;

// The currently selected piece on the chess board
// If no piece is selcted, this is null
  ChessPiece? selectedPiece;

  // The Row index of the selected piece
  // Default value -1 indicated no piece is currently selected
  int selectedRow = -1;

  // The col index of the selected piece
  // Default value -1 indicated no piece is currently selected
  int selectedCol = -1;

  // A List of valid moves for the currently selected piece
  //each elemnt is represented by a List with 2 elements: row and col
  List<List<int>> validMoves = [];

  // A List of white pieces that have been taken by the black player
  List<ChessPiece> whitePiecesTaken = [];

  // A List of black pieces that have been taken by the black player
  List<ChessPiece> blackPiecesTaken = [];

  // A boolean to indicate whos turn is it
  bool isWhiteTurn = true;

  //initial position of kings (keep track of this to make it easierlater to see if king is in Chess)
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  bool checkStatus = false;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

// INITILIZE BOARD
  void _initializeBoard() {
// initilize the boards with nulls, meaning no peaces in those positions
    List<List<ChessPiece?>> newBoard =
        List.generate(8, (index) => List.generate(8, (index) => null));

   // random piece in the midle to test
    // newBoard[3][3] =  ChessPiece(
    //     type: ChessPieceType.rook,
    //     isWhite: true,
    //     imagePath: 'assets/images/chess.png');

    // PLace Pawns
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: false,
          imagePath: 'assets/images/pawn.png');
      newBoard[6][i] = ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: true,
          imagePath: 'assets/images/pawn.png');
    }

    // Place rooks
    newBoard[0][0] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: false,
        imagePath: 'assets/images/rook.png');
    newBoard[0][7] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: false,
        imagePath: 'assets/images/rook.png');
    newBoard[7][0] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: true,
        imagePath: 'assets/images/rook.png');
    newBoard[7][7] = ChessPiece(
        type: ChessPieceType.rook,
        isWhite: true,
        imagePath: 'assets/images/rook.png');

    // Place knights
    newBoard[0][1] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: 'assets/images/knightr.png');
    newBoard[0][6] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: 'assets/images/knightl.png');
    newBoard[7][1] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: 'assets/images/knightr.png');
    newBoard[7][6] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: 'assets/images/knightl.png');

    // Place bishops
    newBoard[0][2] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: 'assets/images/bishop.png');
    newBoard[0][5] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: 'assets/images/bishop.png');
    newBoard[7][2] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: 'assets/images/bishop.png');
    newBoard[7][5] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: 'assets/images/bishop.png');

    // Place queens
    newBoard[0][3] = ChessPiece(
        type: ChessPieceType.queen,
        isWhite: false,
        imagePath: 'assets/images/queen.png');
    newBoard[7][3] = ChessPiece(
        type: ChessPieceType.queen,
        isWhite: true,
        imagePath: 'assets/images/queen.png');

    // Place kings
    newBoard[0][4] = ChessPiece(
        type: ChessPieceType.king,
        isWhite: false,
        imagePath: 'assets/images/king.png');
    newBoard[7][4] = ChessPiece(
        type: ChessPieceType.king,
        isWhite: true,
        imagePath: 'assets/images/king.png');

    board = newBoard;
  }

// USER SELECTED  PIECE
  void pieceSelected(int row, int col) {
    setState(() {
      // no piece has been selected yet, this is the first selection
      if (selectedPiece == null && board[row][col] != null) {
        if (board[row][col]!.isWhite == isWhiteTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }
      }

      // there is a piece already selected, but user can select another of their pieces
      else if (board[row][col] != null &&
          board[row][col]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      }

      // if piece is selcted and user tap on a square that is a valid move, move there
      else if (selectedPiece != null &&
          validMoves.any((element) => element[0] == row && element[1] == col)) {
        movePiece(row, col);
      }

      // if a piece is selected calculate its a valid move
      validMoves =
          calculateRealValidMoves(selectedRow, selectedCol, selectedPiece, true);
    });
  }

//CALCULATE RAW VALID MOVES
  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> candidateMove = [];

    if (piece == null) {
      return [];
    }

    //different irections based on their colors
    int direction = piece.isWhite ? -1 : 1;

    switch (piece.type) {
      case ChessPieceType.pawn:
        // Pawn can move forward if the square is not occupied
        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
          candidateMove.add([row + direction, col]);
        }
        //pawns can move 2 square forward if they are at the initial position
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null &&
              board[row + direction][col] == null) {
            candidateMove.add([row + 2 * direction, col]);
          }
        }
        //pawn can kill diagonaly
        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          candidateMove.add([row + direction, col - 1]);
        }
        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          candidateMove.add([row + direction, col + 1]);
        }
        break;
      case ChessPieceType.rook:
        // Horizontal and Vertical directions
        var directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], // left
          [0, 1], // right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMove.add([newRow, newCol]); // kill
              }
              break; // blocked
            }
            candidateMove.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.knight:
        // all eight possible L Shapes the knight can move
        var knightMoves = [
          [-2, -1], // up 2 left 1
          [-2, 1], // up 2 right 1
          [-1, -2], // up 1 left 2
          [-1, 2], // up 1 right 2
          [1, -2], // down 1 left 2
          [1, 2], // down 1 right 2
          [2, -1], // down 2 left 1
          [2, 1], // down 2 right 1
        ];

        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMove.add([newRow, newCol]); // capture
            }
            continue; // blocked
          }
          candidateMove.add([newRow, newCol]);
        }
        break;
      case ChessPieceType.bishop:
        // diagonal directions
        var directions = [
          [-1, -1], // up left
          [-1, 1], // up right
          [1, -1], // down left
          [1, 1], // down right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMove.add([newRow, newCol]); // capture
              }
              break; // block
            }
            candidateMove.add([newRow, newCol]);
            i++;
          }
        }

        break;
      case ChessPieceType.queen:
        // all 8 directions left, right, up, down, and 4 diagonals
        var directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], // left
          [0, 1], // right
          [-1, -1], // up left
          [-1, 1], // up right
          [1, -1], // down left
          [1, 1], // down right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMove.add([newRow, newCol]); //Capture
              }
              break; //blocked
            }
            candidateMove.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.king:
        // all 8 directions
        var directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], // left
          [0, 1], // right
          [-1, -1], // up left
          [-1, 1], // up right
          [1, -1], // down left
          [1, 1], // down right
        ];

        for (var direction in directions) {
          var newRow = row + direction[0];
          var newCol = col + direction[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMove.add([newRow, newCol]); // capture
            }
            continue; // blocked
          }
          candidateMove.add([newRow, newCol]);
        }
      default:
    }
    return candidateMove;
  }

//CALCULATE REAL VALID MOVES
List<List<int>> calculateRealValidMoves(int row, int col, ChessPiece? piece, bool checkSimulation) {
List<List<int>> realValidMoves = [];
List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece);

//after generate all candidate moves, filter out any that that would result in a check
if (checkSimulation) {
  for (var move in candidateMoves) {
    int endRow = move[0];
    int endCol = move[1];
    // this will simulate the future move to see if its save 
    if (simulatedMoveIsSafe(piece!, row, col, endRow, endCol)) {
      realValidMoves.add(move);
    }
  }
} else {
  realValidMoves = candidateMoves;
}
return realValidMoves;
}

// MOVE PIECE
  void movePiece(int newRow, int newCol) {
// if the new spot has an enemy Piece
    if (board[newRow][newCol] != null) {
      //add the captured piece to the appropriate list
      var capturedPiece = board[newRow][newCol];
      if (capturedPiece!.isWhite) {
        whitePiecesTaken.add(capturedPiece);
      } else {
        blackPiecesTaken.add(capturedPiece);
      }
    }

    // Ckeck if the piece been moved in a King 
    if (selectedPiece!.type == ChessPieceType.king) {
      // update the appropriate king pos
      if (selectedPiece!.isWhite) {
        whiteKingPosition = [newRow, newCol];
      } else {
        blackKingPosition = [newRow, newCol];
      }
    }



// Move the Piece and clear the new spot
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    //see if any Kingsd are under attack
    if (isKingInCheck(!isWhiteTurn)) {
      checkStatus = true;
    } else {
      checkStatus = false;
    }

// Clear selection
    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

  //check if it´s checkmate 
  if (isCkeckMate(!isWhiteTurn)) {
    showDialog(context: context, builder: (context) =>  AlertDialog(title: const Text("CHECK MATE!"),
    actions: [
      // Play again Button
      TextButton(onPressed: resetGame, child: const Text("Play again!"),
      )
    ],));
  }

    // Change turns
    isWhiteTurn = !isWhiteTurn;
  }

  // IS KING IN CHECK
  bool isKingInCheck(bool isWhiteKing) {
    // get the position of the king
    List<int> kingPosition =
        isWhiteKing ? whiteKingPosition : blackKingPosition;

    // check if any enemy piece can attack the King
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        // skip empty squares and pieces of the same color as the king
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMove =
            calculateRealValidMoves(i, j, board[i][j], false);

        // check if the king´s positioning is in this pieces`s valid move
        if (pieceValidMove.any((move) =>
            move[0] == kingPosition[0] && move[1] == kingPosition[1])) {
          return true;
        }
      }
    }

    return false;
  }

  // SIMULATE A FUTURE MOVE TO SEE IF IT´S SAVE (DOESNT PUT YOURE OWN KING UNDER ATTACK) 
  bool simulatedMoveIsSafe(ChessPiece piece, int startRow, int startCol, int endRow, int endCol){
      // save the current oard state 
      ChessPiece? originalDestinationPiece = board[endRow][endCol];

      // if the piece is the king, save its current position and update to the new one 
      List<int>? originalKingPosition;
      if (piece.type == ChessPieceType.king) {
        originalKingPosition = piece.isWhite ? whiteKingPosition : blackKingPosition;

        // update the king position
        if (piece.isWhite) {
          whiteKingPosition = [endRow, endCol];
        } else {
          blackKingPosition = [endRow, endCol];
        }
      }

      // simulate that move 
      board[endRow][endCol] = piece;
      board[startRow][startCol] = null;
      

      // check if youre own king is under attack 
      bool kingInCheck = isKingInCheck(piece.isWhite);

      // restore board to original state
      board[startRow][startCol] = piece;
      board[endRow][endCol] = originalDestinationPiece;

      // if the piece was the king, restore original posotion
      if (piece.type == ChessPieceType.king) {
        if (piece.isWhite) {
          whiteKingPosition = originalKingPosition!;
        } else {
          blackKingPosition = originalKingPosition!;
        }
      }
// if king is in check = true its, its not a save move safe move = false 
      return !kingInCheck;
  }

  // IS IT CHECK MADE 
  bool isCkeckMate(bool isWhiteKing) {
    // if the king is not n chek, then ts´s not checkmate
    if (!isKingInCheck(isWhiteKing)) {
      return false;
    }
    // if there if there is a least on legal ove for any of the player´s pieces, then it´s not checkmate
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        // skip empty squares and pieces of the other color 
        if (board[i][j] == null || board[i][j]!.isWhite != isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMove = calculateRealValidMoves(i, j, board[i][j], true);

        // if this piece has any valid moves, then it´s not checkate
         if (pieceValidMove.isNotEmpty) {
          return false;
         } 
      }
    }

    // if no one of the above conditioning ere met, zhen there are no legal moves left to make 
    // its checkmate 
    return true;
  }

  //RESET THE NEW GAME 
  void resetGame() {
    Navigator.pop(context);
    _initializeBoard();
    checkStatus = false;
    whitePiecesTaken.clear();
    blackPiecesTaken.clear();
    whiteKingPosition = [7, 4];
    blackKingPosition = [0, 4];
    isWhiteTurn = true;
    setState(() {
      
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryBackgroundColor2,
      body: Column(
        children: [
          //WHITE PIECES TAKEN
          Expanded(
            child: GridView.builder(
              itemCount: whitePiecesTaken.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8),
              itemBuilder: (context, index) => DeadPiece(
                imagePath: whitePiecesTaken[index].imagePath,
                isWhite: true,
              ),
            ),
          ),

          // GAME STATUS
          Text(
            checkStatus ? "Ckeck" : ""
          ),

          //CHESS BOARD
          Expanded(
            flex: 3,
            child: GridView.builder(
              itemCount: 8 * 8,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8),
              itemBuilder: (context, index) {
                // get the Row and Col position of this Square
                int row = index ~/ 8;
                int col = index % 8;

                // Check if this Square is selected
                bool isSelected = selectedRow == row && selectedCol == col;

                // Ckeck if this square is a valid move
                bool isValidMove = false;
                for (var position in validMoves) {
                  // Compare row and col
                  if (position[0] == row && position[1] == col) {
                    isValidMove = true;
                  }
                }

                return Square(
                  isWhite: isWhite(index),
                  piece: board[row][col],
                  isSelected: isSelected,
                  isValidMove: isValidMove,
                  onTap: () => pieceSelected(row, col),
                );
              },
            ),
          ), //BLACK PIECES TAKEN
          Expanded(
            child: GridView.builder(
              itemCount: blackPiecesTaken.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8),
              itemBuilder: (context, index) => DeadPiece(
                imagePath: blackPiecesTaken[index].imagePath,
                isWhite: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
