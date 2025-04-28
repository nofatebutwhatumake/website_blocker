import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BlockerProvider with ChangeNotifier {
  List<String> _blockedWebsites = [];
  List<String> _blockedKeywords = [];
  bool _isVpnActive = false;
  String _customBlockMessage = "This content has been blocked";
  
  List<String> get blockedWebsites => _blockedWebsites;
  List<String> get blockedKeywords => _blockedKeywords;
  bool get isVpnActive => _isVpnActive;
  String get customBlockMessage => _customBlockMessage;

  BlockerProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _blockedWebsites = prefs.getStringList('blockedWebsites') ?? [];
    _blockedKeywords = prefs.getStringList('blockedKeywords') ?? [];
    _isVpnActive = prefs.getBool('isVpnActive') ?? false;
    _customBlockMessage = prefs.getString('customBlockMessage') ?? "This content has been blocked";
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('blockedWebsites', _blockedWebsites);
    await prefs.setStringList('blockedKeywords', _blockedKeywords);
    await prefs.setBool('isVpnActive', _isVpnActive);
    await prefs.setString('customBlockMessage', _customBlockMessage);
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

  void addBlockedKeyword(String keyword) {
    if (!_blockedKeywords.contains(keyword) && keyword.isNotEmpty) {
      _blockedKeywords.add(keyword);
      _saveSettings();
      notifyListeners();
    }
  }

  void removeBlockedKeyword(String keyword) {
    _blockedKeywords.remove(keyword);
    _saveSettings();
    notifyListeners();
  }

  void setVpnActive(bool isActive) {
    _isVpnActive = isActive;
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

  bool isWebsiteBlocked(String url) {
    return _blockedWebsites.any((website) => url.contains(website));
  }

  bool containsBlockedKeyword(String content) {
    return _blockedKeywords.any((keyword) => 
      content.toLowerCase().contains(keyword.toLowerCase()));
  }
} 