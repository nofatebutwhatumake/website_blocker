// lib/widgets/custom_web_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:website_blocker/providers/blocker_provider.dart';
import 'package:website_blocker/screens/block_screen.dart';
import 'package:website_blocker/services/vpn_service.dart';

class CustomWebView extends StatefulWidget {
  final String initialUrl;
  
  const CustomWebView({
    Key? key,
    required this.initialUrl,
  }) : super(key: key);

  @override
  State<CustomWebView> createState() => _CustomWebViewState();
}

class _CustomWebViewState extends State<CustomWebView> {
  late WebViewController _controller;
  String _currentUrl = '';
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _currentUrl = widget.initialUrl;
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _currentUrl = url;
            });
            _checkUrl(url);
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            _checkContent();
          },
          onNavigationRequest: (NavigationRequest request) {
            if (_shouldBlock(request.url)) {
              _showBlockScreen(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }
  
  bool _shouldBlock(String url) {
    final blockerProvider = Provider.of<BlockerProvider>(context, listen: false);
    return VpnService.shouldBlockUrl(url, blockerProvider);
  }
  
  void _checkUrl(String url) {
    if (_shouldBlock(url)) {
      _showBlockScreen(url);
    }
  }
  
  Future<void> _checkContent() async {
    final blockerProvider = Provider.of<BlockerProvider>(context, listen: false);
    if (!blockerProvider.isVpnActive || blockerProvider.blockedKeywords.isEmpty) {
      return;
    }
    
    // Get the page content
    final content = await _controller.runJavaScriptReturningResult(
      'document.documentElement.innerText'
    ) as String;
    
    // Check for blocked keywords
    if (VpnService.shouldBlockContent(content, blockerProvider)) {
      _showBlockScreen(_currentUrl);
    }
  }
  
  void _showBlockScreen(String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlockScreen(blockedUrl: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}

// lib/screens/web_browser_screen.dart
import 'package:flutter/material.dart';
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
  final TextEditingController _urlController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
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
      body: CustomWebView(initialUrl: widget.initialUrl),
    );
  }
}