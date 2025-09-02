# Sistema de Sessão - eMart Driver

## Visão Geral

Este sistema implementa persistência de sessão para manter o usuário logado no aplicativo eMart Driver, eliminando a necessidade de fazer login toda vez que o app é aberto.

## Funcionalidades

### ✅ **Persistência de Sessão**
- Salva automaticamente o usuário logado no dispositivo
- Recupera a sessão ao abrir o app
- Mantém o usuário logado até fazer logout manual

### ✅ **Múltiplos Métodos de Autenticação**
- **Email/Senha**: Login tradicional com email e senha
- **OTP**: Autenticação via código SMS
- **Telefone**: Login direto com número de telefone

### ✅ **Segurança**
- Sessão expira automaticamente após 30 dias
- Limpeza automática de dados ao fazer logout
- Compatibilidade com o sistema existente de autenticação

## Como Funciona

### 1. **Login**
Quando o usuário faz login com sucesso:
```dart
// O sistema automaticamente salva a sessão
await SessionService.saveUserSession(user);
```

### 2. **Verificação de Sessão**
Ao abrir o app, o sistema verifica se há uma sessão ativa:
```dart
if (await SessionService.isUserLoggedIn()) {
  User? savedUser = await SessionService.getUserSession();
  // Usuário já está logado, redireciona para a tela principal
}
```

### 3. **Logout**
Ao fazer logout, a sessão é limpa:
```dart
await SessionService.clearUserSession();
```

## Arquivos Implementados

### 📁 **Serviço de Sessão**
- `lib/services/session_service.dart` - Gerencia toda a lógica de sessão

### 📁 **Tela de Autenticação**
- `lib/ui/auth/AuthScreen.dart` - Nova tela com abas para diferentes métodos de login

### 📁 **Integração**
- `lib/main.dart` - Verificação de sessão ao iniciar o app
- Todas as telas de logout - Limpeza automática da sessão

## Uso do SessionService

### **Inicialização**
```dart
// No main.dart
await SessionService.init();
```

### **Salvar Sessão**
```dart
await SessionService.saveUserSession(user);
```

### **Verificar se Está Logado**
```dart
bool isLoggedIn = await SessionService.isUserLoggedIn();
```

### **Recuperar Usuário da Sessão**
```dart
User? user = await SessionService.getUserSession();
```

### **Atualizar Sessão**
```dart
await SessionService.updateUserSession(updatedUser);
```

### **Limpar Sessão (Logout)**
```dart
await SessionService.clearUserSession();
```

### **Verificar Validade da Sessão**
```dart
bool isValid = await SessionService.isSessionValid();
```

## Fluxo de Autenticação

```
App Inicia
    ↓
Verifica Sessão Salva
    ↓
┌─────────────────┬─────────────────┐
│   Sessão Válida │ Sem Sessão     │
│        ↓        │        ↓       │
│   Redireciona   │  Tela de Login │
│   para Home     │        ↓       │
│                 │   Usuário      │
│                 │   faz Login    │
│                 │        ↓       │
│                 │  Salva Sessão  │
│                 │        ↓       │
│                 │  Redireciona   │
│                 │  para Home     │
└─────────────────┴─────────────────┘
```

## Benefícios

### 🚀 **Experiência do Usuário**
- Não precisa fazer login toda vez
- Acesso rápido ao app
- Transição suave entre sessões

### 🔒 **Segurança**
- Sessão expira automaticamente
- Limpeza completa ao logout
- Dados criptografados no dispositivo

### 🛠️ **Desenvolvimento**
- Fácil de implementar
- Compatível com sistema existente
- Código limpo e organizado

## Configurações

### **Expiração de Sessão**
A sessão expira automaticamente após 30 dias. Para alterar:
```dart
// Em session_service.dart, linha ~100
if (daysSinceLogin > 30) { // Altere este valor
  await clearUserSession();
  return false;
}
```

### **Chaves de Armazenamento**
As chaves usadas no SharedPreferences são:
- `user_session` - Dados do usuário
- `is_logged_in` - Status de login
- `last_login_time` - Timestamp do último login

## Compatibilidade

### ✅ **Sistema Existente**
- Mantém compatibilidade com `UserPreference`
- Não quebra funcionalidades existentes
- Integra-se com Firebase Auth

### ✅ **Plataformas**
- Android
- iOS
- Web (se aplicável)

## Troubleshooting

### **Sessão Não Persiste**
1. Verifique se `SessionService.init()` foi chamado
2. Confirme permissões de armazenamento
3. Verifique logs de erro

### **Logout Não Funciona**
1. Verifique se `clearUserSession()` está sendo chamado
2. Confirme se todas as telas de logout foram atualizadas
3. Verifique logs de erro

### **Sessão Expira Prematuramente**
1. Verifique a configuração de expiração (30 dias)
2. Confirme se o timestamp está sendo salvo corretamente
3. Verifique logs de erro

## Logs

O sistema gera logs para debug:
```
Sessão do usuário salva com sucesso: user123
Sessão do usuário recuperada: user123
Sessão do usuário atualizada: user123
Sessão do usuário limpa com sucesso
```

## Contribuição

Para contribuir com melhorias:
1. Mantenha a compatibilidade com o sistema existente
2. Adicione logs para debug
3. Teste em diferentes cenários
4. Documente mudanças

## Licença

Este código faz parte do projeto eMart Driver e segue as mesmas políticas de licenciamento.




