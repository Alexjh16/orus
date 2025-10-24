import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import '../models/treasure_model.dart';
import 'treasure_service.dart';

class CreateTreasureDialog extends StatefulWidget {
  final Position currentPosition;
  final String creatorId;
  final String creatorName;
  final Function(Treasure) onTreasureCreated;

  const CreateTreasureDialog({
    super.key,
    required this.currentPosition,
    required this.creatorId,
    required this.creatorName,
    required this.onTreasureCreated,
  });

  @override
  State<CreateTreasureDialog> createState() => _CreateTreasureDialogState();
}

class _CreateTreasureDialogState extends State<CreateTreasureDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _hintController = TextEditingController();
  final _cluesController = TextEditingController();

  int _difficulty = 1;
  int _points = 10;
  File? _selectedImage;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  final TreasureService _treasureService = TreasureService();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _hintController.dispose();
    _cluesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _selectedImage = File(photo.path);
      });
    }
  }

  Future<void> _createTreasure() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Convertir pistas a lista
      final clues = _cluesController.text
          .split('\n')
          .where((clue) => clue.trim().isNotEmpty)
          .toList();

      final treasure = await _treasureService.createTreasure(
        creatorId: widget.creatorId,
        creatorName: widget.creatorName,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        imageUrl: null, // TODO: Implementar subida de imagen
        latitude: widget.currentPosition.latitude,
        longitude: widget.currentPosition.longitude,
        hint: _hintController.text.trim(),
        difficulty: _difficulty,
        clues: clues,
        points: _points,
      );

      widget.onTreasureCreated(treasure);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Tesoro creado exitosamente!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear tesoro: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Crear Nuevo Tesoro',
                  style: GoogleFonts.lato(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4052B6),
                  ),
                ),
                const SizedBox(height: 24),

                // Imagen del tesoro
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          image: _selectedImage != null
                              ? DecorationImage(
                                  image: FileImage(_selectedImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _selectedImage == null
                            ? const Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton.icon(
                            onPressed: _takePhoto,
                            icon: const Icon(Icons.camera),
                            label: const Text('Foto'),
                          ),
                          TextButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Galería'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Título
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título del Tesoro',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El título es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Descripción
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La descripción es obligatoria';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Pista inicial
                TextFormField(
                  controller: _hintController,
                  decoration: const InputDecoration(
                    labelText: 'Pista Inicial',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lightbulb),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La pista inicial es obligatoria';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Pistas adicionales
                TextFormField(
                  controller: _cluesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Pistas Adicionales (una por línea)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.list),
                    hintText: 'Pista 1\nPista 2\nPista 3',
                  ),
                ),
                const SizedBox(height: 16),

                // Dificultad
                Text(
                  'Dificultad: $_difficulty',
                  style: GoogleFonts.lato(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Slider(
                  value: _difficulty.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: _difficulty.toString(),
                  onChanged: (value) {
                    setState(() {
                      _difficulty = value.toInt();
                      _points =
                          _difficulty * 10; // Puntos basados en dificultad
                    });
                  },
                ),

                // Puntos
                Text(
                  'Puntos a ganar: $_points',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: const Color(0xFF4052B6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Botones
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _createTreasure,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4052B6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Crear Tesoro'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
