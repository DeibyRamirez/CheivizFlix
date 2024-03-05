// ignore_for_file: use_key_in_widget_constructors, file_names, prefer_final_fields
// Paquetes requeridos...
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'Informacion.dart';

//Defino Clase Principal... con statefulwidget
class Principal extends StatefulWidget {
  const Principal({Key? key});

  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  List<Informacion> peliculas = []; // Guarda informacion sobre las peliculas
  List<Informacion> peliculasFiltradas = []; //Guarda las peliculas filtradas
  //Creo el controlador del buscador
  TextEditingController _controller = TextEditingController();
  int _page = 1; //Pagina actual
  int _totalPages = 1; //Numero total de paginas disponibles

//Llamando a la funcion de fetchMovies al iniciar el estado...
  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

//Funcion asincronica para hacer los llamados a las peliculas desde la API...
  Future<void> fetchMovies() async {
    final response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/movie/popular?api_key=ac074b1e293b61ca586f8e5523abdef3&page=$_page'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      _totalPages = data['total_pages'];
      setState(() {
        for (final result in results) {
          final List<dynamic>? genres = result['genres'];
          print('Géneros de la película: $genres');
          // Imformacion pedida de cada pelicula...
          peliculas.add(Informacion(
            titulo: result['title'],
            fechaLanzamiento: result['release_date'],
            genero: obtenerGeneros(result['genres']),
            descripcion: result['overview'],
            imagenUrl:
                'https://image.tmdb.org/t/p/w200${result['poster_path']}',
          ));
        }
        peliculasFiltradas.addAll(
            peliculas); //Agregando todas las peliculas a la lista de peliculasFiltradas...
      });
    } else {
      throw Exception(
          'Fallo al cargar las peliculas'); //Ceando una exepcion, si algo falla
    }
  }

// Funcion utilizada para obtener el nombre de los generos de las peliculas...
  String obtenerGeneros(List<dynamic>? genres) {
    List<String> generosNombres = [];
    if (genres != null && genres.isNotEmpty) {
      for (var genre in genres) {
        if (genre != null && genre['name'] != null) {
          generosNombres.add(genre['name']);
        }
      }
    }
    print('Géneros obtenidos: $generosNombres');
    return generosNombres.join(', ');
  }

// Funcion para buscar las peliculas desde el TextFiel
  void buscarPeliculas(String query) {
    setState(() {
      peliculasFiltradas
          .clear(); //Borrando las peliculas filtradas anteriormente...
      peliculasFiltradas.addAll(peliculas.where((pelicula) =>
          pelicula.titulo.toLowerCase().contains(query.toLowerCase())));
    });
  }

//Funcion para cargar mas peliculas cuando se alcanza el final de la lista...
  void cargarMasPeliculas() {
    if (_page < _totalPages) {
      _page++;
      fetchMovies(); //Cargar mas peliculas...
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: TextField(
          controller: _controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintStyle: const TextStyle(color: Colors.white),
            hintText: 'Buscar películas...',
            suffixIcon: const Icon(Icons.search, color: Colors.white),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onChanged: (value) {
            buscarPeliculas(
                value); //Llama a la funcion de busqueda cuando el txto cambia...
          },
          onSubmitted: (value) {
            buscarPeliculas(
                value); //Llama a la funcion de busqueda cuando se envia la peticion...
          },
        ),
      ),
      backgroundColor: Colors.blue,
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                    cargarMasPeliculas(); //CArg mas peliculas cuando se llega al final de la lista...
                  }
                  return true;
                },
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: peliculasFiltradas.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        SizedBox(
                          width: 200,
                          height: 390,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.black),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => peliculasFiltradas[
                                      index], //Navega a la pagina de detalles de pelicula...
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  peliculasFiltradas[index]
                                      .titulo, //Muestra el titulo de la pelicula...
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Image.network(peliculasFiltradas[index]
                                    .imagenUrl), //Muestra el poster de la pelicula
                                const SizedBox(height: 5),
                                Text(
                                  peliculasFiltradas[index]
                                      .fechaLanzamiento, //Muestra la de fecha de lanzamiento de la pelicula
                                  style: const TextStyle(fontSize: 10),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  peliculasFiltradas[index]
                                      .genero, //Muestra los generos de la pelicula
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10), // Espacio entre elementos
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
