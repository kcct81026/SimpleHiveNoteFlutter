import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('mybabies_box');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'Hive Eg',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  List<Map<String, dynamic>> _items = [];
  final _getMyBabiesBox = Hive.box('mybabies_box');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshItems();
  }

  /// Get ALL MY BABIES
  void _refreshItems(){
    final data = _getMyBabiesBox.keys.map((key){
      final babyItem = _getMyBabiesBox.get(key);
      return {
        "key" : key,
        "name" : babyItem['name'],
        "age" : babyItem['age']
      };
    }).toList();
    setState(() {
      _items = data.reversed.toList();
      print('item size ${_items.length} ');
    });
  }

  /// Create New Item
  Future<void> _createItem(Map<String, dynamic> newItem) async{
    await _getMyBabiesBox.add(newItem);
    _refreshItems();
  }

  /// Update Item
  Future<void> _updateItem(int itemKey, Map<String, dynamic> item) async{
    await _getMyBabiesBox.put(itemKey, item);
    _refreshItems();
  }

  /// Delete Item
  Future<void> _deleteItem(int itemKey) async{
    await _getMyBabiesBox.delete(itemKey);
    _refreshItems();

    // Display a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('A baby has been deleted!'))
    );
  }

  void _showForm(BuildContext ctx, int? itemKey) async{

    if(itemKey != null){
      final existingItem = _items
          .firstWhere((element) => element['key'] == itemKey);
      _nameController.text = existingItem['name'];
      _ageController.text = existingItem['age'];
    }

    showModalBottomSheet(
      context: ctx,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          top: 15,
          left: 15,
          right: 15
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _nameController, 
              decoration: InputDecoration(hintText: 'Name'),
            ),
            SizedBox(height: 10,),
            TextField(
              controller: _ageController,
              decoration: InputDecoration(hintText: "Age"),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20,),
            ElevatedButton(
              onPressed: () async{
                if  (itemKey != null) {
                  _updateItem(
                    itemKey,
                    {
                      'name' : _nameController.text.trim(),
                      'age' : _ageController.text.trim()
                    }
                  );
                }
                else{
                  _createItem({
                    "name" : _nameController.text,
                    "age" : _ageController.text
                  });
                }

                _nameController.text = '';
                _ageController.text = '';
                Navigator.of(ctx).pop();
            }, 
              child: (itemKey != null) ? Text('Update My Baby Info <3') : Text('Add to heart <3 '),
            ),
            SizedBox(height: 15,),
          ],
        ),
      ),
      
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hive'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, null),
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (_, index){
          final currentItem = _items[index];
          return Card(
            color: Colors.blue.shade100,
            margin: EdgeInsets.all(10),
            elevation: 3,
            child: ListTile(
              title: Text(currentItem['name']),
              subtitle: Text(currentItem['age'].toString()),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      _showForm(context, currentItem['key']);
                    },
                    icon: Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: ()  {
                      _deleteItem(currentItem['key']);
                    },
                    icon: Icon(Icons.delete),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


