import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _pesquisa;
  int _offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;
    if (_pesquisa == null)
      response = await http.get(
          "https://api.giphy.com/v1/gifs/trending?api_key=4xNlsioZ9LPZmy3pLLDDHJPcSA3zYkkh&limit=26&rating=g");
    else
      response = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=4xNlsioZ9LPZmy3pLLDDHJPcSA3zYkkh&q=$_pesquisa&limit=20&offset=$_offset&rating=g&lang=pt");
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
        //to usando o link usando um gif na bar, pegando imagem da net
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
        centerTitle: true,
      ),


      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
            //botei uma borda em tudo para melhorar
            padding: EdgeInsets.all(15.0),
            child: TextField(
              decoration: InputDecoration(
                  labelText: "Pesquise o gif",
                  labelStyle: TextStyle(color: Colors.blue),
                  border: OutlineInputBorder()
              ),
              style: TextStyle(color: Colors.white, fontSize: 18.0),
              textAlign: TextAlign.center,
              onSubmitted: (text) {
                setState(() {
                  _pesquisa = text;
                });
              },
            ),
          ),

          Expanded(
            child: FutureBuilder(
                future: _getGifs(),
                builder: (context, snapshot) {
                  //verificar conexao
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Container(
                        width: 200.0,
                        height: 200.0,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue),
                          strokeWidth: 5.0,
                        ),
                      );
                    default:
                      if (snapshot.hasError)
                        return Container();
                      else
                        return _criarTabelaDeGif(context, snapshot);
                  //preferi criar a tabela fora e so chamar, codigo fica limpo
                  }
                }
            ),
          ),
        ],
      ),
    );
  }

  //função
  int _getDados(List data) {
    if (_pesquisa == null) {
      return data.length;
    }
    else {
       return data.length + 1;
    }
  }

  //criar tabela de gif e so chamar aq em cima
  Widget _criarTabelaDeGif(BuildContext context, AsyncSnapshot snapshot) {
    //mostrar o formato de grade
    return GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0
        ),

        itemCount: _getDados(snapshot.data["data"]),
        itemBuilder: (context, index) {
          //pra poder clicar na imagem eu uso o gesturedector
          if (_pesquisa == null || index < snapshot.data["data"].length)
            return GestureDetector(
              child: Image.network(snapshot
                  .data["data"][index]["images"]["fixed_height"]["url"],
                height: 300.0,
                fit: BoxFit.cover,
              ),
            );
          else
            return Container(
              child: GestureDetector(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.add, color: Colors.blue, size: 70.0,),
                    Text("Mais Gifs",
                      style: TextStyle(color: Colors.blue, fontSize: 22.0),)
                  ],
                ),
                onTap: (){
                  setState(() {
                    _offset +=20;
                  });
                },
              ),
            );
        }
    );
  }
}

