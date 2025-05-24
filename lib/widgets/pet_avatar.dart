import 'package:flutter/material.dart';
import '../models/amora_pet.dart';

/// Widget para exibir o avatar do AmoraPet
class PetAvatar extends StatelessWidget {
  final AmoraPet pet;
  final double size;

  const PetAvatar({
    super.key,
    required this.pet,
    this.size = 150,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Base do pet (corpo principal)
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getPetBaseColor(),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),
          
          // Rosto do pet
          Positioned.fill(
            child: CustomPaint(
              painter: _PetFacePainter(
                mood: pet.mood,
                petType: pet.type,
              ),
            ),
          ),
          
          // Itens equipados (sobrepostos ao pet)
          ...pet.equippedItems.map((item) {
            // No MVP, apenas mostramos um chapéu como exemplo
            if (item.id == 'hat_01') {
              return Positioned(
                top: -size * 0.15,
                left: size * 0.25,
                right: size * 0.25,
                height: size * 0.3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.yellow,
                      ),
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }).toList(),
        ],
      ),
    );
  }

  // Retorna a cor base do pet com base na cor selecionada
  Color _getPetBaseColor() {
    switch (pet.color) {
      case PetColor.pink:
        return Colors.pink.shade200;
      case PetColor.blue:
        return Colors.blue.shade200;
      case PetColor.green:
        return Colors.green.shade200;
      case PetColor.yellow:
        return Colors.amber.shade200;
      case PetColor.purple:
        return Colors.purple.shade200;
    }
  }
}

/// Painter personalizado para desenhar o rosto do pet
class _PetFacePainter extends CustomPainter {
  final PetMood mood;
  final PetType petType;

