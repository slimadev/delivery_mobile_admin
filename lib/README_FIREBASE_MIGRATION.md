# Guia de Migração Firebase → API Repositories

## 📊 Status dos Repositórios vs APIs Disponíveis

### ✅ **APIs Completamente Cobertas por Repositórios:**

#### **Motoristas (Drivers)**
- ✅ `GET /api/drivers/vehicle-makers/` → `VehicleMakeRepository.getVehicleMakes()`
- ✅ `GET /api/drivers/vehicle-types/` → `VehicleTypeRepository.getVehicleTypes()`
- ✅ `POST /api/drivers/register-driver` → `DriverRepository.registerDriver()`
- ✅ `POST /api/drivers/activate-driver` → `DriverRepository.activateDriver()`

#### **Vendedores (Vendors)**
- ✅ `GET /api/vendors/products/by_session/{session_id}` → `VendorRepository.getProductsBySession()`
- ✅ `GET /api/vendors/products/category/{category_id}` → `VendorRepository.getProductsByCategory()`
- ✅ `GET /api/vendors/products/favorites` → `VendorRepository.getFavoriteProducts()`

#### **Pedidos (Orders)**
- ✅ `POST /api/orders/` → `OrderRepository.createOrder()`
- ✅ `GET /api/orders/{order_id}` → `OrderRepository.getOrderById()`
- ✅ `GET /api/orders/pending/` → `OrderRepository.getPendingOrders()`
- ✅ `GET /api/orders/pending/by/` → `OrderRepository.getPendingOrdersFiltered()`
- ✅ `PUT /api/orders/{order_id}/status/` → `OrderRepository.updateOrderStatus()`
- ✅ `POST /api/orders/{order_id}/assign-driver/` → `OrderRepository.assignDriverToOrder()`
- ✅ `POST /api/orders/driver/update-location/` → `LocationRepository.updateDriverLocation()`
- ✅ `GET /api/orders/drivers/nearby/` → `LocationRepository.getNearbyDrivers()`
- ✅ `GET /api/orders/{order_id}/driver/location/` → `LocationRepository.getDriverLocationFromOrder()`

## 🔄 **Funcionalidades Firebase que Podem ser Substituídas:**

### **1. Autenticação e Usuários**
**Firebase Auth** → **UserRepository**
```dart
// ANTES (Firebase)
await FirebaseAuth.instance.signInWithEmailAndPassword(email, password);

// DEPOIS (API)
await UserRepository.login(phone, password);
```

**Arquivos para migrar:**
- `lib/ui/login/LoginScreen.dart`
- `lib/ui/signUp/SignUpScreen.dart`
- `lib/ui/profile/ProfileScreen.dart`
- `lib/ui/accountDetails/AccountDetailsScreen.dart`

### **2. Pedidos e Entregas**
**Firebase Firestore** → **OrderRepository**
```dart
// ANTES (Firebase)
await FirebaseFirestore.instance.collection(ORDERS).doc(orderId).get();

// DEPOIS (API)
await OrderRepository.getOrderById(orderId);
```

**Arquivos para migrar:**
- `lib/ui/home/HomeScreen.dart`
- `lib/ui/ordersScreen/OrdersScreen.dart`
- `lib/ui/entrega/EntregaScreen.dart`
- `lib/ui/coleta/ColetaScreen.dart`

### **3. Localização e Motoristas**
**Firebase Realtime Database** → **LocationRepository**
```dart
// ANTES (Firebase)
await FirebaseDatabase.instance.ref('drivers/$driverId/location').set(locationData);

// DEPOIS (API)
await LocationRepository.updateDriverLocation(driverId, latitude, longitude);
```

**Arquivos para migrar:**
- `lib/services/LocationService.dart`
- `lib/ui/home/pick_order.dart`

### **4. Chat e Mensagens**
**Firebase Firestore** → **ChatRepository (a ser criado)**
```dart
// ANTES (Firebase)
await FirebaseFirestore.instance.collection('chat_driver').add(messageData);

// DEPOIS (API)
await ChatRepository.sendMessage(messageData);
```

**Arquivos para migrar:**
- `lib/ui/chat_screen/chat_screen.dart`
- `lib/ui/chat_screen/inbox_screen.dart`
- `lib/ui/chat/SupportChatScreen.dart`

### **5. Upload de Imagens**
**Firebase Storage** → **FileUploadRepository (a ser criado)**
```dart
// ANTES (Firebase)
await FireStoreUtils.uploadUserImageToFireStorage(image, uid);

// DEPOIS (API)
await FileUploadRepository.uploadImage(image, 'user');
```

**Arquivos para migrar:**
- `lib/ui/profile/ProfileScreen.dart`
- `lib/ui/accountDetails/AccountDetailsScreen.dart`

## 🚀 **Plano de Migração Sugerido:**

### **Fase 1: Autenticação (Prioridade Alta)**
1. Migrar login/logout
2. Migrar registro de usuários
3. Migrar recuperação de senha

### **Fase 2: Pedidos (Prioridade Alta)**
1. Migrar criação de pedidos
2. Migrar listagem de pedidos
3. Migrar atualização de status

### **Fase 3: Localização (Prioridade Média)**
1. Migrar atualização de localização
2. Migrar busca de motoristas próximos
3. Migrar tracking de entregas

### **Fase 4: Chat (Prioridade Baixa)**
1. Criar ChatRepository
2. Migrar mensagens
3. Migrar notificações

### **Fase 5: Upload (Prioridade Baixa)**
1. Criar FileUploadRepository
2. Migrar upload de imagens
3. Migrar upload de documentos

## 📝 **Repositórios que Precisam ser Criados:**

1. **ChatRepository** - Para mensagens e chat
2. **FileUploadRepository** - Para upload de arquivos
3. **NotificationRepository** - Para notificações push
4. **SessionRepository** - Para gerenciamento de sessões

## 🔧 **Configurações Necessárias:**

### **API Config**
```dart
// lib/config/api_config.dart
static const String chatBase = '/api/chat';
static const String fileUploadBase = '/api/upload';
static const String notificationsBase = '/api/notifications';
```

### **Modelos Necessários**
- `ChatMessage.dart`
- `NotificationModel.dart`
- `FileUploadResponse.dart`

## ⚠️ **Considerações Importantes:**

1. **Fallback para Firebase**: Manter Firebase como fallback durante a migração
2. **Testes**: Testar cada funcionalidade migrada antes de remover Firebase
3. **Performance**: Monitorar performance das APIs vs Firebase
4. **Offline**: Implementar cache local para funcionalidade offline
5. **Segurança**: Validar tokens e autenticação em todas as chamadas

## 📈 **Benefícios da Migração:**

1. **Controle Total**: Controle completo sobre dados e lógica
2. **Custos**: Redução de custos do Firebase
3. **Performance**: APIs otimizadas para seu caso de uso
4. **Escalabilidade**: Infraestrutura própria escalável
5. **Compliance**: Melhor controle sobre compliance e LGPD
