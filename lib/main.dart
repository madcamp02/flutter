import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter GitHub Login',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GitHubLoginScreen(),
    );
  }
}

class GitHubLoginScreen extends StatefulWidget {
  const GitHubLoginScreen({super.key});

  @override
  State<GitHubLoginScreen> createState() => _GitHubLoginScreenState();
}

class _GitHubLoginScreenState extends State<GitHubLoginScreen> {
  void _loginWithGitHub() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GitHubLoginWebView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('GitHub Login'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _loginWithGitHub,
          child: const Text('Login with GitHub'),
        ),
      ),
    );
  }
}

class GitHubLoginWebView extends StatefulWidget {
  const GitHubLoginWebView({super.key});

  @override
  _GitHubLoginWebViewState createState() => _GitHubLoginWebViewState();
}

class _GitHubLoginWebViewState extends State<GitHubLoginWebView> {
  late WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub Login'),
      ),
      body: WebView(
        initialUrl: 'http://localhost:3000/auth/github',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller = webViewController;
        },
        navigationDelegate: (NavigationRequest request) {
          if (request.url.startsWith('http://localhost:3000/profile')) {
            _handleGitHubProfile();
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    );
  }

  void _handleGitHubProfile() async {
    final String profileUrl = 'http://localhost:8080/profile';
    final response = await http.get(Uri.parse(profileUrl));
    if (response.statusCode == 200) {
      final profile = json.decode(response.body);
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('GitHub Profile'),
            content: Text('Username: ${profile['username']}\nEmail: ${profile['emails'][0]['value']}'),
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
