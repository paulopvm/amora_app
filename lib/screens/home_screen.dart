import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../widgets/couple_calendar.dart';

/// Tela inicial do aplicativo
/// 
/// Exibe informações sobre o casal e contador de tempo juntos
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  // Data de início do relacionamento: 23/03/2024
  final DateTime startDate = DateTime(2024, 3, 23);
  
  // Variáveis para o contador de tempo
  late Timer _timer;
  late String _timeTogetherText = '';
  
  // Variáveis para a animação do coração
  late AnimationController _heartAnimationController;
  late Animation<double> _heartSizeAnimation;
  late Animation<Color?> _heartColorAnimation;
  bool _isHeartAnimating = false;

  @override
  void initState() {
    super.initState();
    
    // Configurar a animação do coração
    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // Animação de tamanho (pulsar)
    _heartSizeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _heartAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Animação de cor (vermelho pulsante)
    _heartColorAnimation = ColorTween(
      begin: Colors.red,
      end: Colors.red.shade900,
    ).animate(CurvedAnimation(
      parent: _heartAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Adicionar listener para a animação
    _heartAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_isHeartAnimating) {
          _heartAnimationController.reset();
          _heartAnimationController.forward();
        }
      }
    });
    
    // Iniciar o timer para atualizar o contador de tempo
    _updateTimeTogetherText();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimeTogetherText();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _heartAnimationController.dispose();
    super.dispose();
  }

  /// Calcula e atualiza o texto do tempo juntos
  void _updateTimeTogetherText() {
    final now = DateTime.now();
    final difference = now.difference(startDate);
    
    // Calcular dias, meses e anos
    final days = difference.inDays;
    final months = (days / 30).floor(); // aproximação
    final years = (days / 365).floor(); // aproximação
    
    // Formatação
    final remainingMonths = months - (years * 12);
    final remainingDays = days - (months * 30);
    
    String timeText = '';
    
    if (years > 0) {
      timeText += '$years ${years == 1 ? 'ano' : 'anos'}';
      if (remainingMonths > 0 || remainingDays > 0) timeText += ', ';
    }
    
    if (remainingMonths > 0) {
      timeText += '$remainingMonths ${remainingMonths == 1 ? 'mês' : 'meses'}';
      if (remainingDays > 0) timeText += ' e ';
    }
    
    if (remainingDays > 0 || (years == 0 && remainingMonths == 0)) {
      timeText += '$remainingDays ${remainingDays == 1 ? 'dia' : 'dias'}';
    }
    
    setState(() {
      _timeTogetherText = timeText;
    });
  }

  /// Inicia ou para a animação do coração
  void _toggleHeartAnimation() {
    setState(() {
      _isHeartAnimating = !_isHeartAnimating;
      if (_isHeartAnimating) {
        _heartAnimationController.reset();
        _heartAnimationController.forward();
      } else {
        _heartAnimationController.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            
            // Card do casal
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    
                    // Título e coração animado
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Paulo & Mizukami',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _toggleHeartAnimation,
                          child: AnimatedBuilder(
                            animation: _heartAnimationController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _heartSizeAnimation.value,
                                child: Icon(
                                  Icons.favorite,
                                  size: 32,
                                  color: _isHeartAnimating
                                      ? _heartColorAnimation.value
                                      : Colors.red,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Data de início
                    Text(
                      'Juntos desde 23 de Março de 2024',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    
                    // Contador de tempo
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Tempo juntos:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _timeTogetherText,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Calendário do casal
            CoupleCalendar(
              relationshipStartDate: startDate,
              onDaySelected: (date, events) {
                // Manipular seleção de data (mockado)
              },
              onAddEvent: (date) {
                // Mostrar diálogo para adicionar evento (mockado)
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Adicionar evento em ${DateFormat('dd/MM/yyyy').format(date)}'),
                    content: const Text('Funcionalidade será implementada em breve!'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              onGoogleCalendarSync: () {
                // Integração com Google Calendar (mockado)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sincronização com Google Calendar será implementada'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Texto informativo
            Text(
              'Para Mizukami!',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
