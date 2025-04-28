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