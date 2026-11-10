import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../providers/auth_provider.dart";
import "home_screen.dart";
import "profile_screen.dart";
import "yonetim_screen.dart";

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final yoneticiMi = context.watch<AuthProvider>().yoneticiMi;

    // Yönetim sekmesi sadece yöneticiye eklenir.
    final sayfalar = <Widget>[
      const HomeScreen(),
      Scaffold(
        appBar: AppBar(title: const Text("Rezervasyonlarım")),
        body: const Center(child: Text("yakında")),
      ),
      if (yoneticiMi) const YonetimScreen(),
      const ProfileScreen(),
    ];

    final sekmeler = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: "Ana Sayfa",
      ),
      const NavigationDestination(
        icon: Icon(Icons.event_seat_outlined),
        selectedIcon: Icon(Icons.event_seat),
        label: "Rezervasyonlarım",
      ),
      if (yoneticiMi)
        const NavigationDestination(
          icon: Icon(Icons.admin_panel_settings_outlined),
          selectedIcon: Icon(Icons.admin_panel_settings),
          label: "Yönetim",
        ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: "Profil",
      ),
    ];

    final index = _index.clamp(0, sayfalar.length - 1);

    return Scaffold(
      body: sayfalar[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: sekmeler,
      ),
    );
  }
}
