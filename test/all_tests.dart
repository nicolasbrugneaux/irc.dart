library all_tests;

import 'package:unittest/unittest.dart';

import 'parser_tests.dart' as parser_tests;

void main() {
  group("Parser", parser_tests.main);
}