import 'dart:convert';

import 'package:buscador_gifs/pages/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search = '';
  int _offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;

    if (_search.isEmpty) {
      response = await http.get(Uri.parse(
          "https://api.giphy.com/v1/gifs/trending?api_key=5rBIZ9GKvOkpL9Ae6rQN4QLWFtuYf9QK&limit=19&offset=25&rating=g&bundle=messaging_non_clips"));
    } else {
      response = await http.get(Uri.parse(
          "https://api.giphy.com/v1/gifs/search?api_key=5rBIZ9GKvOkpL9Ae6rQN4QLWFtuYf9QK&q=$_search&limit=19&offset=$_offset&rating=g&lang=en&bundle=messaging_non_clips"));
    }
    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
    _getGifs().then((map) {
      print(map);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            'https://developers.giphy.com/branch/master/static/header-logo-0fec0225d189bc0eae27dac3e3770582.gif'),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _search = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Pesquise aqui!',
              labelStyle: const TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: Colors.white),
              ),
            ),
            style: const TextStyle(color: Colors.white, fontSize: 18.0),
            textAlign: TextAlign.center,
            onSubmitted: (text) {
              setState(() {
                _search = text;
                _offset = 0;
              });
            },
          ),
        ),
        Expanded(
          child: FutureBuilder(
            future: _getGifs(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return Container(
                    width: 200.0,
                    height: 200.0,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 5.0,
                    ),
                  );
                default:
                  if (snapshot.hasError) {
                    return Container();
                  } else {
                    return _createGifTable(context, snapshot);
                  }
              }
            },
          ),
        ),
      ]),
    );
  }

  int _getCount(List data) {
    if (_search == null || _search.isEmpty) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: EdgeInsets.all(10.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      ),
      itemCount: _getCount(snapshot.data['data']),
      itemBuilder: (context, index) {
        if (_search == null || index < snapshot.data['data'].length) {
          return GestureDetector(
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data['data'][index]['images']['fixed_height']
                  ['url'],
              height: 300.0,
              fit: BoxFit.cover,
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          GifPage(snapshot.data['data'][index])));
            },
            onLongPress: () {
              Share.share(
                  snapshot.data['data'][index]['images']['fixed_height']);
            },
          );
        } else {
          return Container(
              child: GestureDetector(
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 70.0,
                      ),
                      Text(
                        'Carrregar mais...',
                        style: TextStyle(color: Colors.white, fontSize: 22.0),
                      )
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      _offset += 19;
                    });
                  }));
        }
      },
    );
  }
}
