import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/closet_screen.dart';

/* Esta es la enrtada de la aplicación 
main()
   ↓
runApp()
   ↓
ProbadorApp
   ↓
aplicación Flutter
*/
void main() { // "Inicia la aplicación utilizando ProbadorApp".
  runApp(const ProbadorApp()); // "Quiero que ejecutes este widget como raíz de mi aplicación".
}

//Aquí estás creando tu propio widget. ¿Por qué Stateless? Porque ProbadorApp no necesita cambiar su estado durante la ejecución.
class ProbadorApp extends StatelessWidget { // Estoy creando un nuevo tipo de objeto llamado ProbadorApp y Mi widget se comportará como un StatelessWidget.
  const ProbadorApp({super.key});

  @override
  Widget build(BuildContext context) { // Este método lo vas a ver todo el tiempo en Flutter.
  /* build() significa, simplificando:

"Flutter, aquí te digo cómo quiero que se vea este widget". 
Este widget
    ↓
debe mostrar
    ↓
"Hola"

*/
    return MaterialApp( // MaterialApp es uno de los widgets principales de una aplicación Flutter que utiliza Material Design.
      debugShowCheckedModeBanner: false,
      title: 'Probador Virtual',
      /*
      Estás diciendo:

"Mi aplicación se llama Probador Virtual y quiero utilizar este tema visual".
      */
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
        useMaterial3: true,
      ),
      home: const MainScreen(), // "Cuando se abra la aplicación, muestra MainScreen".
      /**
      main()
        ↓
      runApp()
        ↓
      ProbadorApp
        ↓
      MaterialApp
        ↓
      MainScreen */
    );
  }
}

/**
Tu MainScreen es:

class MainScreen extends StatefulWidget {

Aquí ya cambiaste de:

StatelessWidget

a:

StatefulWidget

¿Por qué?

Porque tienes esto:

int _currentIndex = 0;

Ese número representa qué sección está seleccionada.

*/
// ─── PANTALLA PRINCIPAL CON NAVEGACIÓN ───────────────────────────────────────
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // Ese número representa qué sección está seleccionada.

  final List<Widget> _screens = const [
    HomePage(),
    ClosetPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
                /**
                Si:

          _currentIndex = 0

          entonces:

          _screens[0]
                ↓
          HomePage

          Si:

          _currentIndex = 1

          entonces:

          _screens[1]
                ↓
          ClosetPage
       */
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.pinkAccent,
        onTap: (index) => setState(() => _currentIndex = index), /**
                  Cuando presionas:

          🏠 Inicio

          o:

          👗 Mi Closet

          Flutter recibe un index.

          Por ejemplo:

          Inicio
            ↓
          index = 0

          Mi Closet
            ↓
          index = 1

          Entonces haces:

          _currentIndex = index;

          setState() le está diciendo a Flutter:

"Mi estado cambió. Necesito que vuelvas a construir esta parte de la interfaz".

         */
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checkroom),
            label: 'Mi Closet',
          ),
        ],
      ),
    );
  }
}



// ─── PANTALLA DEL CLOSET ──────────────────────────────────────────────────────



/*
De tu código actual ya podemos sacar estos conceptos:

Concepto	En tu código	Para qué sirve
main()	main()	Punto de entrada
runApp()	runApp(...)	Arranca Flutter
Widget	ProbadorApp	Componente de UI
StatelessWidget	ProbadorApp	Widget sin estado mutable
StatefulWidget	MainScreen	Widget con estado
build()	varios	Construye la interfaz
MaterialApp	ProbadorApp	Configuración principal
Scaffold	tus pantallas	Estructura de una pantalla
setState()	navegación/closet	Actualiza estado
List	_prendas	Colección de datos
GridView	Closet	Mostrar elementos en cuadrícula
Navigator	diálogo	Navegación/gestión de rutas
Widget personalizado	_buildPrendaCard()	Reutilizar UI


 */