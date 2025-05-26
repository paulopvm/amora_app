import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

/// Exceção personalizada para erros de autenticação
class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException(this.message, {this.code});

  @override
  String toString() => 'AuthException: $message (code: $code)';
}

/// Serviço responsável pela autenticação e gerenciamento de usuários
class AuthService extends ChangeNotifier {
  // Chaves para armazenamento seguro
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';
  static const String _lastLoginTimestampKey = 'last_login_timestamp';
  static const String _loginAttemptsKey = 'login_attempts';
  
  // Limite de tentativas de login
  static const int _maxLoginAttempts = 5;
  
  // Tempo de expiração do token em horas
  static const int _tokenExpiryHours = 24;
  
  // Instâncias para armazenamento seguro
  final _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;
  
  // Estado da autenticação
  User? _currentUser;
  String? _token;
  bool _isLoading = true;
  
  // Getters para acessar o estado
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _token != null && _currentUser != null;
  bool get isLoading => _isLoading;
  
  // Construtor e inicialização
  AuthService() {
    _initialize();
  }
  
  /// Inicializa o serviço de autenticação
  Future<void> _initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadStoredAuth();
    } catch (e) {
      debugPrint('Erro ao inicializar AuthService: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Carrega dados de autenticação armazenados localmente
  Future<void> _loadStoredAuth() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      if (token != null) {
        final userJson = await _secureStorage.read(key: _userKey);
        if (userJson != null) {
          _token = token;
          _currentUser = User.fromJson(jsonDecode(userJson));
          
          // Verificar expiração do token
          if (_isTokenExpired()) {
            await logout();
          }
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados de autenticação: $e');
      await logout();
    }
  }
  
  /// Verifica se o token está expirado
  bool _isTokenExpired() {
    final lastLoginStr = _prefs?.getString(_lastLoginTimestampKey);
    if (lastLoginStr != null) {
      final lastLogin = DateTime.parse(lastLoginStr);
      final now = DateTime.now();
      final difference = now.difference(lastLogin).inHours;
      return difference >= _tokenExpiryHours;
    }
    return true;
  }
  
  /// Realiza login do usuário
  Future<User> login(String email, String password) async {
    try {
      // Verificar tentativas de login
      final attempts = _prefs?.getInt(_loginAttemptsKey) ?? 0;
      if (attempts >= _maxLoginAttempts) {
        final lastAttemptStr = _prefs?.getString(_lastLoginTimestampKey);
        if (lastAttemptStr != null) {
          final lastAttempt = DateTime.parse(lastAttemptStr);
          final now = DateTime.now();
          final cooldownMinutes = now.difference(lastAttempt).inMinutes;
          
          if (cooldownMinutes < 30) {
            throw AuthException(
              'Muitas tentativas de login. Tente novamente em ${30 - cooldownMinutes} minutos.',
              code: 'too-many-requests'
            );
          } else {
            // Resetar contador após 30 minutos
            await _prefs?.setInt(_loginAttemptsKey, 0);
          }
        }
      }
      
      // Verificar credenciais
      if (email == 'pvm@email.com' && password == 'Xc!s+0?s') {
        // Simulação de autenticação bem-sucedida
        final user = User(
          id: '1',
          name: 'Paulo Victor',
          email: email,
          isEmailVerified: true,
          emailVerifiedAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        
        _currentUser = user;
        _token = _generateToken();
        
        // Armazenar dados de autenticação
        await _secureStorage.write(key: _tokenKey, value: _token);
        await _secureStorage.write(key: _userKey, value: jsonEncode(user.toJson()));
        await _prefs?.setString(_lastLoginTimestampKey, DateTime.now().toIso8601String());
        await _prefs?.setInt(_loginAttemptsKey, 0);
        
        notifyListeners();
        return user;
      } else {
        // Incrementar tentativas de login
        await _prefs?.setInt(_loginAttemptsKey, (attempts + 1));
        await _prefs?.setString(_lastLoginTimestampKey, DateTime.now().toIso8601String());
        
        throw AuthException(
          'Email ou senha incorretos.',
          code: 'invalid-credentials'
        );
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException(
        'Ocorreu um erro durante o login. Tente novamente.',
        code: 'unknown-error'
      );
    }
  }
  
  /// Registra um novo usuário
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Validar formato de email
      final emailRegex = RegExp(r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$');
      if (!emailRegex.hasMatch(email)) {
        throw AuthException('Email inválido.', code: 'invalid-email');
      }
      
      // Validar senha
      if (password.length < 8) {
        throw AuthException(
          'A senha deve ter pelo menos 8 caracteres.',
          code: 'weak-password'
        );
      }
      
      if (!password.contains(RegExp(r'[A-Za-z]')) || 
          !password.contains(RegExp(r'[0-9]'))) {
        throw AuthException(
          'A senha deve conter letras e números.',
          code: 'weak-password'
        );
      }
      
      // Apenas permitir o cadastro do usuário mockado
      if (email == 'pvm@email.com') {
        // Simulação de registro bem-sucedido
        final user = User(
          id: '1',
          name: name,
          email: email,
          isEmailVerified: false,
        );
        
        _currentUser = user;
        _token = _generateToken();
        
        // Armazenar dados de autenticação
        await _secureStorage.write(key: _tokenKey, value: _token);
        await _secureStorage.write(key: _userKey, value: jsonEncode(user.toJson()));
        await _prefs?.setString(_lastLoginTimestampKey, DateTime.now().toIso8601String());
        
        // Simular envio de email de verificação
        await _sendVerificationEmail();
        
        notifyListeners();
        return user;
      } else {
        throw AuthException(
          'Este email não está disponível para cadastro.',
          code: 'email-already-in-use'
        );
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException(
        'Ocorreu um erro durante o registro. Tente novamente.',
        code: 'unknown-error'
      );
    }
  }
  
  /// Envia email de recuperação de senha
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      // Validar formato de email
      final emailRegex = RegExp(r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$');
      if (!emailRegex.hasMatch(email)) {
        throw AuthException('Email inválido.', code: 'invalid-email');
      }
      
      // Simular envio de email
      // Não verificamos se o email existe para evitar vazamento de informação
      // Retornamos sucesso em todos os casos
      await Future.delayed(const Duration(seconds: 1));
      return;
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException(
        'Ocorreu um erro ao enviar o email. Tente novamente.',
        code: 'unknown-error'
      );
    }
  }
  
  /// Vincula usuário ao parceiro pelo código de convite
  Future<User> linkPartner(String inviteCode) async {
    try {
      if (_currentUser == null) {
        throw AuthException(
          'Usuário não autenticado.',
          code: 'unauthenticated'
        );
      }
      
      // Validar código de convite
      if (inviteCode.length != 6) {
        throw AuthException(
          'Código de convite inválido.',
          code: 'invalid-code'
        );
      }
      
      // Simulação de vinculação bem-sucedida
      if (inviteCode == '123456') {
        final updatedUser = _currentUser!.copyWith(
          partnerId: '2',
          partnerName: 'Partner Name',
          partnerCode: inviteCode,
        );
        
        _currentUser = updatedUser;
        
        // Atualizar dados armazenados
        await _secureStorage.write(key: _userKey, value: jsonEncode(updatedUser.toJson()));
        
        notifyListeners();
        return updatedUser;
      } else {
        throw AuthException(
          'Código de convite inválido ou expirado.',
          code: 'invalid-code'
        );
      }
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException(
        'Ocorreu um erro ao vincular o parceiro. Tente novamente.',
        code: 'unknown-error'
      );
    }
  }
  
  /// Gera código de convite para o parceiro
  Future<String> generatePartnerInviteCode() async {
    try {
      if (_currentUser == null) {
        throw AuthException(
          'Usuário não autenticado.',
          code: 'unauthenticated'
        );
      }
      
      // Simular geração de código de convite
      final random = Random();
      final code = List.generate(6, (_) => random.nextInt(10)).join();
      
      // Atualizar usuário com o código gerado
      final updatedUser = _currentUser!.copyWith(partnerCode: code);
      _currentUser = updatedUser;
      
      // Atualizar dados armazenados
      await _secureStorage.write(key: _userKey, value: jsonEncode(updatedUser.toJson()));
      
      notifyListeners();
      return code;
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException(
        'Ocorreu um erro ao gerar o código de convite. Tente novamente.',
        code: 'unknown-error'
      );
    }
  }
  
  /// Realiza logout do usuário
  Future<void> logout() async {
    try {
      _token = null;
      _currentUser = null;
      
      // Limpar dados de autenticação
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _userKey);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao fazer logout: $e');
    }
  }
  
  /// Simular envio de email de verificação
  Future<void> _sendVerificationEmail() async {
    if (_currentUser == null) return;
    
    // Simular envio de email
    await Future.delayed(const Duration(seconds: 1));
    
    // Atualizar usuário com verificação de email
    final updatedUser = _currentUser!.copyWith(
      isEmailVerified: true,
      emailVerifiedAt: DateTime.now(),
    );
    
    _currentUser = updatedUser;
    
    // Atualizar dados armazenados
    await _secureStorage.write(key: _userKey, value: jsonEncode(updatedUser.toJson()));
    
    notifyListeners();
  }
  
  /// Gera um token JWT mock
  String _generateToken() {
    final header = base64Encode(utf8.encode(jsonEncode({
      'alg': 'HS256',
      'typ': 'JWT'
    })));
    
    final payload = base64Encode(utf8.encode(jsonEncode({
      'sub': _currentUser?.id,
      'email': _currentUser?.email,
      'name': _currentUser?.name,
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': DateTime.now().add(Duration(hours: _tokenExpiryHours)).millisecondsSinceEpoch ~/ 1000,
    })));
    
    final signature = base64Encode(utf8.encode('mock_signature'));
    
    return '$header.$payload.$signature';
  }
}
