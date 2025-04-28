// lib/screens/home_screen.dart (updated)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:website_blocker/providers/blocker_provider.dart';
import 'package:website_blocker/screens/blocked_websites_screen.dart';
import 'package:website_blocker/screens/blocked_keywords_screen.dart';
import 'package:website_blocker/screens/settings_screen.dart';
import 'package:website_blocker/screens/web_browser_screen.dart';
import 'package:website_blocker/services/vpn_service.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const DashboardPage(),
    const BlockedWebsitesScreen(),
    const BlockedKeywordsScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.notification.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Blocker'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.public),
            tooltip: 'Safe Browser',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const WebBrowserScreen(
                    initialUrl: 'https://www.google.com',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.block),
            label: 'Websites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.text_fields),
            label: 'Keywords',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final blockerProvider = Provider.of<BlockerProvider>(context);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Blocking Service',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Enable Content Blocking'),
                      Switch(
                        value: blockerProvider.isVpnActive,
                        onChanged: (value) async {
                          if (value) {
                            var status = await Permission.notification.request();
                            if (status.isGranted) {
                              VpnService.startVpn(context);
                            }
                          } else {
                            VpnService.stopVpn(context);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Blocking Stats',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.public_off),
                      const SizedBox(width: 8),
                      Text('${blockerProvider.blockedWebsites.length} websites blocked'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.text_fields),
                      const SizedBox(width: 8),
                      Text('${blockerProvider.blockedKeywords.length} keywords blocked'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (blockerProvider.isVpnActive)
            const Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.shield, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Protection Active', style: TextStyle(color: Colors.green)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const WebBrowserScreen(
                      initialUrl: 'https://www.google.com',
                    ),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Safe Browser',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('Browse safely with content filtering'),
                      ],
                    ),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}