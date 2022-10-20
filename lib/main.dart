import 'dart:developer';
import 'dart:html' as html;

import 'package:blockchain_week4_exercise2/meta_info.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_web3/flutter_web3.dart';

void main() {
  runApp(const MyApp());
}

enum ChosenMethod {
  approve,
  decreaseAllowance,
  increaseAllowance,
  transfer,
  allowance,
  balanceOf,
  transferFrom,
}

const Map<ChosenMethod, List<String>> _methodToHint = {
  ChosenMethod.approve: ['spender', 'amount'],
  ChosenMethod.decreaseAllowance: ['spender', 'subtractedValue'],
  ChosenMethod.increaseAllowance: ['spender', 'addedValue'],
  ChosenMethod.transfer: ['to', 'amount'],
  ChosenMethod.allowance: ['owner', 'spender'],
  ChosenMethod.balanceOf: ['account'],
  ChosenMethod.transferFrom: ['from', 'to', 'amount'],
};

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return NeumorphicApp(
      title: 'g.osotov',
      home: const MyHomePage(),
      themeMode: ThemeMode.light,
      theme: NeumorphicThemeData(
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
        baseColor: const Color(0xFFFFFFFF),
        lightSource: LightSource.topLeft,
        depth: 10,
      ),
      darkTheme: NeumorphicThemeData(
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
        baseColor: const Color(0xFF3E3E3E),
        lightSource: LightSource.topLeft,
        depth: 6,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void setupEth() async {
    // From RPC
    final web3provider = Web3Provider(ethereum!);

    busd = Contract(
      contractAddress,
      Interface(abi),
      web3provider.getSigner(),
    );

    try {
      // Prompt user to connect to the provider, i.e. confirm the connection modal
      final accs =
          await ethereum!.requestAccount(); // Get all accounts in node disposal
      accs; // [foo,bar]
    } on EthereumUserRejected {
      log('User rejected the modal');
    }
  }

  late Contract busd;

  @override
  void initState() {
    setupEth();
    super.initState();
  }

  void showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void callReadOnlyMethod(String method, List<dynamic> args) async {
    try {
      final result = await busd.call(method, args);
      showToast(result.toString());
    } catch (e) {
      showToast(e.toString());
    }
  }

  void callPayableMethod(String method, List<dynamic> args) async {
    final navigator = Navigator.of(context);
    try {
      final send = await busd.send(method, args);
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(
                child: SizedBox(
                  height: 10,
                  width: 300,
                  child: NeumorphicProgressIndeterminate(),
                ),
              ));
      final result = await send.wait();
      navigator.pop();
      showToast(result.logs.toString());
    } catch (e) {
      showToast(e.toString());
    }
  }

  ChosenMethod _chosenMethod = ChosenMethod.values.first;

  late final TextEditingController _controller1 = TextEditingController();
  late final TextEditingController _controller2 = TextEditingController();
  late final TextEditingController _controller3 = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeumorphicColors.background,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Neumorphic(
              style: const NeumorphicStyle(
                  color: NeumorphicColors.background,
                  shape: NeumorphicShape.flat),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NeumorphicText(
                      'Simple methods',
                      style: const NeumorphicStyle(
                        shape: NeumorphicShape.flat,
                        color: NeumorphicColors.background,
                        depth: 3,
                        shadowLightColor: Colors.white,
                        shadowDarkColor: Colors.black,
                      ),
                      textStyle: NeumorphicTextStyle(
                          fontSize: 50, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        'totalSupply',
                        'name',
                        'symbol',
                        'decimals',
                      ]
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: NeumorphicButton(
                                onPressed: () async {
                                  final navigator = Navigator.of(context);
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (_) => Center(
                                            child: SizedBox(
                                              height: 10,
                                              width: 300,
                                              child:
                                                  NeumorphicProgressIndeterminate(
                                                style: ProgressStyle(depth: 3),
                                              ),
                                            ),
                                          ));
                                  final result = await busd.call(e);

                                  navigator.pop();
                                  showToast(result.toString());
                                },
                                child: Text(e),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Neumorphic(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NeumorphicText(
                      'Methods with parameters',
                      style: const NeumorphicStyle(
                        shape: NeumorphicShape.flat,
                        depth: 3,
                        shadowLightColor: Colors.white,
                        shadowDarkColor: Colors.black,
                      ),
                      textStyle: NeumorphicTextStyle(
                          fontSize: 50, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 100,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: ChosenMethod.values
                              .map(
                                (e) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: NeumorphicRadio<ChosenMethod>(
                                    onChanged: (value) => setState(() {
                                      _chosenMethod = value!;
                                    }),
                                    value: e,
                                    groupValue: _chosenMethod,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(e
                                          .toString()
                                          .replaceAll('ChosenMethod.', '')),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 300,
                      // height: 300,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: _methodToHint[_chosenMethod]!.isNotEmpty
                                  ? 1
                                  : 0,
                              child: Neumorphic(
                                child: TextField(
                                  controller: _controller1,
                                  decoration: InputDecoration(
                                    hintText:
                                        (_methodToHint[_chosenMethod]!.length >=
                                                1)
                                            ? _methodToHint[_chosenMethod]![0]
                                            : '',
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: _methodToHint[_chosenMethod]!.length >= 2
                                  ? 1
                                  : 0,
                              child: Neumorphic(
                                child: TextField(
                                  controller: _controller2,
                                  decoration: InputDecoration(
                                    hintText:
                                        (_methodToHint[_chosenMethod]!.length >=
                                                2)
                                            ? _methodToHint[_chosenMethod]![1]
                                            : '',
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: _methodToHint[_chosenMethod]!.length >= 3
                                  ? 1
                                  : 0,
                              child: Neumorphic(
                                child: TextField(
                                  controller: _controller3,
                                  decoration: InputDecoration(
                                    hintText:
                                        (_methodToHint[_chosenMethod]!.length >=
                                                3)
                                            ? _methodToHint[_chosenMethod]![2]
                                            : '',
                                  ),
                                ),
                              ),
                            ),
                          ),
                          NeumorphicButton(
                            onPressed: () {
                              switch (_chosenMethod) {
                                case ChosenMethod.approve:
                                  callPayableMethod('approve',
                                      [_controller1.text, _controller2.text]);
                                  break;
                                case ChosenMethod.decreaseAllowance:
                                  callPayableMethod('decreaseAllowance',
                                      [_controller1.text, _controller2.text]);
                                  break;
                                case ChosenMethod.increaseAllowance:
                                  callPayableMethod('increaseAllowance',
                                      [_controller1.text, _controller2.text]);
                                  break;
                                case ChosenMethod.transfer:
                                  callPayableMethod('transfer', [
                                    _controller1.text,
                                    _controller2.text,
                                  ]);
                                  break;
                                case ChosenMethod.allowance:
                                  callReadOnlyMethod('allowance',
                                      [_controller1.text, _controller2.text]);
                                  break;
                                case ChosenMethod.balanceOf:
                                  callReadOnlyMethod(
                                      'balanceOf', [_controller1.text]);
                                  break;
                                case ChosenMethod.transferFrom:
                                  callPayableMethod('transferFrom', [
                                    _controller1.text,
                                    _controller2.text,
                                    _controller3.text,
                                  ]);
                                  break;
                              }
                            },
                            child: Text(
                                'Call ${_chosenMethod.toString().replaceAll('ChosenMethod.', '')}'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            NeumorphicButton(
              onPressed: () => html.window.open(
                  'https://goerli.etherscan.io/address/${contractAddress}',
                  'new tab'),
              child: const Text('Open EtherScan to view history'),
            )
          ],
        ),
      ),
    );
  }
}
