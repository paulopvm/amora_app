import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../utils/validators.dart';
import '../../widgets/auth_button.dart';
import '../../widgets/auth_input_field.dart';
import '../../main.dart' show MainTabScreen;

/// Tela para vincular o parceiro (casal)
class PartnerInviteScreen extends StatefulWidget {
  const PartnerInviteScreen({Key? key}) : super(key: key);

  @override
  State<PartnerInviteScreen> createState() => _PartnerInviteScreenState();
}

class _PartnerInviteScreenState extends State<PartnerInviteScreen> with SingleTickerProviderStateMixin {
  final _inviteCodeController = TextEditingController();
  
  late TabController _tabController;
  bool _isGeneratingCode = false;
  bool _isLinkingPartner = false;
  String? _generatedCode;
  String? _errorMessage;
  bool _partnerLinked = false;
  String? _partnerName;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _inviteCodeController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _generateInviteCode() async {
    setState(() {
      _isGeneratingCode = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final code = await authService.generatePartnerInviteCode();
      
      if (mounted) {
        setState(() {
          _generatedCode = code;
        });
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ocorreu um erro ao gerar o código. Tente novamente.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingCode = false;
        });
      }
    }
  }

  Future<void> _linkPartner() async {
    if (_inviteCodeController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, insira o código de convite.';
      });
      return;
    }

    setState(() {
      _isLinkingPartner = true;
      _errorMessage = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = await authService.linkPartner(_inviteCodeController.text.trim());
      
      if (mounted) {
        setState(() {
          _partnerLinked = true;
          _partnerName = user.partnerName;
        });
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ocorreu um erro ao vincular o parceiro. Tente novamente.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLinkingPartner = false;
        });
      }
    }
  }

  void _copyCodeToClipboard() {
    if (_generatedCode != null) {
      Clipboard.setData(ClipboardData(text: _generatedCode!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código copiado para a área de transferência!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _continueToApp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainTabScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vincular Casal'),
        centerTitle: true,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _continueToApp,
            child: const Text('Pular'),
          ),
        ],
      ),
      body: SafeArea(
        child: _partnerLinked 
            ? _buildSuccessScreen() 
            : _buildInviteScreen(),
      ),
    );
  }

  Widget _buildInviteScreen() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Título e descrição
          Icon(
            Icons.favorite_rounded,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Vincule seu Relacionamento',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Conecte-se com seu parceiro para compartilhar momentos especiais',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Tabs para escolher opção
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(text: 'Gerar Código'),
              Tab(text: 'Inserir Código'),
            ],
          ),
          const SizedBox(height: 24),
          
          // Conteúdo das tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGenerateCodeTab(),
                _buildEnterCodeTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateCodeTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Gere um código único para convidar seu parceiro',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        
        // Código gerado
        if (_generatedCode != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Seu código de convite:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _generatedCode!,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                            letterSpacing: 2,
                          ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: _copyCodeToClipboard,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Compartilhe este código com seu parceiro para que ele possa se conectar com você no aplicativo.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
        
        // Botão para gerar código
        const Spacer(),
        if (_errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.error.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        AuthButton(
          text: _generatedCode == null 
              ? 'Gerar Código de Convite' 
              : 'Gerar Novo Código',
          onPressed: _generateInviteCode,
          isLoading: _isGeneratingCode,
          icon: Icons.badge,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEnterCodeTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Insira o código de convite que você recebeu',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        
        // Campo para inserir código
        AuthInputField(
          label: 'Código de Convite',
          hintText: 'Ex: 123456',
          controller: _inviteCodeController,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          onEditingComplete: _linkPartner,
          validator: Validators.validateInviteCode,
        ),
        
        // Mensagem de erro
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.error.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        
        const Spacer(),
        AuthButton(
          text: 'Vincular com Parceiro',
          onPressed: _linkPartner,
          isLoading: _isLinkingPartner,
          icon: Icons.favorite,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSuccessScreen() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.favorite,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Sucesso!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Você e ${_partnerName ?? 'seu parceiro'} estão conectados!',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Agora vocês podem compartilhar momentos especiais juntos no Amora.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          AuthButton(
            text: 'Continuar para o Aplicativo',
            onPressed: _continueToApp,
            icon: Icons.arrow_forward,
          ),
        ],
      ),
    );
  }
}
