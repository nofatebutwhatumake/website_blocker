import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:website_blocker/providers/blocker_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<BlockerProvider>(
        builder: (context, blockerProvider, child) {
          return ListView(
            children: [
              ListTile(
                title: const Text('Custom Block Message'),
                subtitle: Text(blockerProvider.customBlockMessage),
                onTap: () {
                  _showCustomMessageDialog(context);
                },
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Enable Website Blocking'),
                subtitle: const Text('Toggle website blocking on/off'),
                value: blockerProvider.isBlockingEnabled,
                onChanged: (value) {
                  blockerProvider.setBlockingEnabled(value);
                },
              ),
              const Divider(),
              const ListTile(
                title: Text('About'),
                subtitle: Text('Website Blocker v1.0.0'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCustomMessageDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController(
      text: Provider.of<BlockerProvider>(context, listen: false)
          .customBlockMessage,
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Custom Block Message'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter custom message',
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final message = controller.text.trim();
                if (message.isNotEmpty) {
                  Provider.of<BlockerProvider>(context, listen: false)
                      .setCustomBlockMessage(message);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
} 