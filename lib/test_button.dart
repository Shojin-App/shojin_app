import 'package:m3e_collection/m3e_collection.dart';
import 'package:flutter/material.dart';

void main() {
  // Test named constructors
  ButtonM3E(
    onPressed: () {},
    label: const Text('Elevated'),
    style: ButtonM3EStyle.elevated,
  );
  ButtonM3E(
    onPressed: () {},
    label: const Text('Filled'),
    style: ButtonM3EStyle.filled,
  );
  ButtonM3E(
    onPressed: () {},
    label: const Text('Tonal'),
    style: ButtonM3EStyle.tonal,
  );
  ButtonM3E(
    onPressed: () {},
    label: const Text('Outlined'),
    style: ButtonM3EStyle.outlined,
  );
  ButtonM3E(
    onPressed: () {},
    label: const Text('Text'),
    style: ButtonM3EStyle.text,
  );
}
