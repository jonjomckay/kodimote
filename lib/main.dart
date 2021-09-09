import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:json_rpc_2/json_rpc_2.dart';
import 'package:jsonrpc2/jsonrpc2.dart';
import 'package:kodimote/actions.dart';
import 'package:kodimote/controls.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class PlayerItem {
  final int player;
  final dynamic data;
  final dynamic info;

  PlayerItem(this.player, this.data, this.info);
}

class _MyHomePageState extends State<MyHomePage> {
  late WebSocketChannel _socket;
  late Peer _client;

  late Stream<List<PlayerItem>> _isPlayingStream;

  @override
  void initState() {
    super.initState();

    _socket = WebSocketChannel.connect(Uri.parse('ws://192.168.0.250:9090'));

    _client = Peer(_socket.cast<String>(), onUnhandledError: (e, stackTrace) {
      log('Unhandled error', error: e, stackTrace: stackTrace);
    });
    _client.listen();
    // _client.done.then((value) {
    //   log('Reconnecting');
    //
    //   setState(() {
    //     _socket = WebSocketChannel.connect(Uri.parse('ws://192.168.0.250:9090'));
    //   });
    // });
    
    // _client.registerMethod('Player.OnPropertyChanged', (a) {
    //   int i = 0;
    // });
    //
    // _client.registerMethod('Player.OnPause', (a) {
    //   int i = 0;
    // });

    _client.withBatch(() async {
      var a = await _client.sendRequest('JSONRPC.Ping');
      log(a);
      var b = await _client.sendRequest('JSONRPC.Ping');
      log(b);
      var c = await _client.sendRequest('JSONRPC.Ping');
      log(c);

      int i = 0;
    });
    
    _isPlayingStream = Stream.periodic(Duration(seconds: 5), (_) async {
      // var result = await _client.sendRequest('Player.GetActivePlayers');
      // if (result == null || result.isEmpty) {
        return List<PlayerItem>.empty();
      // }
      //
      // log('1');
      //
      // List<PlayerItem> playerItems = [];
      //
      // for (var e in List.from(result)) {
      //   log('on ${e['playerid']}');
      //   var item = await _client.sendRequest('Player.GetItem', {
      //     'properties': ["title", "album", "artist", "season", "episode", "duration", "showtitle", "tvshowid", "thumbnail", "file", "fanart", "streamdetails"],
      //     'playerid': e['playerid']
      //   });
      //
      //   log('done');
      //
      //   var info = await _client.sendRequest('Player.GetProperties', {
      //     'properties': ['percentage', 'time', 'totaltime'],
      //     'playerid': e['playerid']
      //   });
      //
      //   playerItems.add(PlayerItem(e['playerid'], item['item'], info));
      // }
      //
      // log('2');
      //
      // return playerItems;
    }).handleError((e, stackTrace) {
      log('Something went wrong handling the stream', error: e, stackTrace: stackTrace);
    }).asyncMap((event) async => await event).asBroadcastStream();
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          PlayerActions(client: _client, isPlaying: _isPlayingStream),
          PlayerControls(client: _client),
        ],
      ),
      bottomSheet: StreamBuilder<List<PlayerItem>>(
        stream: _isPlayingStream,
        builder: (context, snapshot) {
          var isPlaying = snapshot.data;
          if (isPlaying == null || isPlaying.isEmpty) {
            return Container(height: 0);
          }

          var height = 48.0;

          return Container(
            height: height * isPlaying.length,
            child: Column(
              children: [
                ...isPlaying.map((playingItem) => Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  height: height,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.deepOrange,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${playingItem.data['label']}'),
                      Row(
                        children: [
                          IconButton(icon: Icon(Icons.pause), onPressed: () async {
                            await _client.sendRequest('Player.PlayPause', {
                              'playerid': playingItem.player
                            });
                          }),
                          IconButton(icon: Icon(Icons.stop), onPressed: () async {
                            await _client.sendRequest('Player.Stop', {
                              'playerid': playingItem.player
                            });
                          })
                        ],
                      )
                    ],
                  ),
                ))
              ],
            ),
          );
        },
      ),
    );
  }
}

class KodiImage extends StatefulWidget {
  final Client client;
  final String imageUri;

  const KodiImage({Key? key, required this.client, required this.imageUri}) : super(key: key);

  @override
  _KodiImageState createState() => _KodiImageState();
}

class _KodiImageState extends State<KodiImage> {
  String? realUri;

  @override
  void initState() {
    super.initState();
    
    widget.client.sendRequest('Files.PrepareDownload', {
      'path': widget.imageUri
    })
      .then((value) {
        setState(() {
          // realUri = value[]
        });
      })
    .catchError((e, stackTrace) {
      log('Unable to fetch image', error: e, stackTrace: stackTrace);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class MyServerProxy extends ServerProxyBase {
  final WebSocketChannel _channel;

  final Map<int, _Request> _requests = {};

  MyServerProxy(resource, this._channel) : super(resource);

  Future listen() {
    _channel.stream.listen((event) {
      var id = event['id'];
      if (_requests.contains(id))

    });
  }

  @override
  Future<String> transmit(String package) async {
    _channel.sink.add(package);

    var completer = Completer<String>.sync();

    _requests[](_Request(completer));

    return completer.future;
  }


}

class _Request {
  final Completer completer;

  _Request(this.completer);
}