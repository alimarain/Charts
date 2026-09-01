import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/auth_provider.dart';
import '../../widgets/navigation/app_header.dart';
import '../../widgets/navigation/app_sidebar.dart';
import 'widgets/settings_action_tiles.dart';
import 'widgets/settings_personal_info_card.dart';
import 'widgets/settings_tab_menu.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  static const routeName = 'settings';
  static const routePath = '/settings';

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedTab = 'Account Profile';
  String _selectedRegion = 'North America (US-EAST-01)';

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _departmentController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.name ?? 'Marcus Vance');
    _emailController = TextEditingController(text: user?.email ?? 'm.vance@enterpriseflow.io');
    _departmentController = TextEditingController(text: 'Operations & Strategy');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  void _handleSave() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preferences saved successfully.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userRole = authState.user?.role == 'maker' ? 'Maker' : 'User';
    final hasToken = authState.token != null && authState.token!.isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: const Color(0xFFF8F9FC),
          drawer: isDesktop
              ? null
              : Drawer(
                  child: AppSidebar(
                    currentRoute: '/settings',
                    hasToken: hasToken,
                    userRole: userRole,
                    isMobileDrawer: true,
                  ),
                ),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isDesktop)
                AppSidebar(
                  currentRoute: '/settings',
                  hasToken: hasToken,
                  userRole: userRole,
                ),
              Expanded(
                child: Column(
                  children: [
                    AppHeader(
                      title: 'System Configuration',
                      showMenuButton: !isDesktop,
                      onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 36.0 : 16.0,
                          vertical: 24.0,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1180),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'System Configuration',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF111827),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Manage organizational preferences and security protocols.',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                                ),
                                const SizedBox(height: 24),
                                LayoutBuilder(
                                  builder: (context, innerConstraints) {
                                    final isWide = innerConstraints.maxWidth > 850;

                                    final tabMenu = SettingsTabMenu(
                                      selectedTab: _selectedTab,
                                      onTabSelected: (tab) => setState(() => _selectedTab = tab),
                                    );

                                    final detailsContent = Column(
                                      children: [
                                        SettingsPersonalInfoCard(
                                          nameController: _nameController,
                                          emailController: _emailController,
                                          departmentController: _departmentController,
                                          selectedRegion: _selectedRegion,
                                          userRole: userRole,
                                          onRegionChanged: (val) {
                                            if (val != null) setState(() => _selectedRegion = val);
                                          },
                                          onSave: _handleSave,
                                        ),
                                        const SizedBox(height: 16),
                                        const SettingsActionTiles(),
                                      ],
                                    );

                                    if (isWide) {
                                      return Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(width: 220, child: tabMenu),
                                          const SizedBox(width: 24),
                                          Expanded(child: detailsContent),
                                        ],
                                      );
                                    }

                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        tabMenu,
                                        const SizedBox(height: 16),
                                        detailsContent,
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}