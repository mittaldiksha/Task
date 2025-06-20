import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Achievement Model
class Achievement {
  final String id;
  final String title_key;
  final String description_key;
  bool isNew;
  bool isFavorite;

  Achievement({
    required this.id,
    required this.title_key,
    required this.description_key,
    this.isNew = true,
    this.isFavorite = false,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] ?? 'No id',
      title_key: json['title_key'] ?? 'No title',
      description_key: json['description_key'] ?? 'No Description',
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AchievementScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class AchievementScreen extends StatefulWidget {
  @override
  _AchievementScreenState createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  List<Achievement> _achievements = [];

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  // Fetch API Data
  void _loadAchievements() async {
    try {
      final response = await http.get(
        Uri.parse('https://walking-startup.uk/achievements'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          _achievements = data
              .map((item) => Achievement.fromJson(item))
              .toList();
        });
      } else {
        throw Exception('Failed to load achievements');
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _toggleFavorite(int index) {
    setState(() {
      _achievements[index].isFavorite = !_achievements[index].isFavorite;
      final item = _achievements.removeAt(index);
      if (item.isFavorite) {
        _achievements.insert(0, item);
      } else {
        _achievements.add(item);
      }
    });
  }

  void _showDetails(Achievement item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item.title_key),
        content:Text(item.description_key),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Achievements")),
      body: _achievements.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _achievements.length,
        itemBuilder: (context, index) {
          final item = _achievements[index];
          return GestureDetector(
            onTap: () {
              _showDetails(item);
              if (item.isNew) {
                setState(() {
                  item.isNew = false;
                });
              }
            },
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ListTile(
                leading: Stack(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage('assets/static_image.jpg'),
                    ),
                    if (item.isNew)
                      Positioned(
                        top: -2,
                        left: -4,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "NEW",
                            style: TextStyle(
                                color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ),
                  ],
                ),
                title: Text(item.title_key),
                trailing: IconButton(
                  icon: Icon(
                    item.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color:
                    item.isFavorite ? Colors.red : Colors.grey[700],
                  ),
                  onPressed: () => _toggleFavorite(index),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}