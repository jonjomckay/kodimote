import 'package:flutter/material.dart';
import 'package:json_rpc_2/json_rpc_2.dart';

class PlayerControls extends StatelessWidget {
  final Peer client;

  const PlayerControls({Key? key, required this.client}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Container(
        alignment: Alignment.center,
        margin: EdgeInsets.all(16),
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          children: [
            Container(),
            Container(
              child: TextButton(
                child: Icon(Icons.expand_less),
                style: TextButton.styleFrom(backgroundColor: theme.buttonColor),
                onPressed: () async {
                  await client.sendRequest('Input.Up');
                },
              ),
            ),
            Container(),
            Container(
              child: TextButton(
                child: Icon(Icons.chevron_left),
                style: TextButton.styleFrom(backgroundColor: theme.buttonColor),
                onPressed: () async {
                  await client.sendRequest('Input.Left');
                },
              ),
            ),
            Container(
              child: TextButton(
                child: Icon(Icons.radio_button_checked),
                style: TextButton.styleFrom(backgroundColor: theme.buttonColor),
                onPressed: () async {
                  await client.sendRequest('Input.Select');
                },
              ),
            ),
            Container(
              child: TextButton(
                child: Icon(Icons.chevron_right),
                style: TextButton.styleFrom(backgroundColor: theme.buttonColor),
                onPressed: () async {
                  await client.sendRequest('Input.Right');
                },
              ),
            ),
            Container(
              child: TextButton(
                child: Icon(Icons.arrow_back),
                style: TextButton.styleFrom(backgroundColor: theme.buttonColor),
                onPressed: () async {
                  await client.sendRequest('Input.Back');
                },
              ),
            ),
            Container(
              child: TextButton(
                child: Icon(Icons.expand_more),
                style: TextButton.styleFrom(backgroundColor: theme.buttonColor),
                onPressed: () async {
                  await client.sendRequest('Input.Down');
                },
              ),
            ),
            Container()
          ],
        ));
  }
}
