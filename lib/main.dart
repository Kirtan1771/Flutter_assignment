import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter InAppWebView Demo',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  InAppWebViewController? _webViewController;
  final TextEditingController _textController = TextEditingController();
  String imageUrl = "";
  bool isFullscreen = false;
  bool isMenuOpen = false;

  @override
  void initState() {
    super.initState();
  }

  String _generateHtml(String url) {
    return """
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body { display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; background: #f4f4f4; }
        img { max-width: 100%; height: auto; border-radius: 12px; }
      </style>
    </head>
    <body>
      ${url.isNotEmpty ? '<img src="$url" alt="Image">' : '<p>Enter a URL and press the button.</p>'}
    </body>
    </html>
    """;
  }

  void _loadImage() {
    final url = _textController.text.trim();
    if (url.isEmpty || !url.startsWith('http')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid URL')),
      );
      return;
    }

    setState(() {
      imageUrl = url;
    });

    _webViewController?.loadData(data: _generateHtml(imageUrl));
  }

  void _toggleFullscreen() {
    setState(() {
      isFullscreen = !isFullscreen;
    });
  }

  void _toggleMenu() {
    setState(() {
      isMenuOpen = !isMenuOpen;
    });
  }

  void _closeMenu() {
    setState(() {
      isMenuOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isFullscreen ? null : AppBar(title: const Text("InAppWebView Example")),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InAppWebView(
                      initialData: InAppWebViewInitialData(data: _generateHtml("")),
                      onWebViewCreated: (controller) {
                        _webViewController = controller;
                      },
                    ),
                  ),
                ),
                if (!isFullscreen)
                  Column(
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              decoration: const InputDecoration(hintText: 'Image URL'),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _loadImage,
                            child: const Padding(
                              padding: EdgeInsets.all(12),
                              child: Icon(Icons.arrow_forward),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 64),
                    ],
                  ),
              ],
            ),
          ),
          if (isMenuOpen)
            GestureDetector(
              onTap: _closeMenu,
              child: Container(color: Colors.black54, width: double.infinity, height: double.infinity),
            ),
          if (isMenuOpen)
            Positioned(
              bottom: 100,
              right: 20,
              child: Column(
                children: [
                  _MenuButton(
                    text: isFullscreen ? "Exit fullscreen" : "Enter fullscreen",
                    onPressed: () {
                      _toggleFullscreen();
                      _closeMenu();
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleMenu,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _MenuButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(text),
      ),
    );
  }
}
