import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///Funcion Principal////
void main() {
  runApp(MyApp());
}
////Clase con el nombre MyApp que es un Widget///
class MyApp extends StatelessWidget {
  const MyApp({super.key});

////Lo que contiene el Widget
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(////Notificador de cambios
      create: (context) => MyAppState(),///Un estado para toda la aplicacion
      child: MaterialApp(///Lo que contiene dentro de la app
        title: 'Namer App',//NOMBRE
        debugShowCheckedModeBanner: false,
        theme: ThemeData(///TEMA
          useMaterial3: true,////Para que nuestros botones se vena de cierta forma
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {///Estado de la aplicacion---Notificador de cambios
  var current = WordPair.random();//Para que nos genere una palabra random

  void getNext() {/////garantiza que se notifique a todo elemento que esté mirando a MyAppState.
    current = WordPair.random();
    notifyListeners();
  }
  var favorites = <WordPair>[];

  void toggleFavorite() {////Para poder marcar como favoritos las palabras generadas
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {  @override//Clase MyHomePage
  State<MyHomePage> createState() => _MyHomePageState();//Estado para la clase MyHomePage
}

class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0;//Seleccionar un destino -- otro widget

  @override
  Widget build(BuildContext context) {/////Cada cambio sera actualizado

  Widget page;
  switch (selectedIndex) {///Seleccionar un destino
    case 0:
      page = GeneratorPage();
    break;
  case 1:
      page = FavoritesPage();
    break;
  default:
    throw UnimplementedError('no widget for $selectedIndex');//un aviso de error
}

    return LayoutBuilder(//Nos permite que el widget se adapte a cualquier espacio
      builder: (context, constraints) {
        return Scaffold(
          body: Row(//Creacion de una fila--pequeña area
            children: [
              SafeArea(//elementos secundarios no se muestren oscurecidos
                child: NavigationRail(//evitar que los botones de navegación se vean oscurecidos
                  extended: constraints.maxWidth >= 600,//app responde a su entorno,tamaño de pantalla,la orientacion
                  destinations: [
                    NavigationRailDestination(///Para que los iconos ocupen un espacio como lo requieran
                      icon: Icon(Icons.home),/////Icono home
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),////Icono Favoritos
                      label: Text('Favorites'),
                    ),
                  ],
                  selectedIndex: selectedIndex,//seleccionar el destino de los iconos
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(///Divide el espacio entre los dos areas
                child: Container(///Crea otra area--contenedor
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,///Lo que va dentro del area-contenedor
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class GeneratorPage extends StatelessWidget {///Clase
  @override
  Widget build(BuildContext context) {//Cada cambio sera actualizado
    var appState = context.watch<MyAppState>();//realiza el seguimiento de la app usando el método watch
    var pair = appState.current;

    IconData icon;//Agregar un icono
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;//Si es favorito es un icono
    } else {
      icon = Icons.favorite_border;//Si no es favorito es otro icono
    }

    return Center(//El widget este centrado
      child: Column(//Creacion de columna
        mainAxisAlignment: MainAxisAlignment.center,//Centrar
        children: [
          BigCard(pair: pair),//Extraer un Widget--Card
          SizedBox(height: 10),//Espacio entre la Card y el boton
          Row(
            mainAxisSize: MainAxisSize.min,//Alinear los botones
            children: [
              ElevatedButton.icon(//Boton con el icono favotos
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(//Boton de Next
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),//Genera una nueva palabra
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {///Extraimos el Widget
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);//Solicita el tema actual de la app--para la tarjeta
    final style = theme.textTheme.displayMedium!.copyWith(///Estilo del texto de la tarjeta
      color: theme.colorScheme.onPrimary,
    );



    return Card(//Para  que el texto y el boton esten en una tarjeta
    color: theme.colorScheme.primary,//Color del tema actual
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(//Estilo del texto de la tarjeta
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",///Para que los lectores pronuncien bien la palabras
          )
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {//clase FavoritesPage
  @override
  Widget build(BuildContext context) {//Cada cambio sera actualizado
    var appState = context.watch<MyAppState>();//realiza el seguimiento de la app usando el método watch

    if (appState.favorites.isEmpty) {//Para saber si hay favoritos
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(//Una lista
      children: [
        Padding(
          padding: const EdgeInsets.all(20),///La lista de los favoritos que agregamos
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}

