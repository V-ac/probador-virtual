import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../models/clothing.dart';
import 'dart:convert';

/**
pubspec.yaml
→ instala la dependencia en el proyecto

import
→ permite usarla dentro de este archivo
 */

class ClosetPage extends StatefulWidget {
    const ClosetPage({super.key});

    @override
    State<ClosetPage> createState() => _ClosetPageState();
}

class _ClosetPageState extends State<ClosetPage> {
  // Lista de prendas (por ahora solo nombres, después serán imágenes reales)
    final List<Clothing> _prendas = [
        Clothing(name: 'Playera negra'),
        Clothing(name: 'Pantalón azul'),
        Clothing(name: 'Vestido rojo'),
    ];

    //En Dart, comenzar un nombre con _ significa que es privado para su library.
    final ImagePicker _picker = ImagePicker();

  
    // esta es la que agregue
    Future<void> _agregarPrenda() async { //Future<void> significa algo como: esta función terminará en el futuro y, cuando termine, no devolverá un valor útil.
        //Puedes pensar en async como: dentro de esta función voy a realizar operaciones que pueden tardar.
        /*_picker.pickImage(...) abre la galería
        Pero no sabemos cuánto tardará el usuario.

            Podrían ser:

            2 segundos
            30 segundos
            2 minutos
        
        */
        final XFile? image = await _picker.pickImage(
            source: ImageSource.gallery,
        );
        /**
        await significa:
        espera aquí el resultado de esta operación antes de continuar 
        con las siguientes líneas de esta función.

        _agregarPrenda()
            ↓
        abrir galería
            ↓
            await
            ↓
        usuario elige imagen
            ↓
        obtenemos XFile
            ↓
        continuamos

        XFile es una clase utilizada por image_picker para representar el archivo seleccionado.
        Contiene información como la ruta del archivo.
        Por ejemplo:
        image.path

        podría devolver algo parecido a:

        /data/user/0/.../imagen.jpg

        Pero observa que escribimos:

        XFile?

        otra vez aparece nuestro conocido:

        ?

        Eso significa que puede ser:

        XFile

        o:

        null

        ¿Por qué podría ser null?

        Porque el usuario puede abrir la galería y presionar Cancelar.


                */

        if (image == null) {
            return; // si el usuario no seleccionó ninguna imagen, termina la función.
        } // ya se comprobó que no hay nulos

        
        //codigo agregado con lo de las caracteristicas de la prenda
        final String? nombre = await _pedirNombrePrenda();

        if (nombre == null || nombre.trim().isEmpty) {
            return;
        }

        final String rutaLocal = await _guardarImagenLocalmente(image);
        
        setState(() {
            _prendas.add(
            Clothing(
                name: nombre.trim(), //agrega el nombre que le pusimos anteriormente.
                /**
                trim() elimina espacios al principio y al final:

                        "   Vestido azul   "

                        se convierte en:

                        "Vestido azul"

                        Por eso también guardamos:

                        name: nombre.trim(),

                        en lugar de:

                        name: nombre,
                
                 */
                imagePath: rutaLocal,
                ),
            );
        });
        /**
        Imagen incluida dentro de la app
                ↓
        Image.asset()

        Imagen guardada como archivo en el dispositivo
                ↓
        Image.file()
         */
        await _guardarPrendas();
    }

