import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:peliculas/src/models/pelicula_model.dart';

import '../models/pelicula_model.dart';

class PeliculasProvider {
  String _apikey = "634eb55e349113cdc96234cae7b58f19";
  String _url = "api.themoviedb.org";
  String _lenguage = 'es-ES';

  int _popularesPage = 1;

  List<Pelicula> _populares = new List();

  final _popularesStream = StreamController<List<Pelicula>>.broadcast();

  Function(List<Pelicula>) get popularesSink => _popularesStream.sink.add;
  Stream<List<Pelicula>> get popularesStream => _popularesStream.stream;

  void disposeStreams() {
    _popularesStream.close();
  }

  Future<List<Pelicula>> _procesarRespuesta(Uri uri) async {
    final respuesta = await http.get(uri);

    final decodedData = json.decode(respuesta.body);
    final peliculas = Peliculas.fromJsonList(decodedData['results']);
    return peliculas.items;
  }

  Future<List<Pelicula>> getEnCines() async {
    final url = Uri.https(_url, '3/movie/now_playing', {
      'api_key': _apikey,
      'language': _lenguage,
    });
    return await _procesarRespuesta(url);
  }

  Future<List<Pelicula>> getPopulares() async {
    _popularesPage++;
    final url = Uri.https(_url, '3/movie/popular', {
      'api_key': _apikey,
      'language': _lenguage,
      'populares': _popularesPage.toString()
    });

    final resp = await _procesarRespuesta(url);
    _populares.addAll(resp);

    popularesSink(_populares);
    return resp;
  }
}
