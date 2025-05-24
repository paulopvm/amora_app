import 'package:flutter/material.dart';

/// Widget para mostrar as barras de status do AmoraPet
class PetStatusBar extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const PetStatusBar({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: Colors.grey.shade200,
              color: _getStatusColor(value),
              minHeight: 10,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$value%',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: _getStatusColor(value),
          ),
        ),
      ],
    );
  }

  /// Retorna a cor da barra de status baseada no valor
  Color _getStatusColor(int value) {
    if (value < 30) {
      return Colors.red;
    } else if (value < 60) {
      return Colors.orange;
    } else {
      return color;
    }
  }
}
