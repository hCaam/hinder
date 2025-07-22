import 'package:flutter/material.dart';
import 'firebase_api.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double? _dragStartY;
  List<Map<String, dynamic>> _items = [];
  bool _loading = false;

  void _handlePanStart(DragStartDetails details) {
    _dragStartY = details.localPosition.dy;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_dragStartY != null && (_dragStartY! - details.localPosition.dy) > 80) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Swipe up detected!')),
      );
      _dragStartY = null; // Prevent multiple triggers
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    _dragStartY = null;
  }

  Future<void> _fetchData() async {
    setState(() {
      _loading = true;
    });
    try {
      final items = await FirebaseApi.fetchItems();
      setState(() {
        _items = items;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Image
                Image.network(
                  'https://via.placeholder.com/48',
                  width: 48,
                  height: 48,
                ),
                const SizedBox(width: 16),
                // 2. Label text
                const Text(
                  'Label Text',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 16),
                // 3. 2-column component
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.star, size: 20),
                        SizedBox(width: 4),
                        Text('Star'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Icon(Icons.favorite, size: 20),
                        SizedBox(width: 4),
                        Text('Favorite'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loading ? null : _fetchData,
              child: _loading ? const CircularProgressIndicator() : const Text('Read Data'),
            ),
            const SizedBox(height: 16),
            // Show fetched data
            ..._items.map((item) => Text(
              '${item['id']}: ${item['name']} - ${item['description']}',
              style: const TextStyle(fontSize: 16),
            )),
          ],
        ),
      ),
    );
  }
}