    Future<String?> _pedirNombrePrenda() async {
        //TextEditingController sirve para leer y controlar el contenido de un TextField.
        //final TextEditingController controller = TextEditingController();
        String nombreTemporal = '';
        /**
                En palabras sencillas:

                    TextField
                    ↓
                    el usuario escribe
                    ↓
                    controller
                    ↓
                    controller.text

                    Entonces si escribe:

                    Vestido azul

                    podemos obtenerlo con:

                    controller.text
         */
        final String? nombre = await showDialog<String>(
            //Ya usabas showDialog para eliminar prendas. La diferencia es que ahora esperamos que el diálogo nos devuelva un String.
            /**
            puede devolver:

                    "Vestido azul"

                    o:

                    null

                    si el usuario cancela.
             */
            context: context,
            builder: (ctx) {
            return AlertDialog(
                title: const Text('Nombre de la prenda'),
                content: TextField(
                //controller: controller,
                decoration: const InputDecoration(
                    hintText: 'Ej. Playera negra',
                    ),
                    onChanged: (value) {
                        nombreTemporal = value; //onChanged se ejecuta cada vez que el usuario modifica el texto.
                        /**
                            Por ejemplo, si escribe:

                                    V
                                    Ve
                                    Ves
                                    Vestido

                                    Flutter va llamando a onChanged y nombreTemporal termina conteniendo:

                                    'Vestido'
                        
                         */
                    },
                ),
                actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancelar'),
                ),
                FilledButton(
                    onPressed: () {
                    Navigator.pop(ctx, nombreTemporal); //cierra el diálogo y devuelve ese texto.
                    
                    },
                    child: const Text('Guardar'),
                ),
                ],
            );
            },
        );

        //controller.dispose(); //si creamos un controlador temporal, cuando terminamos de usarlo lo limpiamos. libera los recursos usados por el controlador.

        return nombre;
    }

    Future<void> _guardarPrendas() async {
        final prefs = await SharedPreferences.getInstance(); //obtiene acceso al almacenamiento local de la app.

        final List<Map<String, dynamic>> prendasMap =
            _prendas.map((prenda) => prenda.toMap()).toList(); //convierte cada Clothing en un Map.
            // La parte:  .map(...) significa: recorre cada elemento de la lista y transfórmalo.
            // (prenda) => prenda.toMap()  significa: por cada prenda, devuelve su versión toMap().
            /**
            Si teníamos:

                Clothing
                Clothing
                Clothing

                terminamos con:

                Map
                Map
                Map
            
             */

        final String prendasJson = jsonEncode(prendasMap); //convierte toda esa estructura en un String JSON.

        await prefs.setString('prendas', prendasJson);
        /**
        guarda ese texto con una clave llamada:

            prendas

            Puedes imaginar SharedPreferences como un pequeño cajón de pares:

            clave       valor
            -----------------------------
            "prendas" → "[{...},{...}]"
        
         */
    }

    Future<void> _cargarPrendas() async {
        final prefs = await SharedPreferences.getInstance();

        final String? prendasJson = prefs.getString('prendas'); //busca exactamente la misma clave que usamos al guardar: prendas
        //Si nunca hemos guardado nada:  prendasJson == null  y hacemos:  return;
        if (prendasJson == null) {
            return;
        }

        final List<dynamic> prendasDecodificadas = jsonDecode(prendasJson);

        final List<Clothing> prendasCargadas = prendasDecodificadas
            .map((map) => Clothing.fromMap(map))
            .toList();

        setState(() {
            _prendas.clear();
            _prendas.addAll(prendasCargadas);
        });
    }


    Future<void> _eliminarPrenda(int index) async {
        setState(() {
            _prendas.removeAt(index);
        });

        await _guardarPrendas();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
            title: const Text('Mi Closet 👗',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.pinkAccent,
        ),
        // Botón flotante para agregar ropa
        floatingActionButton: FloatingActionButton.extended(
            onPressed: _agregarPrenda,
            backgroundColor: Colors.pinkAccent,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Agregar Prenda',
                style: TextStyle(color: Colors.white)),
        ),
        body: _prendas.isEmpty
            ? const Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Icon(Icons.checkroom, size: 80, color: Colors.grey),
                    SizedBox(height: 10),
                    Text('Tu closet está vacío',
                        style: TextStyle(color: Colors.grey, fontSize: 18)),
                    Text('Agrega tu primera prenda 👆',
                        style: TextStyle(color: Colors.grey)),
                    ],
                ),
                )
            : Padding(
                padding: const EdgeInsets.all(12.0),
                child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,    // 2 columnas
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75, // Proporción de cada tarjeta
                    ),
                    itemCount: _prendas.length,
                    itemBuilder: (context, index) {
                    return _buildPrendaCard(index);
                    },
                ),
                ),
        );
    }

    Widget _buildPrendaCard(int index) {
        return Container(
        decoration: BoxDecoration(
            color: Colors.white, // Fondo blanco para ver bien la ropa
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
            )
            ],
        ),
        child: Stack(
            children: [
            // Área de la imagen (por ahora un ícono)
            Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    //const Icon(Icons.checkroom, size: 60, color: Colors.pinkAccent),
                    _prendas[index].imagePath == null
                        ? const Icon(
                            Icons.checkroom,
                            size: 60,
                            color: Colors.pinkAccent,
                        )
                        :Image.file(
                            File(_prendas[index].imagePath!), //estamos tomando un String como: /data/user/0/.../imagen.jpg
                            height: 120,
                            fit: BoxFit.contain,
                            ),
                            /**
                            Image.asset(...)
                            → busca una imagen empaquetada dentro de la app

                            Image.file(...)
                            → busca una imagen usando una ruta del sistema de archivos
                             */
                        //),
                    const SizedBox(height: 8),
                    Text(
                    _prendas[index].name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 13),
                    textAlign: TextAlign.center,
                    ),
                ],
                ),
            ),
            // Botón de eliminar (esquina superior derecha)
            Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                onTap: () => _mostrarDialogoEliminar(index),
                child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
                ),
            ),
            ],
        ),
        );
    }

    // Diálogo de confirmación antes de eliminar
    void _mostrarDialogoEliminar(int index) {
        showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
            title: const Text('¿Eliminar prenda?'),
            content: Text('¿Segura que quieres eliminar "${_prendas[index].name}"?'),
            actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
            ),
            FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                _eliminarPrenda(index);
                Navigator.pop(ctx);
                },
                child: const Text('Eliminar'),
            ),
            ],
        ),
        );
    }

    @override
    void initState() { //se ejecuta una vez cuando ese estado se crea.
        super.initState();
        _cargarPrendas();
    }

    Future<String> _guardarImagenLocalmente(XFile image) async {
        //¿Dónde puede esta app guardar archivos propios?
        final Directory directory = await getApplicationDocumentsDirectory();
        // Devuelve un objeto: directory. que representa una carpeta. -<directory.path contiene la ruta real de esa carpeta.
        final String nombreArchivo =
            '${DateTime.now().millisecondsSinceEpoch}.jpg'; //obtiene un número basado en el momento actual.La razón es evitar nombres repetidos

        final String nuevaRuta = '${directory.path}/$nombreArchivo';

        final File imagenGuardada = await File(image.path).copy(nuevaRuta);
        //File(image.path) -> representa la imagen que seleccionaste.
        //.copy(nuevaRuta) -> crea una copia dentro de la carpeta de nuestra aplicación.
        print('Imagen guardada en: ${imagenGuardada.path}');
        print('¿Existe?: ${await imagenGuardada.exists()}');
        return imagenGuardada.path; //Nuestra función no devuelve la imagen. Devuelve un: String -> con la ubicación donde quedó guardada.
    }

}