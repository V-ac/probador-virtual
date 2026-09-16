import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TryOnPage extends StatefulWidget {
  const TryOnPage({super.key});

  @override
  State<TryOnPage> createState() => _TryOnPageState();
}

class _TryOnPageState extends State<TryOnPage> {
  String? _baseImagePath;
  String? _categoriaSeleccionada; //para checar que categoria esta utilizada
  String _modoPanel = 'Prendas'; //modo inicial del panel inferior
  bool _prendaEnPrueba = false;
  final ImagePicker _picker = ImagePicker();
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F7),
      appBar: AppBar(
        title: const Text(
          'Probador',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: _baseImagePath == null
                          ? const Text(
                              'Aquí aparecerá tu foto de cuerpo completo',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            )
                          : Image.file(
                              File(_baseImagePath!),
                              fit: BoxFit.contain,
                            ),
                    ),

                    Positioned(
                      left: 12,
                      top: 40,
                      child: Column(
                        children: [
                          _buildCategoryButton(
                            icon: Icons.checkroom,
                            label: 'Superior',
                            selected: _categoriaSeleccionada == 'Superior',
                            onTap: () {
                              setState((){ //cambió algo que afecta la interfaz; vuelve a construir la pantalla.
                                _categoriaSeleccionada = 'Superior';
                              });     
                              print('Categoría Superior seleccionada');
                              // Acción al presionar el botón de categoría "Superior"
                            }
                          ),
                          const SizedBox(height: 10),
                          _buildCategoryButton(
                            icon: Icons.layers_outlined,
                            label: 'Inferior',
                            selected: _categoriaSeleccionada == 'Inferior', 
                            onTap: () {
                              setState((){
                                _categoriaSeleccionada = 'Inferior';
                              });
                              print('Categoría Inferior seleccionada');
                              // Acción al presionar el botón de categoría "Inferior"
                            }
                          ),
                          const SizedBox(height: 10),
                          _buildCategoryButton(
                            icon: Icons.dry_cleaning_outlined,
                            label: 'Vestidos',
                            selected: _categoriaSeleccionada == 'Vestidos',
                            onTap: () {
                              setState((){
                                _categoriaSeleccionada = 'Vestidos';
                              });
                              print('Categoría Vestidos seleccionada');
                              // Acción al presionar el botón de categoría "Vestidos"
                            }
                          ),
                        ],
                      ),
                    ),
                    
                    if(_categoriaSeleccionada != null) //Eso se llama collection if.
                      /**
                      si hay categoría seleccionada
                            → muestra el panel

                            si no hay categoría seleccionada
                            → no lo construye
                      */
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.96),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Encabezado del panel
                              Row(
                                children: [
                                  const Icon(
                                    Icons.auto_awesome,
                                    color: Colors.pinkAccent,
                                  ),
                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: Text(
                                      'Prendas de $_categoriaSeleccionada',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),

                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _categoriaSeleccionada = null;
                                        _modoPanel = 'Prendas';
                                      });
                                    },
                                    icon: const Icon(Icons.close),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              Text(
                                _categoriaSeleccionada == 'Superior'
                                    ? 'Aquí aparecerán blusas, playeras y otras prendas superiores, guapota hermosa.'
                                    : _categoriaSeleccionada == 'Inferior'
                                        ? 'Aquí aparecerán pantalones, faldas y otras prendas inferiores, mi chiquita rica.'
                                        : 'Aquí aparecerán tus vestidos disponibles, mi nenorra preciosa.',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Selector Prendas / Sugerencias
                              Row(
                                children: [
                                  Expanded(
                                    child: FilledButton(
                                      onPressed: () {
                                        setState(() {
                                          _modoPanel = 'Prendas';
                                        });
                                      },
                                      style: FilledButton.styleFrom(
                                        backgroundColor: _modoPanel == 'Prendas'
                                            ? Colors.pinkAccent
                                            : Colors.grey.shade200,
                                        foregroundColor: _modoPanel == 'Prendas'
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                      child: const Text('Prendas'),
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  Expanded(
                                    child: FilledButton(
                                      onPressed: () {
                                        setState(() {
                                          _modoPanel = 'Sugerencias';
                                        });
                                      },
                                      style: FilledButton.styleFrom(
                                        backgroundColor: _modoPanel == 'Sugerencias'
                                            ? Colors.pinkAccent
                                            : Colors.grey.shade200,
                                        foregroundColor: _modoPanel == 'Sugerencias'
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                      child: const Text('Sugerencias'),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              Text(
                                _modoPanel == 'Prendas'
                                    ? 'Prendas disponibles de la categoría seleccionada, mi chiqui beibe.'
                                    : 'Aquí aparecerán sugerencias relacionadas con tu ovni mi amor.',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),

                              const SizedBox(height: 12),

                              FilledButton(
                                onPressed: () {
                                  setState(() {
                                    _prendaEnPrueba = true;
                                    _categoriaSeleccionada = null;
                                    _modoPanel = 'Prendas';
                                  });
                                },
                                child: const Text('Probar prenda de ejemplo'),
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (_prendaEnPrueba)
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 12,
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _prendaEnPrueba = false;
                                  });
                                },
                                child: const Text('Cancelar'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FilledButton(
                                onPressed: () {
                                  setState(() {
                                    _prendaEnPrueba = false;
                                  });
                                },
                                child: const Text('Aceptar'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                  ],
                ),

                

              ),
            ),

            


            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: SizedBox(
                width: double.infinity, //ocupa todo el ancho disponible.
                child: FilledButton.icon(
                  onPressed: _seleccionarFotoBase,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Seleccionar foto base'),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

 Future<void> _seleccionarFotoBase() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) {
      return;
    }

    final String? rutaAnterior = _baseImagePath;

    final String rutaLocal =
        await _guardarFotoBaseLocalmente(image);

    await _guardarRutaFotoBase(rutaLocal);

    setState(() {
      _baseImagePath = rutaLocal;
    });

    if (rutaAnterior != null && rutaAnterior != rutaLocal) {
      /**
      Eso pregunta dos cosas:

        ¿Había una foto anterior?
        ¿La nueva ruta es distinta?
       */
      final File fotoAnterior = File(rutaAnterior); //convierte la ruta anterior en un archivo real.

      if (await fotoAnterior.exists()) { //comprueba que el archivo siga existiendo.
        await fotoAnterior.delete(); //lo elimina físicamente.
      }
    }
  }

  /**
  Aquí hay una diferencia respecto a las prendas.

    Para las prendas usamos nombres únicos:

    1787535000123.jpg
    1787535000456.jpg

    porque necesitamos muchas imágenes distintas.

    Para la foto base, en cambio, solo queremos una activa.

    Por eso podemos usar:

    foto_base.jpg

    y cada vez que la usuaria cambie su foto base, esa imagen puede reemplazarse.
      */

  Future<String> _guardarFotoBaseLocalmente(XFile image) async {
    final Directory directory = await getApplicationDocumentsDirectory();

    final String nombreArchivo =
        'foto_base_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final String nuevaRuta =
        '${directory.path}/$nombreArchivo';

    final File imagenGuardada =
        await File(image.path).copy(nuevaRuta);

    return imagenGuardada.path;
  }

  Future<void> _guardarRutaFotoBase(String ruta) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('fotoBasePath', ruta);
  }

  Future<void> _cargarFotoBase() async {
    final prefs = await SharedPreferences.getInstance();

    final String? ruta = prefs.getString('fotoBasePath');

    if (ruta == null) {
      return;
    }

    setState(() {
      _baseImagePath = ruta;
    });
  }

  @override
  void initState() {
    super.initState();
    _cargarFotoBase();
  }

}

Widget _buildCategoryButton({
  required IconData icon,
  required String label,
  required VoidCallback onTap,// VoidCallback significa, en sencillo:
  //una función que no recibe parámetros y no devuelve un valor.
  //Técnicamente, es un tipo de función muy usado en Flutter para eventos de botones.
  required bool selected,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 6,
        ),
        decoration: BoxDecoration(
          color: selected 
              ? Colors.pinkAccent 
              : Colors.white.withOpacity(0.92), //decoración del Container
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : Colors.pinkAccent,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }