local parse = require("luasnip").parser.parse_snippet

return {
    parse({ trig = "stless", name = "StatelessWidget", dscr = "Flutter stateless widget" }, [[
class ${1:MyWidget} extends StatelessWidget {
  const $1({super.key});

  @override
  Widget build(BuildContext context) {
    return ${0:const SizedBox.shrink()};
  }
}
]]),
    parse({ trig = "stful", name = "StatefulWidget", dscr = "Flutter stateful widget and state" }, [[
class ${1:MyWidget} extends StatefulWidget {
  const $1({super.key});

  @override
  State<$1> createState() => _${1}State();
}

class _${1}State extends State<$1> {
  @override
  Widget build(BuildContext context) {
    return ${0:const SizedBox.shrink()};
  }
}
]]),
    parse({ trig = "ctor", name = "Constructor", dscr = "Constructor with a required named field" }, [[
${1:ClassName}({required this.${2:value}});$0
]]),
    parse({ trig = "screen", name = "Flutter screen", dscr = "Stateless screen with Scaffold and AppBar" }, [[
class ${1:MyScreen} extends StatelessWidget {
  const $1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('${2:Title}')),
      body: ${0:const SizedBox.shrink()},
    );
  }
}
]]),
    parse({ trig = "afn", name = "Async function", dscr = "Async function with an awaited operation" }, [[
Future<${1:void}> ${2:loadData}(${3:}) async {
  ${0:await operation();}
}
]]),
    parse({ trig = "trya", name = "Await with error handling", dscr = "Try/catch around an awaited operation; rethrows by default" }, [[
try {
  ${1:await operation();}
} catch (error, stackTrace) {
  ${0:rethrow;}
}
]]),
    parse({ trig = "dgroup", name = "Dart test group", dscr = "Test group with setup, teardown and a first test" }, [[
group('${1:description}', () {
  setUp(() {
    ${2:// Initialize fixtures.}
  });

  tearDown(() {
    ${3:// Dispose fixtures.}
  });

  test('${4:works as expected}', () {
    ${0:expect(actual, expected);}
  });
});
]]),
    parse({ trig = "dtest", name = "Dart test", dscr = "Unit test" }, [[
test('${1:description}', () {
  ${0:expect(actual, expected);}
});
]]),
    parse({ trig = "wtest", name = "Widget test", dscr = "Flutter widget test" }, [[
testWidgets('${1:description}', (WidgetTester tester) async {
  await tester.pumpWidget(const ${2:MyWidget}());
  expect(find.byType($2), findsOneWidget);
  $0
});
]]),
}
