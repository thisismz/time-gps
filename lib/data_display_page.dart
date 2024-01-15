import 'package:flutter/material.dart';
import 'db_helper.dart';

class DataDisplayPage extends StatefulWidget {
  @override
  _DataDisplayPageState createState() => _DataDisplayPageState();
}

class _DataDisplayPageState extends State<DataDisplayPage> {
  List<Map<String, dynamic>> _data = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    List<Map<String, dynamic>> data = await DBHelper.instance.getLocations();
    setState(() {
      _data = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Display Page'),
      ),
      body: ListView.builder(
        itemCount: _data.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('timestamp: ${_data[index]['timestamp']}'),
            subtitle: Column(
              children: [
                Text(
                    'latitude: ${_data[index]['latitude']}'
                ),
                Text(
                    'longitude: ${_data[index]['longitude']}'
                ),
                Text(
                    'speed: ${_data[index]['speed']}'
                ),
              ],
            ),

            // Add more ListTile details as needed
          );
        },
      ),
    );
  }
}
