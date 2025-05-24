import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'utils/calendar_utils.dart';
import 'widgets/couple_calendar.dart';

/// Aplicativo Amora - Ponto de entrada principal do aplicativo
void main() async {
  // Inicializar locale para o calendário
  await initializeCalendarLocale();
  runApp(const AmoraApp());
}

/// Widget raiz do aplicativo Amora
/// 
/// Define a estrutura básica do aplicativo, incluindo temas e rotas iniciais
class AmoraApp extends StatelessWidget {
  const AmoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8E44AD), // Cor roxa similar à amora
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8E44AD),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}

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
      timeText += '$years ${years == 1 ? 'ano' : 'anos'}, ';
    }
    
    if (months > 0) {
      timeText += '${remainingMonths > 0 ? remainingMonths : months} ${(remainingMonths > 0 ? remainingMonths : months) == 1 ? 'mês' : 'meses'}, ';
    }
    
    timeText += '${remainingDays > 0 ? remainingDays : days} ${(remainingDays > 0 ? remainingDays : days) == 1 ? 'dia' : 'dias'}';
    
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: const Text('Amora'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Ícone do app
                Icon(
                  Icons.favorite,
                  size: 60,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 30),
                
                // Card principal com informações do casal
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        // Nomes do casal com coração animado no meio
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Paulo',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                            const SizedBox(width: 10),
                            // Coração animado
                            GestureDetector(
                              onTap: _toggleHeartAnimation,
                              child: AnimatedBuilder(
                                animation: _heartAnimationController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _heartSizeAnimation.value,
                                    child: Icon(
                                      Icons.favorite,
                                      color: _isHeartAnimating 
                                          ? _heartColorAnimation.value 
                                          : Colors.red,
                                      size: 32,
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Duda',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
