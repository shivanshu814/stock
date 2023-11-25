import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DataScreen()),
            );
          },
          child: Text('Go to Data Screen'),
        ),
      ),
    );
  }
}

class DataScreen extends StatefulWidget {
  @override
  _DataScreenState createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  List<Map<String, dynamic>> data = [];
  TextEditingController numberOfItemsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final Uri uri = Uri.parse(
        'https://api.polygon.io/v2/aggs/grouped/locale/us/market/stocks/2023-01-09?adjusted=true&apiKey=Uuc2J73WWc22LcUhvpmhZcPjPptbRLbE');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> results = jsonResponse['results'];

      setState(() {
        data = results
            .map<Map<String, dynamic>>((result) => {
                  'symbol': result['T'],
                  'high': result['h'],
                  'low': result['l'],
                  'open': result['o'],
                  'close': result['c'],
                })
            .toList();
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Screen'),
      ),
      body: Column(
        children: [
          TextField(
            controller: numberOfItemsController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Number of items to display',
            ),
          ),
          ElevatedButton(
            onPressed: () {
              int numberOfItems =
                  int.tryParse(numberOfItemsController.text) ?? 0;
              if (numberOfItems >= 0) {
                setState(() {
                  data = data.take(numberOfItems).toList();
                });
              }
            },
            child: Text('Update'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final stock = data[index];
                return ListTile(
                  title: Text(stock['symbol']),
                  subtitle: Text(
                    'High: ${stock['high']}, Low: ${stock['low']}, Open: ${stock['open']}, Close: ${stock['close']}',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
