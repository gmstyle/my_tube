import 'package:flutter/material.dart';

class DraggableHeader extends StatelessWidget {
  const DraggableHeader({super.key, required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: controller,
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2)),
              ),
            ],
          ),
          const SizedBox(
            height: 4,
          ),
          const Text(
            'QUEUE',
          ),
        ]),
      ),
    );
  }
}
