import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/amora_pet.dart';
import '../widgets/pet_avatar.dart';
import '../widgets/pet_status_bar.dart';
import '../widgets/pet_mission_card.dart';

/// Tela principal do AmoraPet - o bichinho virtual do casal
class PetScreen extends StatefulWidget {
  const PetScreen({super.key});

  @override
  State<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen> with SingleTickerProviderStateMixin {
  // Pet inicial já personalizado (para MVP)
  late AmoraPet _pet;
  
  // Controlador para animações do pet
  late AnimationController _animationController;
  late Animation<double> _bounceAnimation;
  
  // Flag para controlar interações de carinho
  bool _isInteracting = false;
  
  // Lista de corações para animação de carinho
  final List<_HeartParticle> _hearts = [];
  
  @override
  void initState() {
    super.initState();
    
    // Criar o pet inicial
    _pet = AmoraPet.createDefaultPet();
    
    // Configurar animações
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _bounceAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
    
    // Iniciar animação inicial
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Função para alimentar o pet
  void _feedPet() {
    if (_pet.hungerLevel >= 100) {
      _showMessage("${_pet.name} já está alimentado!");
      return;
    }
    
    setState(() {
      _pet = _pet.copyWith(
        hungerLevel: math.min(100, _pet.hungerLevel + 15),
        lastInteraction: DateTime.now(),
        happinessPoints: math.min(100, _pet.happinessPoints + 5),
        experiencePoints: _pet.experiencePoints + 5,
      );
      
      _updatePetMood();
      _checkLevelUp();
    });
    
    _animationController.reset();
    _animationController.forward();
    
    _showMessage("${_pet.name} está comendo!");
  }
  
  // Função para limpar o pet
  void _cleanPet() {
    if (_pet.cleanlinessLevel >= 100) {
      _showMessage("${_pet.name} já está limpo!");
      return;
    }
    
    setState(() {
      _pet = _pet.copyWith(
        cleanlinessLevel: math.min(100, _pet.cleanlinessLevel + 20),
        lastInteraction: DateTime.now(),
        happinessPoints: math.min(100, _pet.happinessPoints + 5),
        experiencePoints: _pet.experiencePoints + 5,
      );
      
      _updatePetMood();
      _checkLevelUp();
    });
    
    _animationController.reset();
    _animationController.forward();
    
    _showMessage("${_pet.name} está tomando banho!");
  }
  
  // Função para dar carinho ao pet
  void _petPet() {
    setState(() {
      _isInteracting = true;
      _pet = _pet.copyWith(
        affectionLevel: math.min(100, _pet.affectionLevel + 10),
        lastInteraction: DateTime.now(),
        happinessPoints: math.min(100, _pet.happinessPoints + 10),
        experiencePoints: _pet.experiencePoints + 5,
      );
      
      // Adicionar corações para animação
      _addHeartParticles();
      
      _updatePetMood();
      _checkLevelUp();
    });
    
    _animationController.reset();
    _animationController.forward();
    
    _showMessage("${_pet.name} está feliz com o carinho!");
    
    // Parar interação após um tempo
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isInteracting = false;
          _hearts.clear();
        });
      }
    });
  }
  
  // Adiciona partículas de coração na animação
  void _addHeartParticles() {
    final random = math.Random();
    for (int i = 0; i < 5; i++) {
      _hearts.add(
        _HeartParticle(
          x: random.nextDouble() * 200 - 100,
          y: -50 - random.nextDouble() * 100,
          size: 15 + random.nextDouble() * 15,
          velocity: 2 + random.nextDouble() * 2,
        ),
      );
    }
  }
  
  // Verifica e atualiza o humor do pet com base nos status
  void _updatePetMood() {
    PetMood newMood;
    
    if (_pet.happinessPoints > 80) {
      newMood = PetMood.happy;
    } else if (_pet.needsAttention) {
      newMood = PetMood.sad;
    } else if (!_pet.isHealthy) {
      newMood = PetMood.sick;
    } else {
      newMood = PetMood.neutral;
    }
    
    if (newMood != _pet.mood) {
      setState(() {
        _pet = _pet.copyWith(mood: newMood);
      });
    }
  }
  
  // Verifica se o pet subiu de nível
  void _checkLevelUp() {
    if (_pet.experiencePoints >= _pet.experienceForNextLevel) {
      setState(() {
        _pet = _pet.copyWith(
          level: _pet.level + 1,
          experiencePoints: _pet.experiencePoints - _pet.experienceForNextLevel,
          happinessPoints: 100,
        );
      });
      
      _showMessage("${_pet.name} subiu para o nível ${_pet.level}!");
    }
  }
  
  // Mostra mensagem em um snackbar
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  // Abre a tela da loja (mockada para MVP)
  void _openShop() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Loja de Itens'),
        content: const SizedBox(
          width: 300,
          height: 200,
          child: Center(
            child: Text(
              'A loja de itens será implementada em breve!\n\nAqui você poderá comprar roupas, acessórios, comidas especiais e decorações para o seu AmoraPet.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  // Abre a tela de personalização (mockada para MVP)
  void _openCustomization() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Personalizar Pet'),
        content: const SizedBox(
          width: 300,
          height: 200,
          child: Center(
            child: Text(
              'A personalização do pet será implementada em breve!\n\nAqui você poderá alterar a aparência do seu AmoraPet.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  // Mostra detalhes da missão
  void _showMissionDetails(PetMission mission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(mission.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mission.description),
            const SizedBox(height: 16),
            Text('Recompensa: ${mission.rewardPoints} pontos'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
          if (!mission.completed)
            ElevatedButton(
              onPressed: () {
                // Para o MVP, simular a conclusão da missão
                setState(() {
                  final missionIndex = _pet.activeMissions.indexOf(mission);
                  final completedMission = mission.copyWith(
                    completed: true,
                    dateCompleted: DateTime.now(),
                  );
                  
                  final List<PetMission> newActiveMissions = List.from(_pet.activeMissions);
                  newActiveMissions.removeAt(missionIndex);
                  
                  final List<PetMission> newCompletedMissions = List.from(_pet.completedMissions)
                    ..add(completedMission);
                  
                  _pet = _pet.copyWith(
                    activeMissions: newActiveMissions,
                    completedMissions: newCompletedMissions,
                    experiencePoints: _pet.experiencePoints + mission.rewardPoints,
                    happinessPoints: math.min(100, _pet.happinessPoints + 20),
                    coins: _pet.coins + (mission.rewardPoints ~/ 2),
                  );
                  
                  _updatePetMood();
                  _checkLevelUp();
                });
                
                Navigator.of(context).pop();
                _showMessage('Missão completada! Parabéns!');
              },
              child: const Text('Completar'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Informações do pet
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Área principal com avatar do pet
                            SizedBox(
                              height: 250,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Animação de salto do pet
                                  AnimatedBuilder(
                                    animation: _bounceAnimation,
                                    builder: (context, child) {
                                      return Transform.translate(
                                        offset: Offset(0, math.sin(_bounceAnimation.value * math.pi) * 10),
                                        child: child,
                                      );
                                    },
                                    child: GestureDetector(
                                      onTap: _petPet,
                                      child: PetAvatar(
                                        pet: _pet,
                                        size: 180,
                                      ),
                                    ),
                                  ),
                                  
                                  // Animação de corações ao fazer carinho
                                  if (_isInteracting)
                                    ...List.generate(_hearts.length, (index) {
                                      final heart = _hearts[index];
                                      return Positioned(
                                        left: heart.x,
                                        bottom: heart.y,
                                        child: Icon(
                                          Icons.favorite,
                                          color: Colors.red.withOpacity(0.7),
                                          size: heart.size,
                                        ),
                                      );
                                    }),
                                ],
                              ),
                            ),
                            
                            // Nome e nível
                            Text(
                              '${_pet.name} - Nível ${_pet.level}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Progresso para o próximo nível
                            Row(
                              children: [
                                Text(
                                  'Próximo nível:',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: _pet.levelProgress,
                                      backgroundColor: Colors.grey.shade200,
                                      color: Theme.of(context).colorScheme.primary,
                                      minHeight: 8,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${_pet.experiencePoints}/${_pet.experienceForNextLevel}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Barras de status
                            PetStatusBar(
                              label: 'Fome',
                              value: _pet.hungerLevel,
                              icon: Icons.restaurant,
                              color: Colors.orange,
                            ),
                            
                            const SizedBox(height: 8),
                            
                            PetStatusBar(
                              label: 'Limpeza',
                              value: _pet.cleanlinessLevel,
                              icon: Icons.shower,
                              color: Colors.blue,
                            ),
                            
                            const SizedBox(height: 8),
                            
                            PetStatusBar(
                              label: 'Carinho',
                              value: _pet.affectionLevel,
                              icon: Icons.favorite,
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Botões de ação
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          icon: Icons.restaurant,
                          label: 'Alimentar',
                          color: Colors.orange,
                          onTap: _feedPet,
                        ),
                        _buildActionButton(
                          icon: Icons.shower,
                          label: 'Limpar',
                          color: Colors.blue,
                          onTap: _cleanPet,
                        ),
                        _buildActionButton(
                          icon: Icons.favorite,
                          label: 'Carinho',
                          color: Colors.red,
                          onTap: _petPet,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Botões adicionais
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          icon: Icons.shopping_bag,
                          label: 'Loja',
                          color: Colors.green,
                          onTap: _openShop,
                        ),
                        _buildActionButton(
                          icon: Icons.brush,
                          label: 'Personalizar',
                          color: Colors.purple,
                          onTap: _openCustomization,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Missões disponíveis
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Missões de Conexão',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    if (_pet.activeMissions.isEmpty)
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              'Não há missões disponíveis no momento.',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      )
                    else
                      ...List.generate(_pet.activeMissions.length, (index) {
                        final mission = _pet.activeMissions[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: PetMissionCard(
                            mission: mission,
                            onTap: () => _showMissionDetails(mission),
                          ),
                        );
                      }),
                    
                    const SizedBox(height: 16),
                    
                    // Missões completadas
                    if (_pet.completedMissions.isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Missões Completadas',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      ...List.generate(_pet.completedMissions.length, (index) {
                        final mission = _pet.completedMissions[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: PetMissionCard(
                            mission: mission,
                            onTap: () => _showMissionDetails(mission),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Classe para efeito de partículas de coração
class _HeartParticle {
  double x;
  double y;
  final double size;
  final double velocity;
  
  _HeartParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.velocity,
  });
}
