import 'package:m3e_collection/m3e_collection.dart';
import 'package:flutter/material.dart';

void main() {
  // Test named constructors with label
  ButtonM3E(
    onPressed: () {},
    label: Text('Elevated'),
    style: ButtonM3EStyle.elevated,
  );
  ButtonM3E(
    onPressed: () {},
    label: Text('Filled'),
    style: ButtonM3EStyle.filled,
  );
  ButtonM3E(
    onPressed: () {},
    label: Text('Tonal'),
    style: ButtonM3EStyle.tonal,
  );
  ButtonM3E(
    onPressed: () {},
    label: Text('Outlined'),
    style: ButtonM3EStyle.outlined,
  );
  ButtonM3E(onPressed: () {}, label: Text('Text'), style: ButtonM3EStyle.text);

  // Test with style parameter
  ButtonM3E(
    onPressed: () {},
    label: Text('Style Text'),
    style: ButtonM3EStyle.text,
  );
  ButtonM3E(
    onPressed: () {},
    label: Text('Style Filled'),
    style: ButtonM3EStyle.filled,
  );

  // Test with variant parameter (deprecated/removed?)
  // ButtonM3E(onPressed: () {}, label: Text('Variant'), variant: ButtonM3EVariant.elevated);
}
