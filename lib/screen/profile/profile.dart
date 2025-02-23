import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userEmail = "Loading...";

  @override
  void initState() {
    super.initState();
    getUserEmail();
  }

  void getUserEmail() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userEmail = user.email ?? "No Email Found";
      });
    }
  }

  Future<List<Map<String, String>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('history') ?? [];

    return history.map((e) {
      var parts = e.split('|');
      return {"title": parts[0], "image": parts[1]};
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "User Email: $userEmail",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              "Recent History:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder(
                future: getHistory(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("No recent history");
                  }
                  List<Map<String, String>> history = snapshot.data!;
                  return ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Image.asset(history[index]["image"] ?? ""),
                        title: Text(history[index]["title"] ?? ""),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
