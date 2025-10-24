import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../models/treasure_model.dart';
import 'treasure_service.dart';

class TreasureDetailsDialog extends StatefulWidget {
  final Treasure treasure;
  final Position? currentPosition;
  final Function(Treasure) onTreasureClaimed;
  final String currentUserId; // Agregar ID del usuario actual

  const TreasureDetailsDialog({
    super.key,
    required this.treasure,
    required this.currentPosition,
    required this.onTreasureClaimed,
    required this.currentUserId, // Requerir ID del usuario
  });

  @override
  State<TreasureDetailsDialog> createState() => _TreasureDetailsDialogState();
}

class _TreasureDetailsDialogState extends State<TreasureDetailsDialog> {
  bool _isClaiming = false;
  final TreasureService _treasureService = TreasureService();

  String _getDifficultyText(int difficulty) {
    switch (difficulty) {
      case 1:
        return 'Muy Fácil';
      case 2:
        return 'Fácil';
      case 3:
        return 'Medio';
      case 4:
        return 'Difícil';
      case 5:
        return 'Muy Difícil';
      default:
        return 'Desconocido';
    }
  }

  Color _getDifficultyColor(int difficulty) {
    switch (difficulty) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.deepOrange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _claimTreasure() async {
    setState(() {
      _isClaiming = true;
    });

    try {
      final success = await _treasureService.claimTreasure(
        widget.treasure.id,
        widget.currentUserId, // Usar ID real del usuario
      );

      if (success) {
        final claimedTreasure = Treasure(
          id: widget.treasure.id,
          creatorId: widget.treasure.creatorId,
          creatorName: widget.treasure.creatorName,
          title: widget.treasure.title,
          description: widget.treasure.description,
          imageUrl: widget.treasure.imageUrl,
          latitude: widget.treasure.latitude,
          longitude: widget.treasure.longitude,
          hint: widget.treasure.hint,
          difficulty: widget.treasure.difficulty,
          clues: widget.treasure.clues,
          createdAt: widget.treasure.createdAt,
          points: widget.treasure.points,
          isFound: true,
          foundBy: widget.currentUserId, // Usar ID real del usuario
          foundAt: DateTime.now(),
        );

        widget.onTreasureClaimed(claimedTreasure);

        // Cerrar el dialog después de un breve delay para mostrar la animación
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.of(context).pop();
        }

        // Mostrar mensaje de celebración con animación
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.celebration, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '🎉 ¡Tesoro encontrado! +${widget.treasure.points} puntos ganados',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('Error al reclamar el tesoro. Inténtalo de nuevo.'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Error de conexión: $e'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isClaiming = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final distance = widget.currentPosition != null
        ? widget.treasure.distanceFrom(
            widget.currentPosition!.latitude,
            widget.currentPosition!.longitude,
          )
        : double.infinity;

    final isVeryClose = distance < 50; // 50 metros

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con dificultad
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.treasure.title,
                      style: GoogleFonts.lato(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4052B6),
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(widget.treasure.difficulty),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getDifficultyText(widget.treasure.difficulty),
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Imagen del tesoro (si existe)
              if (widget.treasure.imageUrl != null)
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(widget.treasure.imageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Descripción
              Text(
                'Descripción:',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.treasure.description,
                style: GoogleFonts.lato(fontSize: 14),
              ),
              const SizedBox(height: 16),

              // Pista inicial
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pista Inicial:',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.treasure.hint,
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Información de distancia
              if (widget.currentPosition != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isVeryClose ? Colors.green[50] : Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isVeryClose
                          ? Colors.green[200]!
                          : Colors.orange[200]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isVeryClose
                            ? Icons.location_on
                            : Icons.location_searching,
                        color: isVeryClose
                            ? Colors.green[700]
                            : Colors.orange[700],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isVeryClose
                              ? '¡Estás muy cerca! Busca en los alrededores.'
                              : widget.treasure.getDistanceHint(
                                  widget.currentPosition!.latitude,
                                  widget.currentPosition!.longitude,
                                ),
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            color: isVeryClose
                                ? Colors.green[700]
                                : Colors.orange[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Pistas adicionales (solo si está muy cerca)
              if (isVeryClose && widget.treasure.clues.isNotEmpty) ...[
                Text(
                  'Pistas Adicionales:',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...widget.treasure.clues.map((clue) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontSize: 16)),
                          Expanded(
                            child: Text(
                              clue,
                              style: GoogleFonts.lato(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 16),
              ],

              // Información del creador y puntos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Creado por:',
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        widget.treasure.creatorName,
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4052B6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.treasure.points}',
                          style: GoogleFonts.lato(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Estado del tesoro
              if (widget.treasure.isFound) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '¡Este tesoro ya fue encontrado!',
                          style: GoogleFonts.lato(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (isVeryClose) ...[
                // Información de distancia y pistas adicionales
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Colors.blue, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '¡Estás muy cerca!',
                            style: GoogleFonts.lato(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Distancia: ${distance.toStringAsFixed(1)} metros',
                        style: GoogleFonts.lato(
                          color: Colors.blue[600],
                          fontSize: 12,
                        ),
                      ),
                      if (widget.treasure.hint.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Pista: ${widget.treasure.hint}',
                          style: GoogleFonts.lato(
                            color: Colors.blue[800],
                            fontStyle: FontStyle.italic,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      if (widget.treasure.clues.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Pistas adicionales:',
                          style: GoogleFonts.lato(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...widget.treasure.clues.map((clue) => Padding(
                              padding:
                                  const EdgeInsets.only(left: 8, bottom: 2),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ',
                                      style: TextStyle(color: Colors.blue)),
                                  Expanded(
                                    child: Text(
                                      clue,
                                      style: GoogleFonts.lato(
                                        color: Colors.blue[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ],
                  ),
                ),

                // Botón para reclamar tesoro
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isClaiming ? null : _claimTreasure,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4052B6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: _isClaiming
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                '¡Reclamar Tesoro! (+${widget.treasure.points} pts)',
                                style: GoogleFonts.lato(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ] else ...[
                // Mensaje para acercarse más con pista de distancia
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.directions_walk,
                              color: Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.treasure.getDistanceHint(
                                widget.currentPosition!.latitude,
                                widget.currentPosition!.longitude,
                              ),
                              style: GoogleFonts.lato(
                                color: Colors.orange[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Distancia actual: ${distance.toStringAsFixed(1)} metros',
                        style: GoogleFonts.lato(
                          color: Colors.orange[600],
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Botón cerrar
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
