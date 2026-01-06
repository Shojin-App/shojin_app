import 'package:m3e_collection/m3e_collection.dart';
import 'package:flutter/material.dart';

void probe() {
  // Check if ButtonM3E exists
  ButtonM3E(
    onPressed: () {},
    label: const Text('Test'),
    style: ButtonM3EStyle.elevated,
  );

  // Check if ButtonM3E.elevated exists (expecting error)
  // ButtonM3E.elevated(onPressed: () {}, child: const Text('Test'));
}
