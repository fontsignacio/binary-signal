import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BinarySignalChart(),
    );
  }
}

class BinarySignalChart extends StatefulWidget {
  const BinarySignalChart({super.key});

  @override
  State<BinarySignalChart> createState() => _BinarySignalChartState();
}

class _BinarySignalChartState extends State<BinarySignalChart> {
  String binaryInput = '';
  List<double> signalData = [];
  List<double> signalDataDefault = [];
  String selectedSignalType = 'NRZ';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Binary Signal Chart'),
        backgroundColor: Colors.amber,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 30, bottom: 10, right: 10),
                  child: TextField(
                    style: const TextStyle(fontSize: 20),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-1]')),
                      LengthLimitingTextInputFormatter(8),
                    ],
                    onChanged: (value) {
                      setState(() {
                        binaryInput = value;
                        generateSignalData(binaryInput, selectedSignalType);
                        signalByDefault(binaryInput, selectedSignalType);
                      });
                    },
                    decoration:
                        const InputDecoration(labelText: 'Entrada Binaria'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: DropdownButton<String>(
                  dropdownColor: Colors.white,
                  value: selectedSignalType,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSignalType = newValue!;
                      generateSignalData(binaryInput, selectedSignalType);
                      signalByDefault(binaryInput, selectedSignalType);
                    });
                  },
                  items: <String>[
                    'NRZ',
                    'PolarNRZI',
                    'PolarRZ',
                    'Manchester',
                    'ManchesterDifferential',
                    'AMI',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('NRZ',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: LineChart(
                LineChartData(
                  titlesData: const FlTitlesData(
                      bottomTitles: AxisTitles(axisNameWidget: Text('')),
                      topTitles: AxisTitles(axisNameWidget: Text('')),
                      rightTitles: AxisTitles(axisNameWidget: Text(''))),
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: 0,
                        color: Colors.black.withOpacity(0.8),
                      ),
                    ],
                  ),
                  
                  lineBarsData: [
                    LineChartBarData(
                      dotData: const FlDotData(show: false),
                      color: Colors.red,
                      spots: signalDataDefault.asMap().entries.expand((entry) {
                        if (entry.key > 0 &&
                            signalDataDefault[entry.key - 1] != entry.value) {
                          return [
                            FlSpot(entry.key.toDouble() / 2,
                                signalDataDefault[entry.key - 1]),
                            FlSpot(entry.key.toDouble() / 2, entry.value)
                          ];
                        }
                        return [FlSpot(entry.key.toDouble() / 2, entry.value)];
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Visibility(
              visible: selectedSignalType != 'NRZ',
              child: Text(selectedSignalType,
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.bold))),
          Visibility(
            visible: selectedSignalType != 'NRZ',
            child: Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: LineChart(
                  LineChartData(
                    titlesData: const FlTitlesData(
                        bottomTitles: AxisTitles(axisNameWidget: Text('')),
                        topTitles: AxisTitles(axisNameWidget: Text('')),
                        rightTitles: AxisTitles(axisNameWidget: Text(''))),
                    extraLinesData: ExtraLinesData(
                      horizontalLines: [
                        HorizontalLine(
                          y: 0,
                          color: Colors.black.withOpacity(0.8),
                        ),
                      ],
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        dotData: const FlDotData(show: false),
                        color: Colors.red,
                        spots: signalData.asMap().entries.expand((entry) {
                          // Mapear puntos para mantener una línea horizontal en cambios de bit
                          if (entry.key > 0 &&
                              signalData[entry.key - 1] != entry.value) {
                            return [
                              FlSpot(entry.key.toDouble() / 2,
                                  signalData[entry.key - 1]),
                              FlSpot(entry.key.toDouble() / 2, entry.value)
                            ];
                          }
                          return [
                            FlSpot(entry.key.toDouble() / 2, entry.value)
                          ];
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  void generateSignalData(String binaryInput, String signalType) {
    List<int> binaryList = binaryInput.split('').map(int.parse).toList();
    switch (signalType) {
      case 'NRZ':
        signalData = generateNRZSignal(binaryList);
        break;
      case 'PolarNRZI':
        signalData = generatePolarNRZISignal(binaryList);
        break;
      case 'PolarRZ':
        signalData = generatePolarRZSignal(binaryList);
        break;
      case 'Manchester':
        signalData = generateManchesterSignal(binaryList);
        break;
      case 'ManchesterDifferential':
        signalData = generateManchesterDifferentialSignal(binaryList);
        break;
      case 'AMI':
        signalData = generateAMISignal(binaryList);
        break;
      default:
        signalData = generateNRZSignal(binaryList);
    }
  }

  List<double> signalByDefault(String binaryInput, String signalType) {
    List<int> binaryList = binaryInput.split('').map(int.parse).toList();
    signalDataDefault = generateNRZSignal(binaryList);
    return signalDataDefault;
  }

  List<double> generateNRZSignal(List<int> binaryList) {
    List<double> signal = [];
    for (int i = 0; i < binaryList.length; i++) {
      signal.add(binaryList[i] == 1 ? 1.0 : 0.0);
      if (i == binaryList.length - 1) {
        signal.add(binaryList[i] == 1 ? 1.0 : 0.0);
      }
    }
    return signal;
  }

  List<double> generatePolarNRZISignal(List<int> binaryList) {
    bool invert = false;
    List<double> signal = [];

    if (binaryList.isNotEmpty && binaryList[0] == 1) {
      invert = true;
    }

    for (int i = 0; i < binaryList.length; i++) {
      if (binaryList[i] == 1) invert = !invert;
      signal.add(invert ? -1.0 : 1.0);
      if (i == binaryList.length - 1) {
        signal.add(invert ? -1.0 : 1.0);
      }
    }

    return signal;
  }

  List<double> generatePolarRZSignal(List<int> binaryList) {
    List<double> signal = [];
    for (int i = 0; i < binaryList.length; i++) {
      signal.add(binaryList[i] == 1 ? 1.0 : -1.0);
      signal.add(0.0);
      if (i == binaryList.length - 1) signal.add(0.0);
    }
    return signal;
  }

  List<double> generateManchesterSignal(List<int> binaryList) {
    List<double> signal = [];
    for (int i = 0; i < binaryList.length; i++) {
      signal.addAll(binaryList[i] == 0 ? [1.0, -1.0] : [-1.0, 1.0]);
      if (i == binaryList.length - 1) {
        signal.add(binaryList[i] == 0 ? 1.0 : -1.0);
      }
    }
    return signal;
  }

  List<double> generateManchesterDifferentialSignal(List<int> binaryList) {
    List<double> signal = [];
    bool positive = binaryList.isNotEmpty ? binaryList[0] == 1 : true;

    for (int i = 0; i < binaryList.length; i++) {
      if (binaryList[i] == 0) {
        signal.add(positive ? 1.0 : -1.0);
      } else {
        if (i == 0) signal.add(1.0);
        positive = !positive;
        signal.add(positive ? 1.0 : -1.0);
      }
      signal.add(positive ? -1.0 : 1.0);
    }
    return signal;
  }

  List<double> generateAMISignal(List<int> binaryList) {
    List<double> signal = [];
    bool positive = true;

    for (int i = 0; i < binaryList.length; i++) {
      if (binaryList[i] == 0) {
        signal.add(0.0);
      } else {
        signal.add(positive ? 1.0 : -1.0);
        positive = !positive;
      }
      if (i == binaryList.length - 1) signal.add(0.0);
    }
    return signal;
  }

}
