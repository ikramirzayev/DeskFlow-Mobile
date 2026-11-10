import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/router.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'services/api_service.dart';
import 'services/token_store.dart';

class DeskFlowApp extends StatelessWidget {
  const DeskFlowApp({super.key, this.tokenStore, this.apiService});

  /// Testlerde sahte bir depo verilebilir; verilmezse gerçek şifreli depo kullanılır.
  final TokenStore? tokenStore;

  /// Testlerde sahte cevap dönen bir API servisi verilebilir.
  final ApiService? apiService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => apiService ?? ApiService()),
        Provider<TokenStore>(create: (_) => tokenStore ?? TokenStore()),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            context.read<ApiService>(),
            context.read<TokenStore>(),
          )..baslat(),
        ),
      ],
      child: const _Uygulama(),
    );
  }
}

class _Uygulama extends StatefulWidget {
  const _Uygulama();

  @override
  State<_Uygulama> createState() => _UygulamaState();
}

class _UygulamaState extends State<_Uygulama> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = routerOlustur(context.read<AuthProvider>());
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DeskFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
    );
  }
}
