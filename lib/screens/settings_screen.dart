import 'package:flutter/material.dart';

/// Tela de configurações do aplicativo
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Center(
              child: Icon(
                Icons.settings,
                size: 64,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Configurações',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
            const SizedBox(height: 30),
            
            _buildSectionTitle(context, 'Preferências de conta'),
            const SizedBox(height: 8),
            _buildSettingItem(
              context, 
              'Dados do perfil',
              Icons.person,
              () => _showComingSoonMessage(context),
            ),
            _buildSettingItem(
              context, 
              'Data do relacionamento',
              Icons.calendar_today,
              () => _showComingSoonMessage(context),
            ),
            
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Notificações'),
            const SizedBox(height: 8),
            _buildSwitchItem(
              context,
              'Notificações push',
              Icons.notifications,
              true,
              (value) {},
            ),
            _buildSwitchItem(
              context,
              'Lembretes de datas',
              Icons.event_note,
              true,
              (value) {},
            ),
            
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Aparência'),
            const SizedBox(height: 8),
            _buildSettingItem(
              context, 
              'Tema do aplicativo',
              Icons.color_lens,
              () => _showComingSoonMessage(context),
            ),
            
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Sobre'),
            const SizedBox(height: 8),
            _buildSettingItem(
              context, 
              'Sobre o aplicativo',
              Icons.info,
              () => _showComingSoonMessage(context),
            ),
            _buildSettingItem(
              context, 
              'Termos de uso',
              Icons.description,
              () => _showComingSoonMessage(context),
            ),
            
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Funcionalidade em desenvolvimento!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sair'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }
  
  Widget _buildSettingItem(
    BuildContext context, 
    String title, 
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
  
  Widget _buildSwitchItem(
    BuildContext context, 
    String title, 
    IconData icon,
    bool initialValue,
    Function(bool) onChanged,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        secondary: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        value: initialValue,
        onChanged: (value) {
          onChanged(value);
          _showComingSoonMessage(context);
        },
      ),
    );
  }
  
  void _showComingSoonMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade em desenvolvimento!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
