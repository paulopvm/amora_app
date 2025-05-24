

/// Tipos de pet disponíveis para seleção
enum PetType {
  cat,
  dog,
  rabbit,
  bird,
  hamster,
}

/// Cores disponíveis para personalização do pet
enum PetColor {
  pink,
  blue,
  green,
  yellow,
  purple,
}

/// Emoções que o pet pode expressar
enum PetMood {
  happy,
  sad,
  excited,
  sick,
  neutral,
}

/// Tipos de missões para o casal
enum MissionType {
  tellSecret,
  planDate,
  compliment,
  sendSelfie,
  memory,
  activity,
}

/// Modelo para missões de conexão
class PetMission {
  final String title;
  final String description;
  final MissionType type;
  final int rewardPoints;
  final bool completed;
  final DateTime? dateCompleted;

  PetMission({
    required this.title,
    required this.description,
    required this.type,
    required this.rewardPoints,
    this.completed = false,
    this.dateCompleted,
  });

  PetMission copyWith({
    String? title,
    String? description,
    MissionType? type,
    int? rewardPoints,
    bool? completed,
    DateTime? dateCompleted,
  }) {
    return PetMission(
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      completed: completed ?? this.completed,
      dateCompleted: dateCompleted ?? this.dateCompleted,
    );
  }
}

/// Item que pode ser comprado na loja para o pet
class PetItem {
  final String id;
  final String name;
  final String description;
  final String assetPath;
  final int price;
  final ItemType type;
  final bool purchased;
  final bool equipped;

  PetItem({
    required this.id,
    required this.name,
    required this.description,
    required this.assetPath,
    required this.price,
    required this.type,
    this.purchased = false,
    this.equipped = false,
  });

  PetItem copyWith({
    String? id,
    String? name,
    String? description,
    String? assetPath,
    int? price,
    ItemType? type,
    bool? purchased,
    bool? equipped,
  }) {
    return PetItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      assetPath: assetPath ?? this.assetPath,
      price: price ?? this.price,
      type: type ?? this.type,
      purchased: purchased ?? this.purchased,
      equipped: equipped ?? this.equipped,
    );
  }
}

/// Tipos de itens disponíveis na loja
enum ItemType {
  clothing,
  accessory,
  food,
  background,
}

/// Modelo para o AmoraPet
class AmoraPet {
  final String name;
  final PetType type;
  final PetColor color;
  final PetMood mood;
  final int level;
  final int experiencePoints;
  final int happinessPoints;
  final int hungerLevel; // 0-100 (0 = fome total, 100 = alimentado)
  final int cleanlinessLevel; // 0-100 (0 = sujo, 100 = limpo)
  final int affectionLevel; // 0-100 (0 = carente, 100 = afetuoso)
  final List<PetItem> inventory;
  final List<PetItem> equippedItems;
  final DateTime lastInteraction;
  final DateTime createdAt;
  final List<PetMission> activeMissions;
  final List<PetMission> completedMissions;
  final int coins;

  AmoraPet({
    required this.name,
    required this.type,
    required this.color,
    this.mood = PetMood.happy,
    this.level = 1,
    this.experiencePoints = 0,
    this.happinessPoints = 80,
    this.hungerLevel = 80,
    this.cleanlinessLevel = 80,
    this.affectionLevel = 80,
    this.inventory = const [],
    this.equippedItems = const [],
    DateTime? lastInteraction,
    DateTime? createdAt,
    this.activeMissions = const [],
    this.completedMissions = const [],
    this.coins = 0,
  }) : 
    lastInteraction = lastInteraction ?? DateTime.now(),
    createdAt = createdAt ?? DateTime.now();

  /// Cria uma cópia do AmoraPet com valores atualizados
  AmoraPet copyWith({
    String? name,
    PetType? type,
    PetColor? color,
    PetMood? mood,
    int? level,
    int? experiencePoints,
    int? happinessPoints,
    int? hungerLevel,
    int? cleanlinessLevel,
    int? affectionLevel,
    List<PetItem>? inventory,
    List<PetItem>? equippedItems,
    DateTime? lastInteraction,
    DateTime? createdAt,
    List<PetMission>? activeMissions,
    List<PetMission>? completedMissions,
    int? coins,
  }) {
    return AmoraPet(
      name: name ?? this.name,
      type: type ?? this.type,
      color: color ?? this.color,
      mood: mood ?? this.mood,
      level: level ?? this.level,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      happinessPoints: happinessPoints ?? this.happinessPoints,
      hungerLevel: hungerLevel ?? this.hungerLevel,
      cleanlinessLevel: cleanlinessLevel ?? this.cleanlinessLevel,
      affectionLevel: affectionLevel ?? this.affectionLevel,
      inventory: inventory ?? this.inventory,
      equippedItems: equippedItems ?? this.equippedItems,
      lastInteraction: lastInteraction ?? this.lastInteraction,
      createdAt: createdAt ?? this.createdAt,
      activeMissions: activeMissions ?? this.activeMissions,
      completedMissions: completedMissions ?? this.completedMissions,
      coins: coins ?? this.coins,
    );
  }

  /// Verifica se o pet precisa de cuidados
  bool get needsAttention => 
    hungerLevel < 30 || cleanlinessLevel < 30 || affectionLevel < 30;

  /// Retorna se o pet está saudável
  bool get isHealthy => 
    hungerLevel > 50 && cleanlinessLevel > 50 && affectionLevel > 50;

  /// Experiência necessária para o próximo nível
  int get experienceForNextLevel => level * 100;

  /// Progresso percentual para o próximo nível
  double get levelProgress => 
    experiencePoints / experienceForNextLevel;

  /// Criação de um AmoraPet inicial personalizado para o MVP
  static AmoraPet createDefaultPet() {
    return AmoraPet(
      name: 'Amorinha',
      type: PetType.cat,
      color: PetColor.purple,
      lastInteraction: DateTime.now(),
      mood: PetMood.happy,
      level: 1,
      experiencePoints: 0,
      happinessPoints: 85,
      hungerLevel: 90,
      cleanlinessLevel: 90,
      affectionLevel: 90,
      inventory: [
        PetItem(
          id: 'hat_01',
          name: 'Chapéu de Festa',
          description: 'Um chapéu colorido para celebrar o relacionamento',
          assetPath: 'assets/items/hat_01.png',
          price: 50,
          type: ItemType.accessory,
          purchased: true,
          equipped: true,
        ),
      ],
      equippedItems: [
        PetItem(
          id: 'hat_01',
          name: 'Chapéu de Festa',
          description: 'Um chapéu colorido para celebrar o relacionamento',
          assetPath: 'assets/items/hat_01.png',
          price: 50,
          type: ItemType.accessory,
          purchased: true,
          equipped: true,
        ),
      ],
      activeMissions: [
        PetMission(
          title: 'Conte um segredo',
          description: 'Compartilhe um segredo com seu parceiro que você nunca contou antes',
          type: MissionType.tellSecret,
          rewardPoints: 50,
        ),
        PetMission(
          title: 'Selfie Sorridente',
          description: 'Tirem uma selfie juntos sorrindo e guardem na galeria do app',
          type: MissionType.sendSelfie,
          rewardPoints: 30,
        ),
      ],
      completedMissions: [],
      coins: 100,
    );
  }
}
