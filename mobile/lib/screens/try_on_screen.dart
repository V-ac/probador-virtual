import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/clothing.dart';

class TryOnPage extends StatefulWidget {
  const TryOnPage({super.key});

  @override
  State<TryOnPage> createState() => _TryOnPageState();
}

class _TryOnPageState extends State<TryOnPage> {
  // ============================================================
  // ESTADO DEL PROBADOR
  // ============================================================

  // Ruta de la fotografía de cuerpo completo que usamos como base.
  String? _baseImagePath;

  // Categoría actualmente seleccionada:
  // Superior, Inferior, Vestido o null.
  String? _categoriaSeleccionada;

  // Controla qué contenido muestra el panel:
  // "Prendas" o "Sugerencias".
  String _modoPanel = 'Prendas';

  // Nos dice si estamos en el modo donde ya se eligió
  // una prenda y mostramos Cancelar / Aceptar.
  bool _prendaEnPrueba = false;

  // ============================================================
  // NUEVO:
  // PRENDA REAL SELECCIONADA
  // ============================================================
  //
  // Clothing? significa:
  //
  // puede contener una prenda real:
  // Playera blanca
  //
  // o puede contener:
  // null
  //
  // cuando todavía no hemos seleccionado ninguna.
  Clothing? _prendaSeleccionada;

  // Todas las prendas cargadas desde SharedPreferences.
  List<Clothing> _prendas = [];

  // Objeto encargado de abrir la galería.
  final ImagePicker _picker = ImagePicker();

  // ============================================================
  // CICLO DE VIDA
  // ============================================================

  @override
  void initState() {
    super.initState();

    // Cuando se crea la pantalla:
    // 1. cargamos la foto base guardada;
    // 2. cargamos las prendas del closet.
    _cargarFotoBase();
    _cargarPrendas();
  }