  _PetFacePainter({
    required this.mood,
    required this.petType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Pintar olhos
    _drawEyes(canvas, center, size);
    
    // Pintar boca/sorriso baseado no humor
    _drawMouth(canvas, center, size);
    
    // Adicionar detalhes específicos por tipo de pet
    _drawPetTypeDetails(canvas, center, size);
  }

  void _drawEyes(Canvas canvas, Offset center, Size size) {
    final eyePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
      
    final eyeSize = size.width * 0.15;
    final eyeOffset = size.width * 0.15;
    
    // Desenhar olhos
    canvas.drawCircle(
      Offset(center.dx - eyeOffset, center.dy - eyeOffset * 0.5),
      eyeSize / 2,
      eyePaint,
    );
    
    canvas.drawCircle(
      Offset(center.dx + eyeOffset, center.dy - eyeOffset * 0.5),
      eyeSize / 2,
      eyePaint,
    );
    
    // Adicionar brilho aos olhos
    final highlightPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle(
      Offset(center.dx - eyeOffset + eyeSize * 0.25, center.dy - eyeOffset * 0.5 - eyeSize * 0.25),
      eyeSize / 5,
      highlightPaint,
    );
    
    canvas.drawCircle(
      Offset(center.dx + eyeOffset + eyeSize * 0.25, center.dy - eyeOffset * 0.5 - eyeSize * 0.25),
      eyeSize / 5,
      highlightPaint,
    );
    
    // Se estiver triste ou doente, modificar os olhos
    if (mood == PetMood.sad || mood == PetMood.sick) {
      final eyebrowPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      
      // Sobrancelhas para expressão triste
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(center.dx - eyeOffset, center.dy - eyeOffset - eyeSize * 0.5),
          width: eyeSize,
          height: eyeSize * 0.5,
        ),
        0,
        3.14,
        false,
        eyebrowPaint,
      );
      
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(center.dx + eyeOffset, center.dy - eyeOffset - eyeSize * 0.5),
          width: eyeSize,
          height: eyeSize * 0.5,
        ),
        0,
        3.14,
        false,
        eyebrowPaint,
      );
    }
  }

  void _drawMouth(Canvas canvas, Offset center, Size size) {
    final mouthPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    
    final mouthWidth = size.width * 0.3;
    final mouthHeight = size.height * 0.15;
    
    switch (mood) {
      case PetMood.happy:
      case PetMood.excited:
        // Boca sorridente
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(center.dx, center.dy + size.height * 0.1),
            width: mouthWidth,
            height: mouthHeight,
          ),
          0,
          3.14,
          false,
          mouthPaint,
        );
        break;
        
      case PetMood.sad:
        // Boca triste
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(center.dx, center.dy + size.height * 0.2),
            width: mouthWidth,
            height: mouthHeight,
          ),
          3.14,
          3.14,
          false,
          mouthPaint,
        );
        break;
        
      case PetMood.sick:
        // Boca reta para aparência doente
        canvas.drawLine(
          Offset(center.dx - mouthWidth / 2, center.dy + size.height * 0.15),
          Offset(center.dx + mouthWidth / 2, center.dy + size.height * 0.15),
          mouthPaint,
        );
        break;
        
      case PetMood.neutral:
        // Boca levemente curvada
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(center.dx, center.dy + size.height * 0.1),
            width: mouthWidth,
            height: mouthHeight * 0.5,
          ),
          0,
          3.14,
          false,
          mouthPaint,
        );
        break;
    }
  }

  void _drawPetTypeDetails(Canvas canvas, Offset center, Size size) {
    final detailPaint = Paint()
      ..style = PaintingStyle.fill;
    
    switch (petType) {
      case PetType.cat:
        // Orelhas de gato
        detailPaint.color = Colors.black.withOpacity(0.7);
        
        final earSize = size.width * 0.2;
        final earOffset = size.width * 0.25;
        
        // Orelha esquerda
        final leftEarPath = Path()
          ..moveTo(center.dx - earOffset, center.dy - size.height * 0.3)
          ..lineTo(center.dx - earOffset - earSize, center.dy - size.height * 0.5)
          ..lineTo(center.dx - earOffset + earSize * 0.5, center.dy - size.height * 0.4)
          ..close();
          
        canvas.drawPath(leftEarPath, detailPaint);
        
        // Orelha direita
        final rightEarPath = Path()
          ..moveTo(center.dx + earOffset, center.dy - size.height * 0.3)
          ..lineTo(center.dx + earOffset + earSize, center.dy - size.height * 0.5)
          ..lineTo(center.dx + earOffset - earSize * 0.5, center.dy - size.height * 0.4)
          ..close();
          
        canvas.drawPath(rightEarPath, detailPaint);
        
        // Detalhes internos das orelhas
        detailPaint.color = Colors.pink.withOpacity(0.7);
        
        final innerLeftEarPath = Path()
          ..moveTo(center.dx - earOffset, center.dy - size.height * 0.3)
          ..lineTo(center.dx - earOffset - earSize * 0.7, center.dy - size.height * 0.45)
          ..lineTo(center.dx - earOffset + earSize * 0.3, center.dy - size.height * 0.38)
          ..close();
          
        canvas.drawPath(innerLeftEarPath, detailPaint);
        
        final innerRightEarPath = Path()
          ..moveTo(center.dx + earOffset, center.dy - size.height * 0.3)
          ..lineTo(center.dx + earOffset + earSize * 0.7, center.dy - size.height * 0.45)
          ..lineTo(center.dx + earOffset - earSize * 0.3, center.dy - size.height * 0.38)
          ..close();
          
        canvas.drawPath(innerRightEarPath, detailPaint);
        
        // Bigodes
        detailPaint.color = Colors.black;
        detailPaint.style = PaintingStyle.stroke;
        detailPaint.strokeWidth = 2;
        
        // Bigodes esquerda
        canvas.drawLine(
          Offset(center.dx - size.width * 0.15, center.dy + size.height * 0.05),
          Offset(center.dx - size.width * 0.4, center.dy),
          detailPaint,
        );
        
        canvas.drawLine(
          Offset(center.dx - size.width * 0.15, center.dy + size.height * 0.1),
          Offset(center.dx - size.width * 0.4, center.dy + size.height * 0.1),
          detailPaint,
        );
        
        // Bigodes direita
        canvas.drawLine(
          Offset(center.dx + size.width * 0.15, center.dy + size.height * 0.05),
          Offset(center.dx + size.width * 0.4, center.dy),
          detailPaint,
        );
        
        canvas.drawLine(
          Offset(center.dx + size.width * 0.15, center.dy + size.height * 0.1),
          Offset(center.dx + size.width * 0.4, center.dy + size.height * 0.1),
          detailPaint,
        );
        break;
        
      case PetType.dog:
        // Orelhas de cachorro
        detailPaint.color = Colors.brown;
        
        final earSize = size.width * 0.2;
        
        // Orelha esquerda
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(center.dx - size.width * 0.3, center.dy - size.height * 0.3),
            width: earSize,
            height: earSize * 1.5,
          ),
          detailPaint,
        );
        
        // Orelha direita
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(center.dx + size.width * 0.3, center.dy - size.height * 0.3),
            width: earSize,
            height: earSize * 1.5,
          ),
          detailPaint,
        );
        
        // Focinho
        detailPaint.color = Colors.brown.shade300;
        
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(center.dx, center.dy + size.height * 0.1),
            width: size.width * 0.3,
            height: size.height * 0.25,
          ),
          detailPaint,
        );
        
        // Nariz
        detailPaint.color = Colors.black;
        
        canvas.drawCircle(
          Offset(center.dx, center.dy + size.height * 0.05),
          size.width * 0.08,
          detailPaint,
        );
        break;
        
      case PetType.rabbit:
        // Orelhas de coelho
        detailPaint.color = Colors.grey.shade300;
        
        // Orelha esquerda
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(center.dx - size.width * 0.15, center.dy - size.height * 0.4),
            width: size.width * 0.2,
            height: size.height * 0.6,
          ),
          detailPaint,
        );
        
        // Orelha direita
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(center.dx + size.width * 0.15, center.dy - size.height * 0.4),
            width: size.width * 0.2,
            height: size.height * 0.6,
          ),
          detailPaint,
        );
        
        // Detalhes internos das orelhas
        detailPaint.color = Colors.pink.shade200;
        
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(center.dx - size.width * 0.15, center.dy - size.height * 0.4),
            width: size.width * 0.1,
            height: size.height * 0.4,
          ),
          detailPaint,
        );
        
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(center.dx + size.width * 0.15, center.dy - size.height * 0.4),
            width: size.width * 0.1,
            height: size.height * 0.4,
          ),
          detailPaint,
        );
        
        // Nariz
        detailPaint.color = Colors.pink;
        
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(center.dx, center.dy + size.height * 0.05),
            width: size.width * 0.15,
            height: size.height * 0.1,
          ),
          detailPaint,
        );
        break;
        
      case PetType.bird:
        // Bico
        detailPaint.color = Colors.orange;
        
        final beakPath = Path()
          ..moveTo(center.dx, center.dy + size.height * 0.05)
          ..lineTo(center.dx - size.width * 0.1, center.dy + size.height * 0.15)
          ..lineTo(center.dx + size.width * 0.1, center.dy + size.height * 0.15)
          ..close();
          
        canvas.drawPath(beakPath, detailPaint);
        
        // Crista
        detailPaint.color = Colors.red;
        
        for (int i = 0; i < 3; i++) {
          final offset = i - 1;
          final cristPath = Path()
            ..moveTo(center.dx + offset * size.width * 0.1, center.dy - size.height * 0.3)
            ..lineTo(center.dx + offset * size.width * 0.1, center.dy - size.height * 0.5)
            ..lineTo(center.dx + offset * size.width * 0.1 + size.width * 0.05, center.dy - size.height * 0.4)
            ..close();
            
          canvas.drawPath(cristPath, detailPaint);
        }
        
        // Asas
        detailPaint.color = Colors.blue.shade800;
        
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(center.dx - size.width * 0.25, center.dy),
            width: size.width * 0.2,
            height: size.height * 0.4,
          ),
          detailPaint,
        );
        
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(center.dx + size.width * 0.25, center.dy),
            width: size.width * 0.2,
            height: size.height * 0.4,
          ),
          detailPaint,
        );
        break;
        
      case PetType.hamster:
        // Orelhas de hamster
        detailPaint.color = Colors.brown.shade300;
        
        canvas.drawCircle(
          Offset(center.dx - size.width * 0.2, center.dy - size.height * 0.3),
          size.width * 0.1,
          detailPaint,
        );
        
        canvas.drawCircle(
          Offset(center.dx + size.width * 0.2, center.dy - size.height * 0.3),
          size.width * 0.1,
          detailPaint,
        );
        
        // Bolsas das bochechas
        detailPaint.color = Colors.brown.shade200;
        
        canvas.drawCircle(
          Offset(center.dx - size.width * 0.25, center.dy + size.height * 0.05),
          size.width * 0.15,
          detailPaint,
        );
        
        canvas.drawCircle(
          Offset(center.dx + size.width * 0.25, center.dy + size.height * 0.05),
          size.width * 0.15,
          detailPaint,
        );
        
        // Nariz
        detailPaint.color = Colors.black;
        
        canvas.drawCircle(
          Offset(center.dx, center.dy + size.height * 0.05),
          size.width * 0.05,
          detailPaint,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
