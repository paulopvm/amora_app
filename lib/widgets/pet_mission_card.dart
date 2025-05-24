import 'package:flutter/material.dart';
import '../models/amora_pet.dart';

/// Widget para exibir uma missão do AmoraPet em formato de cartão
class PetMissionCard extends StatelessWidget {
  final PetMission mission;
  final VoidCallback onTap;

  const PetMissionCard({
    super.key,
    required this.mission,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: mission.completed
            ? BorderSide(color: Colors.green.shade300, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _buildMissionIcon(context),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: mission.completed
                            ? TextDecoration.lineThrough
                            : null,
                        color: mission.completed
                            ? Colors.grey
                            : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mission.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: mission.completed
                            ? Colors.grey
                            : Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '+${mission.rewardPoints}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  if (mission.completed)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói o ícone da missão com base no tipo
  Widget _buildMissionIcon(BuildContext context) {
    IconData icon;
    Color color;

    switch (mission.type) {
      case MissionType.tellSecret:
        icon = Icons.visibility_off;
        color = Colors.indigo;
        break;
      case MissionType.planDate:
        icon = Icons.event;
        color = Colors.red;
        break;
      case MissionType.compliment:
        icon = Icons.favorite;
        color = Colors.pink;
        break;
      case MissionType.sendSelfie:
        icon = Icons.camera_alt;
        color = Colors.blue;
        break;
      case MissionType.memory:
        icon = Icons.photo_album;
        color = Colors.amber;
        break;
      case MissionType.activity:
        icon = Icons.directions_run;
        color = Colors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }
}
