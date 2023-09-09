import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_tube/blocs/home/home_bloc.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Center(child: Text('Dashboard'));
        },
      ),
    );
  }
}
