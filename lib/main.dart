import 'package:flutter/material.dart';

/// Aplicativo Amora - Ponto de entrada principal do aplicativo
void main() {
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
      title: 'Amora App',
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
/// Exibe uma mensagem de boas-vindas simples com a identidade visual do Amora
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: const Text('Amora App'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo ou ícone representativo
            Icon(
              Icons.eco_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            // Texto de boas-vindas
            Text(
              'Bem-vindo ao Amora App!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Mensagem de Hello World
            Text(
              'Hello World',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 48),
            // Botão de exemplo com feedback visual
            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bem-vindo ao projeto Amora!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.waving_hand),
              label: const Text('Diga Olá'),
            ),
          ],
        ),
      ),
    );
  }
}
