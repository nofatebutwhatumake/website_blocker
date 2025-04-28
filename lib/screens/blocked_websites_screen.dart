import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:website_blocker/providers/blocker_provider.dart';

class BlockedWebsitesScreen extends StatelessWidget {
  const BlockedWebsitesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<BlockerProvider>(
        builder: (context, blockerProvider, child) {
          if (blockerProvider.blockedWebsites.isEmpty) {
            return const Center(
              child: Text(
                'No websites blocked yet',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            itemCount: blockerProvider.blockedWebsites.length,
            itemBuilder: (context, index) {
              final website = blockerProvider.blockedWebsites[index];
              return ListTile(
                title: Text(website),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    blockerProvider.removeBlockedWebsite(website);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddWebsiteDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddWebsiteDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Website to Block'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter website URL (e.g., example.com)',
            ),
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
                final website = controller.text.trim();
                if (website.isNotEmpty) {
                  Provider.of<BlockerProvider>(context, listen: false)
                      .addBlockedWebsite(website);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
} 