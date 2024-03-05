// ignore_for_file: file_names, use_key_in_widget_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

class Informacion extends StatefulWidget {
  final String titulo;
  final String fechaLanzamiento;
  final String genero;
  final String descripcion;
  final String imagenUrl;

  const Informacion({
    Key? key,
    required this.titulo,
    required this.fechaLanzamiento,
    required this.genero,
    required this.descripcion,
    required this.imagenUrl,
  });

  @override
  State<Informacion> createState() => _InformacionState();
}

class _InformacionState extends State<Informacion> {
  List<dynamic> peliculas = [];

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    final response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/movie/popular?api_key=ac074b1e293b61ca586f8e5523abdef3'));
    if (response.statusCode == 200) {
      setState(() {
        peliculas = json.decode(response.body)['results'];
      });
    } else {
      throw Exception('Fallo al cargar las peliculas');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          // Fondo de imagen
          Image.network(
            widget.imagenUrl,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
          // Contenedor oscuro para superponer texto
          Container(
            alignment: Alignment.center,
            color: Colors.black
                .withOpacity(0.6), // Opacidad para oscurecer el fondo
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.titulo,
                      style: const TextStyle(fontSize: 25, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.fechaLanzamiento,
                      style: const TextStyle(fontSize: 15, color: Colors.white),
                    ),
                    Text(
                      widget.genero,
                      style: const TextStyle(fontSize: 15, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Descripción:',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.descripcion,
                      style: const TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
