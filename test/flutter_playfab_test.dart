import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_playfab/flutter_playfab.dart';

void main() {
  test('login', () {
    var playfab = new Playfab("PLAYFAB_TITLE_ID");
    playfab.debugMode = true;
  });
}