  // ============================================================
  // INTERFAZ PRINCIPAL
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // Filtramos las prendas según la categoría seleccionada.
    //
    // Ejemplo:
    //
    // _categoriaSeleccionada == 'Superior'
    //
    // entonces solamente tendremos prendas cuya:
    //
    // prenda.category == 'Superior'
    final List<Clothing> prendasFiltradas = _prendas
        .where((prenda) => prenda.category == _categoriaSeleccionada)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F7),

      appBar: AppBar(
        title: const Text(
          'Probador',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),

            // Stack nos permite colocar elementos unos encima de otros.
            //
            // Aquí tenemos:
            //
            // - fotografía base
            // - categorías
            // - engrane
            // - panel de prendas/sugerencias
            // - Cancelar / Aceptar
            //
            // Más adelante también pondremos aquí
            // la prenda encima de la fotografía.
            child: Stack(
              children: [
                // ====================================================
                // FOTO BASE
                // ====================================================
                Center(
                  child: _baseImagePath == null
                      ? const Padding(
                          padding: EdgeInsets.all(30),
                          child: Text(
                            'Aquí aparecerá tu foto de cuerpo completo',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Image.file(File(_baseImagePath!), fit: BoxFit.contain),
                ),

                // ====================================================
                // CATEGORÍAS LATERALES
                // ====================================================
                Positioned(
                  left: 12,
                  top: 40,

                  child: Column(
                    children: [
                      // ---------------- SUPERIOR ----------------
                      _buildCategoryButton(
                        icon: Icons.checkroom,
                        label: 'Superior',
                        selected: _categoriaSeleccionada == 'Superior',
                        onTap: () {
                          // Si ya estamos probando una prenda,
                          // no permitimos abrir otra categoría.
                          if (_prendaEnPrueba) {
                            return;
                          }

                          setState(() {
                            _categoriaSeleccionada = 'Superior';

                            // Cada categoría nueva comienza
                            // mostrando "Prendas".
                            _modoPanel = 'Prendas';
                          });
                        },
                      ),

                      const SizedBox(height: 10),

                      // ---------------- INFERIOR ----------------
                      _buildCategoryButton(
                        icon: Icons.layers_outlined,
                        label: 'Inferior',
                        selected: _categoriaSeleccionada == 'Inferior',
                        onTap: () {
                          if (_prendaEnPrueba) {
                            return;
                          }

                          setState(() {
                            _categoriaSeleccionada = 'Inferior';
                            _modoPanel = 'Prendas';
                          });
                        },
                      ),

                      const SizedBox(height: 10),

                      // ---------------- VESTIDOS ----------------
                      _buildCategoryButton(
                        icon: Icons.dry_cleaning_outlined,
                        label: 'Vestidos',

                        // Visualmente mostramos "Vestidos".
                        //
                        // Internamente usamos "Vestido"
                        // porque así guardamos Clothing.category.
                        selected: _categoriaSeleccionada == 'Vestido',
                        onTap: () {
                          if (_prendaEnPrueba) {
                            return;
                          }

                          setState(() {
                            _categoriaSeleccionada = 'Vestido';
                            _modoPanel = 'Prendas';
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // ====================================================
                // ENGRANE / CONFIGURACIÓN
                // ====================================================
                //
                // Solo aparece cuando:
                //
                // NO hay categoría abierta
                // Y
                // NO hay una prenda en prueba.
                //
                // Así no podemos cambiar accidentalmente
                // la fotografía base mientras elegimos ropa.
                if (_categoriaSeleccionada == null && !_prendaEnPrueba)
                  Positioned(
                    top: 12,
                    right: 12,

                    child: IconButton(
                      onPressed: _mostrarOpcionesProbador,
                      icon: const Icon(Icons.settings),
                      tooltip: 'Opciones del probador',
                    ),
                  ),

                // ====================================================
                // PANEL FLOTANTE
                // PRENDAS / SUGERENCIAS
                // ====================================================
                //
                // Este panel solamente existe cuando
                // hay una categoría seleccionada.
                if (_categoriaSeleccionada != null)
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
                          // ========================================
                          // ENCABEZADO DEL PANEL
                          // ========================================
                          Row(
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                color: Colors.pinkAccent,
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: Text(
                                  _categoriaSeleccionada == 'Vestido'
                                      ? 'Prendas de Vestidos'
                                      : 'Prendas de $_categoriaSeleccionada',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),

                              // X para cerrar el panel.
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

                          // ========================================
                          // DESCRIPCIÓN DE LA CATEGORÍA
                          // ========================================
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

                          // ========================================
                          // SELECTOR:
                          // PRENDAS / SUGERENCIAS
                          // ========================================
                          Row(
                            children: [
                              // ------------ PRENDAS ------------
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

                              // ---------- SUGERENCIAS ----------
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

                          // ========================================
                          // MODO PRENDAS
                          // ========================================
                          if (_modoPanel == 'Prendas')
                            prendasFiltradas.isEmpty
                                // No hay prendas.
                                ? const Text(
                                    'No hay prendas en esta categoría.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  )
                                // Sí tenemos prendas.
                                : SizedBox(
                                    height: 145,

                                    // ListView.separated crea
                                    // una lista con separación automática
                                    // entre cada elemento.
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,

                                      itemCount: prendasFiltradas.length,

                                      // Espacio entre tarjetas.
                                      separatorBuilder: (context, index) {
                                        return const SizedBox(width: 10);
                                      },

                                      // ==================================
                                      // CONSTRUCCIÓN DE CADA PRENDA
                                      // ==================================
                                      itemBuilder: (context, index) {
                                        // Aquí obtenemos UNA prenda
                                        // de prendasFiltradas.
                                        //
                                        // Ejemplo:
                                        //
                                        // Playera blanca
                                        final Clothing prenda =
                                            prendasFiltradas[index];

                                        // ==================================
                                        // NUEVO:
                                        // INKWELL HACE LA TARJETA TOCABLE
                                        // ==================================

                                        return InkWell(
                                          // Cuando tocamos esta tarjeta...
                                          onTap: () {
                                            setState(() {
                                              // Guardamos exactamente
                                              // qué Clothing seleccionamos.
                                              _prendaSeleccionada = prenda;

                                              // Entramos al modo prueba.
                                              _prendaEnPrueba = true;

                                              // Cerramos el panel
                                              // de categorías.
                                              _categoriaSeleccionada = null;

                                              // Lo dejamos listo
                                              // para la próxima apertura.
                                              _modoPanel = 'Prendas';
                                            });
                                          },

                                          // Hace que el efecto del toque
                                          // siga las esquinas redondeadas.
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),

                                          child: Container(
                                            width: 95,
                                            padding: const EdgeInsets.all(8),

                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),

                                            child: Column(
                                              children: [
                                                // -------------------
                                                // IMAGEN
                                                // -------------------
                                                Expanded(
                                                  child:
                                                      prenda.imagePath == null
                                                      ? const Icon(
                                                          Icons.checkroom,
                                                          size: 40,
                                                          color:
                                                              Colors.pinkAccent,
                                                        )
                                                      : ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                          child: Image.file(
                                                            File(
                                                              prenda.imagePath!,
                                                            ),
                                                            width:
                                                                double.infinity,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                ),

                                                const SizedBox(height: 6),

                                                // -------------------
                                                // NOMBRE
                                                // -------------------
                                                Text(
                                                  prenda.name,

                                                  // Permitimos hasta
                                                  // dos líneas.
                                                  maxLines: 2,

                                                  // Si todavía no cabe,
                                                  // usamos "...".
                                                  overflow:
                                                      TextOverflow.ellipsis,

                                                  textAlign: TextAlign.center,

                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                          // ========================================
                          // MODO SUGERENCIAS
                          // ========================================
                          else
                            const Text(
                              'Aquí aparecerán sugerencias relacionadas con tu ovni mi amor.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                // ====================================================
                // PRENDA EN PRUEBA
                // ====================================================
                //
                // Al tocar una tarjeta real:
                //
                // _prendaSeleccionada = prenda
                // _prendaEnPrueba = true
                //
                // Entonces aparece esta parte.
                if (_prendaEnPrueba)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,

                    child: Row(
                      children: [
                        // ---------------- CANCELAR ----------------
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                // Salimos del modo prueba.
                                _prendaEnPrueba = false;

                                // Cancelar significa que
                                // descartamos completamente
                                // la prenda seleccionada.
                                _prendaSeleccionada = null;
                              });
                            },
                            child: const Text('Cancelar'),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // ---------------- ACEPTAR ----------------
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              setState(() {
                                // Terminamos el modo de confirmación.
                                _prendaEnPrueba = false;

                                // IMPORTANTE:
                                //
                                // NO ponemos
                                // _prendaSeleccionada = null;
                                //
                                // porque al aceptar queremos
                                // conservar esa Clothing.
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
      ),
    );
  }

  // ============================================================
  // SELECCIONAR Y GUARDAR FOTO BASE
  // ============================================================

  Future<void> _seleccionarFotoBase() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    // Si la usuaria canceló la galería,
    // terminamos la función.
    if (image == null) {
      return;
    }

    // Guardamos la ruta vieja para eliminarla
    // después de guardar correctamente la nueva.
    final String? rutaAnterior = _baseImagePath;

    // Copiamos la fotografía a almacenamiento
    // privado de nuestra aplicación.
    final String rutaLocal = await _guardarFotoBaseLocalmente(image);

    // Guardamos la ruta para futuras sesiones.
    await _guardarRutaFotoBase(rutaLocal);

    setState(() {
      _baseImagePath = rutaLocal;
    });

    // Eliminamos la fotografía anterior
    // para no acumular archivos innecesarios.
    if (rutaAnterior != null && rutaAnterior != rutaLocal) {
      final File fotoAnterior = File(rutaAnterior);

      if (await fotoAnterior.exists()) {
        await fotoAnterior.delete();
      }
    }
  }

  // ============================================================
  // COPIAR FOTO BASE A ALMACENAMIENTO PRIVADO
  // ============================================================

  Future<String> _guardarFotoBaseLocalmente(XFile image) async {
    final Directory directory = await getApplicationDocumentsDirectory();

    // Cada nueva foto recibe un nombre diferente.
    //
    // Esto también evita el problema de caché
    // que vimos anteriormente.
    final String nombreArchivo =
        'foto_base_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final String nuevaRuta = '${directory.path}/$nombreArchivo';

    final File imagenGuardada = await File(image.path).copy(nuevaRuta);

    return imagenGuardada.path;
  }

  // ============================================================
  // GUARDAR RUTA FOTO BASE
  // ============================================================

  Future<void> _guardarRutaFotoBase(String ruta) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('fotoBasePath', ruta);
  }

  // ============================================================
  // CARGAR FOTO BASE
  // ============================================================

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

  // ============================================================
  // CARGAR PRENDAS DEL CLOSET
  // ============================================================

  Future<void> _cargarPrendas() async {
    final prefs = await SharedPreferences.getInstance();

    final String? prendasJson = prefs.getString('prendas');

    if (prendasJson == null) {
      return;
    }

    // String JSON
    //      ↓
    // datos Dart
    final List<dynamic> prendasDecodificadas = jsonDecode(prendasJson);

    // Map
    // ↓
    // Clothing
    final List<Clothing> prendasCargadas = prendasDecodificadas
        .map((map) => Clothing.fromMap(map))
        .toList();

    setState(() {
      _prendas = prendasCargadas;
    });
  }

  // ============================================================
  // OPCIONES DEL PROBADOR
  // ============================================================

  void _mostrarOpcionesProbador() {
    showModalBottomSheet(
      context: context,

      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Cambiar foto base'),
                onTap: () {
                  // Cerramos primero el menú.
                  Navigator.pop(ctx);

                  // Abrimos después la galería.
                  _seleccionarFotoBase();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // BOTÓN DE CATEGORÍA REUTILIZABLE
  // ============================================================

  Widget _buildCategoryButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool selected,
  }) {
    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(16),

      child: Container(
        width: 72,

        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),

        decoration: BoxDecoration(
          // Categoría seleccionada:
          // rosa.
          //
          // Categoría normal:
          // blanco.
          color: selected ? Colors.pinkAccent : Colors.white.withOpacity(0.92),

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
}
