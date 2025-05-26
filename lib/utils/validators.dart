/// Utilitário para validação de campos de formulário
class Validators {
  /// Valida um email usando uma expressão regular
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira um email';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$');
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor, insira um email válido';
    }
    
    return null;
  }

  /// Valida uma senha com base nos requisitos de segurança
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira uma senha';
    }
    
    if (value.length < 8) {
      return 'A senha deve ter pelo menos 8 caracteres';
    }
    
    if (!value.contains(RegExp(r'[A-Za-z]'))) {
      return 'A senha deve conter pelo menos uma letra';
    }
    
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'A senha deve conter pelo menos um número';
    }
    
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'A senha deve conter pelo menos um caractere especial';
    }
    
    return null;
  }

  /// Valida a confirmação de senha
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Por favor, confirme sua senha';
    }
    
    if (value != password) {
      return 'As senhas não coincidem';
    }
    
    return null;
  }

  /// Valida um nome
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira seu nome';
    }
    
    if (value.length < 3) {
      return 'O nome deve ter pelo menos 3 caracteres';
    }
    
    return null;
  }

  /// Valida um código de convite
  static String? validateInviteCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira o código de convite';
    }
    
    if (value.length != 6) {
      return 'O código de convite deve ter 6 caracteres';
    }
    
    return null;
  }
}
