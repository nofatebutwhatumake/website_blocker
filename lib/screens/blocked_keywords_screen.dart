import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:website_blocker/providers/blocker_provider.dart';

class BlockedKeywordsScreen extends StatelessWidget {
  const BlockedKeywordsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<BlockerProvider>(
        builder: (context, blockerProvider, child) {
          return ListView.builder(
            itemCount: blockerProvider.blockedKeywords.length,
            itemBuilder: (context, index) {
              final keyword = blockerProvider.blockedKeywords[index];
              return ListTile(
                title: Text(keyword),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    blockerProvider.removeBlockedKeyword(keyword);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddKeywordDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddKeywordDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Keyword to Block'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter keyword to block',
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
                final keyword = controller.text.trim();
                if (keyword.isNotEmpty) {
                  Provider.of<BlockerProvider>(context, listen: false)
                      .addBlockedKeyword(keyword);
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