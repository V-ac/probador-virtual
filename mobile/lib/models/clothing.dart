// La carpeta models la usamos para clases que representan los datos de nuestra aplicación.
class Clothing { //Estamos creando un nuevo tipo de dato llamado Clothing.
  //String indica el tipo de dato:
  // name es el nombre de la propiedad.
  // Y final significa que, después de crear el objeto, esa referencia no se puede reasignar.

  final String name;
  final String? imagePath;
    /** 
    permite que al crear la prenda le demos un nombre:

    Playera negra

    pero luego no podremos hacer:

    clothing.name = 'Pantalón';

    */
  Clothing({ //Esto es el constructor de la clase.
    required this.name,
    this.imagePath,
  });

      /**
      Por ejemplo:

    Clothing(
      name: 'Playera negra',
    );

    Aquí Dart ejecuta:

    Clothing({
      required this.name,
    });

    y guarda 'Playera negra' dentro de:

    name

    Puedes imaginarlo así:

    Clothing(
      name: 'Playera negra',
    )
            ↓
    constructor
            ↓
    this.name = 'Playera negra'
      */
  Map<String, dynamic> toMap(){

    /**
      Map<String, dynamic> significa que vamos a crear una estructura de pares clave → valor.

        Por ejemplo:

        {
          'name': 'Playera negra',
          'imagePath': '/ruta/imagen.jpg',
        }

        En palabras sencillas, es como una ficha:

        name      → Playera negra
        imagePath → /ruta/imagen.jpg
    
     */

     /**
     Y dynamic significa que los valores pueden ser de distintos tipos.

        En nuestro caso ahora tenemos:

        name      → String
        imagePath → String o null

        Por eso dynamic nos sirve.
     
      */
    return{
      'name': name,
      'imagePath': imagePath,
    };
  }

  factory Clothing.fromMap(Map<String, dynamic> map) { //"Este constructor recibe datos que ya existen y fabrica un Clothing a partir de ellos.”
    return Clothing(
      name: map['name'],
      imagePath: map['imagePath'],
    );
  }


}

