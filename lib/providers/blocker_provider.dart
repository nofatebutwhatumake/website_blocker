import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BlockerProvider with ChangeNotifier {
  List<String> _blockedWebsites = [];
  String _customBlockMessage = "This website has been blocked";
  bool _isBlockingEnabled = true;
  
  List<String> get blockedWebsites => _blockedWebsites;
  String get customBlockMessage => _customBlockMessage;
  bool get isBlockingEnabled => _isBlockingEnabled;

  BlockerProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _blockedWebsites = prefs.getStringList('blockedWebsites') ?? [];
    _customBlockMessage = prefs.getString('customBlockMessage') ?? "This website has been blocked";
    _isBlockingEnabled = prefs.getBool('isBlockingEnabled') ?? true;
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('blockedWebsites', _blockedWebsites);
    await prefs.setString('customBlockMessage', _customBlockMessage);
    await prefs.setBool('isBlockingEnabled', _isBlockingEnabled);
  }

  void addBlockedWebsite(String website) {
    if (!_blockedWebsites.contains(website) && website.isNotEmpty) {
      _blockedWebsites.add(website);
      _saveSettings();
      notifyListeners();
    }
  }

  void removeBlockedWebsite(String website) {
    _blockedWebsites.remove(website);
    _saveSettings();
    notifyListeners();
  }

  void setCustomBlockMessage(String message) {
    if (message.isNotEmpty) {
      _customBlockMessage = message;
      _saveSettings();
      notifyListeners();
    }
  }

  void setBlockingEnabled(bool value) {
    _isBlockingEnabled = value;
    _saveSettings();
    notifyListeners();
  }

  bool isWebsiteBlocked(String url) {
    return _blockedWebsites.any((website) => url.contains(website));
  }
} 