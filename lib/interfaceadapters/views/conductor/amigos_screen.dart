import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:newsentinel/constants/global_variables.dart';

/// Pantalla de "Contactos de Emergencia"
/// FRONT ONLY:
/// - Lista local en memoria (no BD).
/// - Agregar / editar / eliminar contactos.
/// - Seleccionar foto desde la galería.
/// 
/// Los de BACK solo tienen que:
/// - Reemplazar la lista `contactos` por datos que vengan de la API/BD.
/// - Implementar las llamadas reales en los métodos marcados con // TODO BACKEND.
class AmigosScreen extends StatefulWidget {
  @override
  _AmigosScreenState createState() => _AmigosScreenState();
}

class _AmigosScreenState extends State<AmigosScreen> {
  /// Lista local de contactos.
  /// Cada contacto es un Map con:
  /// nombre, relacion, telefono, direccion, photoPath (ruta local de la imagen).
  List<Map<String, dynamic>> contactos = [];

  /// Form controllers
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _relacionController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();

  /// Ruta de la imagen seleccionada para el formulario actual.
  String? _photoPath;

  /// Picker para abrir galería.
  final ImagePicker _picker = ImagePicker();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nombreController.dispose();
    _relacionController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  /// Limpia campos del formulario y la foto seleccionada.
  void _limpiarFormulario() {
    _nombreController.clear();
    _relacionController.clear();
    _telefonoController.clear();
    _direccionController.clear();
    _photoPath = null;
  }

  /// Abre la galería y guarda la ruta de la imagen en `_photoPath`.
  Future<void> _seleccionarFotoDesdeGaleria() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _photoPath = pickedFile.path;
      });
    }
  }

  /// Muestra el diálogo (Agregar / Editar).
  ///
  /// Si [contacto] es null -> Agregar.
  /// Si [contacto] != null -> Editar ese contacto.
  void _mostrarDialogContacto({Map<String, dynamic>? contacto, int? index}) {
    final bool esEdicion = contacto != null;

    if (esEdicion) {
      // Cargar datos existentes al formulario.
      _nombreController.text = contacto!['nombre'] ?? '';
      _relacionController.text = contacto['relacion'] ?? '';
      _telefonoController.text = contacto['telefono'] ?? '';
      _direccionController.text = contacto['direccion'] ?? '';
      _photoPath = contacto['photoPath']; // ruta local de la foto
    } else {
      _limpiarFormulario();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: GlobalVariables.secondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            esEdicion ? 'Editar contacto' : 'Agregar contacto',
            style: const TextStyle(color: Colors.white),
          ),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // PREVISUALIZACIÓN DE FOTO + BOTÓN "Cambiar foto"
                  GestureDetector(
                    onTap: _seleccionarFotoDesdeGaleria,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.grey.shade700,
                          backgroundImage: _photoPath != null
                              ? FileImage(File(_photoPath!))
                              : null,
                          child: _photoPath == null
                              ? const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 30,
                                )
                              : null,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tocar para elegir foto',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildInput(_nombreController, 'Nombre', required: true),
                  _buildInput(_relacionController, 'Relación (Madre, Hermano...)'),
                  _buildInput(_telefonoController, 'Teléfono'),
                  _buildInput(_direccionController, 'Dirección'),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white70),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _limpiarFormulario();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: GlobalVariables.primaryColor,
                foregroundColor: GlobalVariables.secondaryColor,
              ),
              child: Text(esEdicion ? 'Guardar' : 'Agregar'),
              onPressed: () {
                if (!_formKey.currentState!.validate()) return;

                final nuevoContacto = {
                  "nombre": _nombreController.text.trim(),
                  "relacion": _relacionController.text.trim(),
                  "telefono": _telefonoController.text.trim(),
                  "direccion": _direccionController.text.trim(),
                  "photoPath": _photoPath, // ruta local de la foto
                };

                setState(() {
                  if (esEdicion) {
                    // TODO BACKEND: Aquí en lugar de solo modificar la lista,
                    // se debería llamar al endpoint de actualización.
                    contactos[index!] = nuevoContacto;
                  } else {
                    // TODO BACKEND: Aquí en lugar de solo agregar a la lista,
                    // se debería llamar al endpoint de creación.
                    contactos.add(nuevoContacto);
                  }
                });

                Navigator.of(context).pop();
                _limpiarFormulario();
              },
            ),
          ],
        );
      },
    );
  }

  /// Campo de texto reutilizable.
  Widget _buildInput(
    TextEditingController controller,
    String label, {
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }

  /// Tarjeta de "Añadir contacto de emergencia".
  Widget _buildAddContactCard() {
    return GestureDetector(
      onTap: () => _mostrarDialogContacto(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: GlobalVariables.greyBackgroundCOlor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: GlobalVariables.secondaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: GlobalVariables.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Añadir contacto de emergencia',
              style: TextStyle(
                color: GlobalVariables.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Botón redondo para editar / eliminar.
  Widget _roundIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: GlobalVariables.secondaryColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        padding: EdgeInsets.zero,
        onPressed: onTap,
      ),
    );
  }

  /// Tarjeta de contacto que imita tu diseño de la captura.
  Widget _buildContactCard(Map<String, dynamic> contacto, int index) {
    final String nombre = contacto['nombre'] ?? '';
    final String relacion = contacto['relacion'] ?? '';
    final String? photoPath = contacto['photoPath'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 34, 34, 34),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color.fromARGB(255, 119, 119, 119),
            backgroundImage:
                (photoPath != null && photoPath.isNotEmpty)
                    ? FileImage(File(photoPath))
                    : null,
            child: (photoPath == null || photoPath.isEmpty)
                ? Text(
                    nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (relacion.isNotEmpty)
                  Text(
                    relacion,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _roundIconButton(
            icon: Icons.edit,
            color: GlobalVariables.primaryColor,
            onTap: () => _mostrarDialogContacto(
              contacto: contacto,
              index: index,
            ),
          ),
          const SizedBox(width: 8),
          _roundIconButton(
            icon: Icons.delete,
            color: Colors.redAccent,
            onTap: () {
              // TODO BACKEND: aquí borrarán en la BD.
              setState(() {
                contactos.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalVariables.secondaryColor,
      appBar: AppBar(
        backgroundColor: GlobalVariables.secondaryColor,
        elevation: 0,
        title: const Text(
          'Contactos de Emergencia',
          style: TextStyle(
            color: GlobalVariables.greyBackgroundCOlor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        children: [
          _buildAddContactCard(),
          if (contactos.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Text(
                'No tienes contactos agregados.',
                style: TextStyle(color: Colors.white70),
              ),
            )
          else
            ...contactos.asMap().entries.map(
              (entry) => _buildContactCard(entry.value, entry.key),
            ),
        ],
      ),
    );
  }
}
