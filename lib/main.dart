import 'package:flutter/material.dart';
import 'speed_display.dart';
import 'data_display_page.dart';
import 'db_helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Real-time GPS Speed Display App'),
      ),
      body: Center(
        child: Column(
          children: [
            SpeedDisplay(),
            ElevatedButton(
              onPressed: () async {
                // Example: Insert data into the SQLite database
                // Navigate to the DataDisplayPage when the button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DataDisplayPage()),
                );
              },
              child: Text('Perform SQLite Operations'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                var shouldDelete = await _showDeleteAlert(context) ;
                // print(shouldDelete);
                // Example: Clear data from the SQLite database
                await DBHelper.instance.clearTable('locations');

              },
              child: Text('Clear Database'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                // Example: Export data to CSV
                bool hasPermission = await _requestStoragePermission();
                if (hasPermission) {
                  // Example: Export data to CSV
                  await DBHelper.instance.exportToCSV('locations');
                  showOkAlertDialog(
                    context: context,
                    okLabel: 'OK',
                    title: 'Title',
                    message: 'This is the message',
                  );
                } else {
                  // Handle case where the user denied permission
                  print('Permission denied to export data.');
                }
              },
              child: Text('Export to CSV'),
            ),
          ],
        ),
      ),
    );
  }
  Future<bool> _requestStoragePermission() async {
    PermissionStatus status = await Permission.manageExternalStorage.request();
    return status == PermissionStatus.granted;
  }

  Future<void> _showDeleteAlert(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to clear the database?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // No
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Yes
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
Future<void> showAlertDialog(BuildContext context) async{
  // set up the button
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () { },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Successfull"),
    content: Text("Save your selected location"),
    actions: [
      okButton,
    ],
  );
  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}