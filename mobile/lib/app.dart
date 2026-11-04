import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'screens/splash_screen.dart';
import 'services/api_service.dart';
import 'services/token_store.dart';

class DeskFlowApp extends StatelessWidget {
  const DeskFlowApp({super.key, this.tokenStore});

  /// Testlerde sahte bir depo verilebilir; verilmezse gerçek şifreli depo kullanılır.
  final TokenStore? tokenStore;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
        Provider<TokenStore>(create: (_) => tokenStore ?? TokenStore()),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            context.read<ApiService>(),
            context.read<TokenStore>(),
          )..baslat(),
        ),
      ],
      child: MaterialApp(
        title: 'DeskFlow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _OturumYonlendirici(),
      ),
    );
  }
}

/// Oturum durumuna göre açılış, giriş ya da ana ekranı gösterir.
class _OturumYonlendirici extends StatelessWidget {
  const _OturumYonlendirici();

  @override
  Widget build(BuildContext context) {
    final durum = context.watch<AuthProvider>().durum;

    final Widget ekran = switch (durum) {
      OturumDurumu.baslatiliyor => const SplashScreen(),
      OturumDurumu.girisYapildi => const MainShell(),
      OturumDurumu.girisYapilmadi => const LoginScreen(),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: KeyedSubtree(key: ValueKey(durum), child: ekran),
    );
  }
}