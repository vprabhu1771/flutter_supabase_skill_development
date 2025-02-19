import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/Topic.dart';
import '../widgets/CustomDrawer.dart';
import 'ExamScreen.dart';

class TopicScreen extends StatefulWidget {
  final String title;

  const TopicScreen({super.key, required this.title});

  @override
  State<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Topic> _topics = [];

  @override
  void initState() {
    super.initState();
    _listenToTopicUpdates();
    _fetchInitialTopics();
  }

  /// 🔔 Listen for real-time updates from the 'topics' table
  void _listenToTopicUpdates() {
    _supabase
        .from('topics')
        .stream(primaryKey: ['id'])
        .listen((data) {
      setState(() {
        _topics = data.map((e) => Topic.fromMap(e)).toList();
      });
    });
  }

  /// 🗂️ Initial fetch of topics using `.get()` instead of `.execute()`
  Future<void> _fetchInitialTopics() async {

    final response = await _supabase.from('topics').select();

    print(response.toString());

    // if (response.error != null) {
    //   print('Error fetching topics: ${response.error!.message}');
    //   return;
    // }

    setState(() {
      _topics = (response as List<dynamic>)
          .map((e) => Topic.fromMap(e as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.title),
      // ),
      drawer: CustomDrawer(parentContext: context),
      body: _topics.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _topics.length,
        itemBuilder: (context, index) {
          final topic = _topics[index];
          return ListTile(
            title: Text(topic.name),
            onTap: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExamScreen(topic: topic),
                ),
              );

            },
          );
        },
      ),
    );
  }
}
