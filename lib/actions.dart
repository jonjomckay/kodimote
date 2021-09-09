import 'package:flutter/material.dart';
import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:kodimote/main.dart';

class PlayerActions extends StatelessWidget {
  final Peer client;
  final Stream<List<PlayerItem>> isPlaying;

  const PlayerActions({Key? key, required this.client, required this.isPlaying}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Container(
        alignment: Alignment.center,
        margin: EdgeInsets.all(16),
        child: StreamBuilder<List<PlayerItem>>(
          stream: this.isPlaying,
          builder: (context, snapshot) {
            var playerItems = snapshot.data;
            if (playerItems == null) {
              return Center(child: CircularProgressIndicator());
            }

            var isPlaying = playerItems.isNotEmpty;

            return GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              children: [
                Container(
                  child: RpcIconButton(client: client, method: '', icon: Icons.fullscreen),
                ),
                Container(
                  child: RpcIconButton(client: client, method: 'Input.Info', icon: Icons.info),
                ),
                Container(
                  child: TextButton(
                    child: Icon(Icons.keyboard),
                    style: TextButton.styleFrom(backgroundColor: theme.buttonColor),
                    onPressed: () async {
                      // TODO: Show text input dialog
                      // await client.sendRequest(method);
                    },
                  ),
                ),
                Container(
                  // child: RpcIconButton(client: client, method: 'Input.ContextMenu', icon: Icons.expand_less),
                  child: isPlaying
                    ? RpcIconButton(client: client, method: 'Input.ShowPlayerProcessInfo', icon: Icons.format_list_bulleted)
                    : RpcIconButton(client: client, method: 'Input.ContextMenu', icon: Icons.menu_open),
                ),
              ],
            );
          },
        ));
  }
}

class RpcIconButton extends StatelessWidget {
  final Peer client;
  final String method;
  final IconData icon;

  const RpcIconButton({Key? key, required this.client, required this.method, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return TextButton(
      child: Icon(icon),
      style: TextButton.styleFrom(backgroundColor: theme.buttonColor),
      onPressed: () async {
        await client.sendRequest(method);
      },
    );
  }
}
