

create a plan to turn the project into a monorepo using https://github.com/invertase/melos/tree/main (make sure to use the latest stable version) and dart "workspace" feature
I want to separate the current codebase in packages and app
eg:
./packages/ansi
./packages/renderer
./packages/parser
./app/t22e_cli

note the is likely that the package originated from ./lib/src/testing would be likely be a dev_dependencies import

then split the well_known.dart into a package specific versions and rename the class "Defaults", make sure that there is no cross import
(eg: "ansi" package doesn't import "renderer"  Defaults, if necessary duplicate the values)


C) create a package t22e_ui ispired by flutter's dart:ui (https://api.flutter.dev/flutter/dart-ui/) classes and types useful to this project
eg: (including, but not limited to)
- https://api.flutter.dev/flutter/dart-ui/GlyphInfo-class.html
- https://api.flutter.dev/flutter/dart-ui/Offset-class.html
- https://api.flutter.dev/flutter/dart-ui/Color-class.html

### it's very important that ONLY the functionality that we need are implemented

keeping in mind to adapt the classes to our use cases (eg probably colors won't have opacity)

then replace the newly created classes where it makes sense
(eg: lib/src/ansi/color.dart or wherever the file has landed after the monorepo refactor can probably use the newly created "Color" class)