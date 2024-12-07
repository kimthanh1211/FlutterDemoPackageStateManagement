import 'dart:collection';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter/material.dart';
import 'package:flutter_state_management/state_manager.dart';

import 'common/http_request.dart';



void main() {
  runApp(MyApp());
}

/*
// test perfomance with Integer test
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  //Time to update state 100 times: 16145 ms
  testInteger(100);
  //Time to update state 1000 times: 117051 ms
  //testInteger(1000);
}
 */

class MyApp extends StatelessWidget {
  final StateManager<int> stateNumberManager = StateManager<int>(0);
  final StateManager<dynamic> stateJsonManager = StateManager<dynamic>({});


  MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(title: Text("State Management Example")),
        body:Builder(builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Column(
              children: [
                demoNumber(context),
                Divider(),
                demoJson(context),
              ],
            ),
          );
        })


      ),
    );
  }

  Widget demoNumber(BuildContext context){
    return Container(
      child: Column(
        children: [
          Text('Demo number',style: TextStyle(fontSize: 20),),
          SizedBox(height: 5),
          StreamBuilder<int?>(
            stream: stateNumberManager.notifier.stateStream,
            initialData: stateNumberManager.state,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                int? currentState = snapshot.data ?? 0;
                return Text(
                  'State: $currentState',
                  style: TextStyle(fontSize: 24),
                );
              }
              else return CircularProgressIndicator();
            },
          ),
          /*
              StateObserver<dynamic>(
                notifier: stateManager.notifier,
                builder: (context, state) {
                  return Text(
                    'State: ${state}',
                    style: TextStyle(fontSize: 24),
                  );
                },
                onStateChanged: (newState) {
                  print('State Changed: $newState');
                },
                onError: (error) {
                  print('Error: $error');
                },
                onDone: () {
                  print('Stream Completed');
                },
              ),
               */
          SizedBox(height: 5),
          FloatingActionButton(
            onPressed: () {
              stateNumberManager.state = (stateNumberManager.state ?? 0) + 1;
            },
            child: Icon(Icons.add),
          ),
          SizedBox(height: 5),
          ElevatedButton(
            onPressed: () {
              stateNumberManager.resetState();
            },
            child: Text("Reset State"),
          ),
          SizedBox(height: 5),
          ElevatedButton(
            onPressed: () {
              stateNumberManager.deleteState();
            },
            child: Text("Delete State"),
          ),
          SizedBox(height: 5),
          ElevatedButton(
            onPressed: () {
              // Get the current state directly without triggering stream
              int? currentState = stateNumberManager.getData();
              print("Current State: $currentState");
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Current State: $currentState",style: TextStyle(color:Colors.white))));
            },
            child: Text("Get Data"),
          ),
        ],
      ),
    );
  }

  Widget demoJson(BuildContext context){
    return Container(
      child: Column(
        children: [
          Text('Demo json/ call api',style: TextStyle(fontSize: 20),),
          SizedBox(height: 5),
          StreamBuilder<dynamic>(
            stream: stateJsonManager.notifier.stateStream,
            initialData: stateJsonManager.state,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active
                && snapshot.hasData && snapshot.data!.isNotEmpty
              ) {
                dynamic currentState = snapshot.data ?? "";

                return Column(
                  children: List.generate(snapshot.data.length??0,
                          (index){
                        var _item = snapshot.data[index];
                        return Container(
                          child:Text('${_item.id}. ${_item.title}')
                        );
                      }
                  ),
                );
              }
              else return CircularProgressIndicator();
            },
          ),
          SizedBox(height: 5),
          ElevatedButton(
            onPressed: () {
              stateJsonManager.state = [Post(id: 1, title: "New Post", body: "This is a new post")];
            },
            child: Text("Synchronous update"),
          ),
          SizedBox(height: 5),
          ElevatedButton(
            onPressed: () {
              fetchPosts();
            },
            child: Text("Asynchronous update"),
          ),
          SizedBox(height: 5),
          ElevatedButton(
            onPressed: () {
              stateJsonManager.resetState();
            },
            child: Text("Reset State"),
          ),
          SizedBox(height: 5),
          ElevatedButton(
            onPressed: () {
              stateJsonManager.deleteState();
            },
            child: Text("Delete State"),
          ),
          SizedBox(height: 5),
          ElevatedButton(
            onPressed: () {
              // Get the current state directly without triggering stream
              dynamic currentState = stateJsonManager.getData();
              print("Current State Json: ${jsonEncode(currentState)}");
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Current State Json: ${jsonEncode(currentState)}",style: TextStyle(color:Colors.white))));
            },
            child: Text("Get Data"),
          ),
        ],
      ),
    );
  }

  Future<void> fetchPosts() async {
    try {
      ApiService apiService = ApiService();
      //List<Post> posts = await apiService.fetchPosts();
      //print("posts: ${jsonEncode(posts)}");
      //stateJsonManager.state = posts;
      await stateJsonManager.updateStateAsynchronous(apiService.fetchPosts());
    } catch (e) {
      print('Error fetching posts: $e');
    }
  }
}
void testInteger(int timeTest){
  final StateManager<int> stateTestIntManager = StateManager<int>(0);
  testWidgets('Measure performance of state changes', (tester) async {
    final startTime = DateTime.now().millisecondsSinceEpoch;

    // Simulate a lot of state changes
    for (int i = 0; i < timeTest; i++) {
      // Trigger a state update (change in your state manager)
      stateTestIntManager.state = i;

      // Use your stream or observer widget to rebuild the UI
      await tester.pumpAndSettle();
    }

    final endTime = DateTime.now().millisecondsSinceEpoch;
    final duration = endTime - startTime;
    print('Time to update state $timeTest times: $duration ms');

    // Test rendering performance
    expect(duration, lessThan(5000)); // This is an example threshold
  });
}

