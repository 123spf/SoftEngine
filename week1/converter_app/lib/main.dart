import 'package:flutter/material.dart';
import 'util/conversion.dart';

void main() {
  runApp(const MyApp());
}

/// The root widget of the unit converter application.
///
/// This widget sets up the [MaterialApp], defines the initial route to
/// [MyHomePage], and establishes the global application theme.
class MyApp extends StatelessWidget {
  /// Creates the main application widget.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme appColorScheme =
    ColorScheme.fromSeed(seedColor: Colors.blue);
    return MaterialApp(
      title: 'Unit Converter App',
      theme: ThemeData(
        colorScheme: appColorScheme,
        appBarTheme: AppBarTheme(
          backgroundColor: appColorScheme.inversePrimary,
          foregroundColor: appColorScheme.inverseSurface,
        ),
      ),
      home: const MyHomePage(title: 'Unit Converter'),
    );
  }
}

/// The main screen of the unit converter application.
///
/// This widget displays input fields for the value and units to be converted,
/// a button to trigger the conversion, and an area to show the conversion
/// result or any relevant messages. It is a [StatefulWidget] because its
/// content changes based on user interaction.
class MyHomePage extends StatefulWidget {
  /// Creates the main page widget.
  const MyHomePage({super.key, required this.title});

  /// The title displayed in the [AppBar] of this screen.
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// Manages the state for [MyHomePage].
///
/// This class holds the mutable data for the unit converter, such as the
/// input number, selected units, and the result text. It also contains the
/// logic for handling user input and performing conversions.
class _MyHomePageState extends State<MyHomePage> {
  /// The numeric value entered by the user to be converted.
  ///
  /// This value is updated via the [_valueController]. It is `null` if the
  /// input is empty or invalid.
  double? _startNum;

  /// The unit from which the conversion will start.
  late Unit _startUnit;

  /// The unit to which the value will be converted.
  late Unit _targetUnit;

  /// The text displayed to the user, showing the result of a conversion,
  /// an instructional message, or an error message.
  String _resultText = '';

  /// A controller for the [TextField] where the user inputs the numeric value.
  late TextEditingController _valueController;

  static const String _kPleaseEnterValue = 'Please enter a value.';
  static const String _kInvalidInputValue =
      'Invalid value, please only enter numbers.';
  static const String _kValueCannotBeZero =
      'Enter a number greater than zero.';

  /// A list of all available units for the dropdown menus.
  final List<Unit> _allUnits = Unit.values;

  @override
  void initState() {
    super.initState();
    _valueController = TextEditingController();
    _startUnit = _allUnits[0];
    _targetUnit = _allUnits[4];

    // Listen to text changes for real-time validation.
    _valueController.addListener(_onTextFieldChanged);
  }

  @override
  void dispose() {
    _valueController.removeListener(_onTextFieldChanged);
    _valueController.dispose();
    super.dispose();
  }

  /// A callback invoked when the text in the input field changes.
  ///
  /// Parses the input text, updates [_startNum], and provides immediate
  /// validation feedback by updating [_resultText].
  void _onTextFieldChanged() {
    final text = _valueController.text;
    final userInput = double.tryParse(text);

    setState(() {
      if (userInput != null && userInput != 0) {
        _startNum = userInput;
        if (_resultText == _kInvalidInputValue ||
            _resultText == _kValueCannotBeZero) {
          _resultText = '';
        }
      } else {
        _startNum = null;

        if (text.isEmpty) {
          if (_resultText == _kInvalidInputValue ||
              _resultText == _kValueCannotBeZero) {
            _resultText = '';
          }
        } else if (userInput == 0) {
          _resultText = _kValueCannotBeZero;
        } else {
          _resultText = _kInvalidInputValue;
        }
      }
    });
  }

  /// Attempts to convert the current [_startNum] from [_startUnit] to
  /// [_targetUnit].
  ///
  /// This method is called when the user presses the "Convert" button. It
  /// updates [_resultText] with the outcome of the conversion or an
  /// appropriate error message.
  void convert() {
    if (_startNum == null) {
      setState(() {
        if (_valueController.text.isEmpty && _resultText.isEmpty) {
          _resultText = _kPleaseEnterValue;
        }
      });
      return;
    }

    try {
      final double result =
      Conversion.convert(_startNum!, _startUnit, _targetUnit);

      setState(() {
        _resultText =
        '${_startNum!.toString()} ${_startUnit.name} are ${result.toStringAsFixed(4)} ${_targetUnit.name}';
      });
    } on IncompatibleUnitsException catch (e) {
      setState(() {
        _resultText = e.message;
      });
    } on ConversionSetupException catch (e, s) {
      setState(() {
        _resultText = "An unexpected error occurred during conversion setup.";
      });
      debugPrint("CONVERSION SETUP ERROR: $e\nStack trace:\n$s");
    } catch (e, s) {
      setState(() {
        _resultText = "An unexpected error occurred during conversion.";
      });
      debugPrint("UNEXPECTED CONVERSION ERROR: $e\nStack trace:\n$s");
    }
  }

  /// Builds the UI section for user input of the numeric value.
  Widget _buildValueInputSection(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          'Value',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextField(
          controller: _valueController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            hintText: 'Enter a number',
          ),
        ),
      ],
    );
  }

  /// Builds the UI section for selecting the unit to convert from.
  Widget _buildFromUnitSection(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          'From',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        DropdownMenu<Unit>(
            requestFocusOnTap: false,
            enableSearch: false,
            initialSelection: _startUnit,
            dropdownMenuEntries: _allUnits.map((Unit unitValue) {
              return DropdownMenuEntry<Unit>(
                value: unitValue,
                label: unitValue.name,
              );
            }).toList(),
            onSelected: (unitValue) {
              setState(() {
                if (_resultText.startsWith("Cannot convert from")) {
                  _resultText = '';
                }
                _startUnit = unitValue!;
              });
            }),
      ],
    );
  }

  /// Builds the UI section for selecting the unit to convert to.
  Widget _buildToUnitSection(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          'To',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        DropdownMenu<Unit>(
            requestFocusOnTap: false,
            enableSearch: false,
            initialSelection: _targetUnit,
            dropdownMenuEntries: _allUnits.map((Unit unitValue) {
              return DropdownMenuEntry<Unit>(
                value: unitValue,
                label: unitValue.name,
              );
            }).toList(),
            onSelected: (unitValue) {
              setState(() {
                if (_resultText.startsWith("Cannot convert from")) {
                  _resultText = '';
                }
                _targetUnit = unitValue!;
              });
            }),
      ],
    );
  }

  /// Builds the "Convert" button.
  Widget _buildConvertButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          foregroundColor: Theme.of(context).colorScheme.inverseSurface,
          minimumSize: const Size(double.minPositive, 50),
          textStyle: const TextStyle(fontSize: 23)),
      onPressed: convert,
      child: const Text('Convert'),
    );
  }

  /// Builds the [Text] widget that displays the conversion result or messages.
  Widget _buildResultText(BuildContext context) {
    return Text(
      _resultText,
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: Text(widget.title),
      centerTitle: true,
    );

    return Scaffold(
      appBar: appBar,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 8),
                _buildValueInputSection(context),
                const SizedBox(height: 30),
                _buildFromUnitSection(context),
                const SizedBox(height: 12),
                _buildToUnitSection(context),
                const SizedBox(height: 30),
                _buildConvertButton(context),
                const SizedBox(height: 30),
                _buildResultText(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
