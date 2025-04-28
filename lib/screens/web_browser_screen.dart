import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:website_blocker/providers/blocker_provider.dart';
import 'package:website_blocker/widgets/custom_web_view.dart';

class WebBrowserScreen extends StatefulWidget {
  final String initialUrl;
  
  const WebBrowserScreen({
    Key? key,
    required this.initialUrl,
  }) : super(key: key);

  @override
  State<WebBrowserScreen> createState() => _WebBrowserScreenState();
}

class _WebBrowserScreenState extends State<WebBrowserScreen> {
  late final WebViewController _controller;
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = true;
  bool _isBlocked = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _isBlocked = false;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
              _urlController.text = url;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            final blockerProvider =
                Provider.of<BlockerProvider>(context, listen: false);
            if (blockerProvider.isVpnActive &&
                blockerProvider.isWebsiteBlocked(url)) {
              setState(() {
                _isBlocked = true;
              });
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
    _urlController.text = widget.initialUrl;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe Browser'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter URL',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                    ),
                    onSubmitted: (url) {
                      String processedUrl = url;
                      if (!url.startsWith('http://') && !url.startsWith('https://')) {
                        processedUrl = 'https://$url';
                      }
                      
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => WebBrowserScreen(
                            initialUrl: processedUrl,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    String url = _urlController.text.trim();
                    if (!url.startsWith('http://') && !url.startsWith('https://')) {
                      url = 'https://$url';
                    }
                    
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => WebBrowserScreen(
                          initialUrl: url,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          CustomWebView(initialUrl: widget.initialUrl),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_isBlocked)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.block,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      Provider.of<BlockerProvider>(context).customBlockMessage,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _controller.loadRequest(Uri.parse(widget.initialUrl));
                      },
                      child: const Text('Go to Google'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
} 