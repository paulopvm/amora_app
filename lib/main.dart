import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/diary_screen.dart';
import 'screens/game_screen.dart';
import 'screens/pet_screen.dart';
import 'screens/settings_screen.dart';
import 'utils/calendar_utils.dart';

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
      home: const MainTabScreen(),
    );
  }
}

/// Tela principal com sistema de abas
class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  // Controlador para o PageView
  final PageController _pageController = PageController();
  
  // Índice da página atual
  int _selectedIndex = 0;
  
  // Lista de telas das abas
  final List<Widget> _screens = [
    const HomeScreen(),
    const DiaryScreen(),
    const GameScreen(),
    const PetScreen(),
    const SettingsScreen(),
  ];
  
  // Lista de ícones para a barra de navegação
  final List<IconData> _tabIcons = [
    Icons.favorite,
    Icons.book,
    Icons.quiz,
    Icons.pets,
    Icons.settings,
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Mudança de página através do bottom navigation bar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Animar para a página selecionada
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  // Mudança de página através do deslize
  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Amora'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(), // Para uma sensação de deslize suave
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _tabIcons.map((IconData icon) {
          return BottomNavigationBarItem(
            icon: Icon(icon),
            label: '', // Sem texto para design minimalista
          );
        }).toList(),
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        showSelectedLabels: false, // Não mostrar labels nem mesmo para o item selecionado
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
