import 'package:alippepro_v1/providers/room_data_provider.dart';
import 'package:alippepro_v1/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';

class GameMethods {
  void checkWinner(BuildContext context, Socket socketClent) {
    RoomDataProvider roomDataProvider =
        Provider.of<RoomDataProvider>(context, listen: false);

    String winner = '';

    if (winner != '') {
      if (roomDataProvider.player1.playerType == winner) {
        showGameDialog(context, '${roomDataProvider.player1.nickname} won!');
        socketClent.emit('winner', {
          'winnerSocketId': roomDataProvider.player1.socketID,
          'roomId': roomDataProvider.roomData['_id'],
        });
      } else {
        showGameDialog(context, '${roomDataProvider.player2.nickname} won!');
        socketClent.emit('winner', {
          'winnerSocketId': roomDataProvider.player2.socketID,
          'roomId': roomDataProvider.roomData['_id'],
        });
      }
    }
  }

  void clearBoard(BuildContext context) {
    RoomDataProvider roomDataProvider =
        Provider.of<RoomDataProvider>(context, listen: false);

    // for (int i = 0; i < roomDataProvider.displayElements.length; i++) {
    //   roomDataProvider.updateDisplayElements(i, '');
    // }
    roomDataProvider.setFilledBoxesTo0();
  }
}