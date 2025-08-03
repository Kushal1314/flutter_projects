import 'package:flutter/material.dart';
import 'counter_bloc.dart';

class BlocCounterScreen extends StatefulWidget {
  @override
  _BlocCounterScreenState createState() => _BlocCounterScreenState();
}

class _BlocCounterScreenState extends State<BlocCounterScreen> {
  final CounterBloc _bloc = CounterBloc();

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BLoC Counter')),
      body: Center(
        child: StreamBuilder<int>(
          stream: _bloc.counterStream,
          initialData: 0,
          builder: (context, snapshot) {
            return Text(
              'Count: ${snapshot.data}',
              style: const TextStyle(fontSize: 32),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _bloc.increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}