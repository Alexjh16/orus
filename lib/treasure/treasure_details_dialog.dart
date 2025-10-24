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
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('¡Tesoro encontrado! +${widget.treasure.points} puntos'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al reclamar el tesoro'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isClaiming = false;
      });
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
                              const Icon(Icons.search),
                              const SizedBox(width: 8),
                              Text(
                                '¡Reclamar Tesoro!',
                                style: GoogleFonts.lato(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ] else ...[
                // Mensaje para acercarse más
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Text(
                    'Acércate más para ver pistas adicionales y reclamar el tesoro.',
                    style: GoogleFonts.lato(
                      color: Colors.orange[700],
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
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
