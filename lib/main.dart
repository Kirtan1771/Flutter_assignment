import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// Application itself.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Flutter Demo', home: const HomePage());
  }
}

/// [Widget] displaying the home page consisting of an image and the buttons.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// State of a [HomePage].
class _HomePageState extends State<HomePage> {
  late WebViewController _webViewController;
  final TextEditingController _textController = TextEditingController();
  String imageUrl = "";
  bool isFullscreen = false;
  bool isMenuOpen = false;

  @override
  // Initializing a WebView Controller
  void initState() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(_generateHtml(""));
    super.initState();
  }
// Using Webview to generate image url through html tags
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
    setState(() {
      imageUrl = _textController.text.trim();
    });
    _webViewController.loadHtmlString(_generateHtml(imageUrl));
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
      appBar: isFullscreen ? null : AppBar(),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: imageUrl.isEmpty
                        ? Container(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'Enter a URL and press the button.',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                        : WebViewWidget(controller: _webViewController),
                  ),
                ),
                const SizedBox(height: 8),
                if (!isFullscreen)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          decoration: InputDecoration(hintText: 'Image URL'),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _loadImage,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
                          child: Icon(Icons.arrow_forward),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 64),
              ],
            ),
          ),
          if (isMenuOpen)
            GestureDetector(
              onTap: _closeMenu,
              child: Container(
                color: Colors.black54,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          if (isMenuOpen)
            Positioned(
              bottom: 100,
              right: 20,
              child: Column(
                children: [
                  _MenuButton(
                    text: "Enter fullscreen",
                    onPressed: () {
                      _toggleFullscreen();
                      _closeMenu();
                    },
                  ),
                  const SizedBox(height: 8),
                  _MenuButton(
                    text: "Exit fullscreen",
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
        child: Icon(Icons.add),
      ),
    );
  }
}

/// Custom widget for the menu buttons.
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
