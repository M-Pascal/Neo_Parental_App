import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_strings.dart';
import '../widgets/common_widgets.dart';
import 'home_screen.dart';
import '../Screens/record.dart';
import '../Screens/history.dart';
import '../Screens/chat.dart';
import '../Screens/profile.dart';
import 'welcome_screen.dart';

/// Main navigation screen with bottom navigation bar
class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navProvider, _) {
        return Scaffold(
          backgroundColor: AppColors.white,
          drawer: _buildDrawer(context),
          appBar: _shouldShowAppBar(navProvider.selectedIndex)
              ? _buildAppBar(context)
              : null,
          body: _getPage(navProvider.selectedIndex),
          bottomNavigationBar: _buildBottomNavigationBar(context, navProvider),
        );
      },
    );
  }

  bool _shouldShowAppBar(int index) {
    // Don't show app bar for Record (1), History (2), and Chat (3) pages
    return index == 0;
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(
            Icons.menu_rounded,
            color: AppColors.black,
            size: 28,
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: AppColors.black,
            size: 26,
          ),
          onPressed: () => showSnackBar(context, 'Notifications'),
        ),
        IconButton(
          icon: const Icon(
            Icons.person_outline,
            color: AppColors.black,
            size: 26,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const RecordPage();
      case 2:
        return const HistoryPage();
      case 3:
        return const ChatPage();
      default:
        return const HomeScreen();
    }
  }

  Widget _buildBottomNavigationBar(
    BuildContext context,
    NavigationProvider navProvider,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context,
            icon: Icons.home,
            label: AppStrings.home,
            index: 0,
            isSelected: navProvider.selectedIndex == 0,
            onTap: () => navProvider.setSelectedIndex(0),
          ),
          _buildNavItem(
            context,
            icon: Icons.hearing,
            label: AppStrings.audio,
            index: 1,
            isSelected: navProvider.selectedIndex == 1,
            onTap: () => navProvider.setSelectedIndex(1),
          ),
          _buildNavItem(
            context,
            icon: Icons.history,
            label: AppStrings.history,
            index: 2,
            isSelected: navProvider.selectedIndex == 2,
            onTap: () => navProvider.setSelectedIndex(2),
          ),
          _buildNavItem(
            context,
            icon: Icons.chat,
            label: AppStrings.chat,
            index: 3,
            isSelected: navProvider.selectedIndex == 3,
            onTap: () => navProvider.setSelectedIndex(3),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryLight : AppColors.white,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primaryLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(gradient: AppColors.primaryGradient),
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.transparent),
              child: Center(
                child: Text(
                  AppStrings.appName,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(context, Icons.home, AppStrings.home, () {
                    Navigator.pop(context);
                    context.read<NavigationProvider>().navigateToHome();
                  }),
                  _buildMenuItem(context, Icons.mic, AppStrings.audio, () {
                    Navigator.pop(context);
                    context.read<NavigationProvider>().navigateToAudio();
                  }),
                  _buildMenuItem(
                    context,
                    Icons.history,
                    AppStrings.history,
                    () {
                      Navigator.pop(context);
                      context.read<NavigationProvider>().navigateToHistory();
                    },
                  ),
                  _buildMenuItem(context, Icons.chat, AppStrings.chat, () {
                    Navigator.pop(context);
                    context.read<NavigationProvider>().navigateToChat();
                  }),
                  _buildMenuItem(context, Icons.person, AppStrings.profile, () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    );
                  }),
                  const Divider(color: Colors.white30),
                  _buildMenuItem(
                    context,
                    Icons.logout,
                    AppStrings.logout,
                    () async {
                      final confirmed = await showConfirmationDialog(
                        context,
                        AppStrings.logout,
                        'Are you sure you want to logout?',
                      );
                      if (confirmed && context.mounted) {
                        await context.read<AuthProvider>().signOut();
                        if (context.mounted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WelcomeScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.white),
      title: Text(title, style: const TextStyle(color: AppColors.white)),
      onTap: onTap,
    );
  }
}
