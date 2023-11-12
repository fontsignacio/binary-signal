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
  String selectedSignalType = 'NRZ'; // Inicialmente selecciona NRZ

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Binary Signal Chart'),
        backgroundColor: Colors.amber,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-1]'))],
              onChanged: (value) {
                setState(() {
                  binaryInput = value;
                  generateSignalData(binaryInput, selectedSignalType);
                });
              },
              decoration: const InputDecoration(labelText: 'Entrada Binaria'),
            ),
          ),
          // Agrega un Dropdown para seleccionar el tipo de señal
          DropdownButton<String>(
            value: selectedSignalType,
            onChanged: (String? newValue) {
              setState(() {
                selectedSignalType = newValue!;
                generateSignalData(binaryInput, selectedSignalType);
              });
            },
            items: <String>[
              'NRZ',
              'PolarNRZI',
              'PolarRZ',
              'Manchester',
              'ManchesterDifferential',
              'AMI',
              'B8ZS',
              'HDB3'
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: LineChart(
            LineChartData(
              titlesData: const FlTitlesData(
                topTitles: AxisTitles(
                  axisNameWidget: Text(''),
                ),
                rightTitles: AxisTitles(
                  axisNameWidget: Text('')
                )
              ),
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
                  color: Colors.red,
                  spots: signalData
                      .asMap()
                      .entries
                      .expand((entry) {
                        // Mapear puntos para mantener una línea horizontal en cambios de bit
                        if (entry.key > 0 && signalData[entry.key - 1] != entry.value) {
                          return [
                            FlSpot(entry.key.toDouble() / 2, signalData[entry.key - 1] * 5),
                            FlSpot(entry.key.toDouble() / 2, entry.value * 5)
                          ];
                        }
                        return [FlSpot(entry.key.toDouble() / 2, entry.value * 5)];
                      }).toList(),
                ),
              ],
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
        break;/*
      case 'B8ZS':
        signalData = generateB8ZSSignal(binaryList);
        break;
      case 'HDB3':
        signalData = generateHDB3Signal(binaryList);
        break; */
      default:
        // Implementación de señal por defecto (NRZ)
        signalData = generateNRZSignal(binaryList);
    }
  }

  List<double> generateNRZSignal(List<int> binaryList) {
    List<double> signal = [];
    for (int i = 0; i < binaryList.length; i++) {
      signal.add(binaryList[i] == 1 ? 1.0 : 0.0);
      signal.add(binaryList[i] == 1 ? 1.0 : 0.0);
      if (i + 1 < binaryList.length && binaryList[i] != binaryList[i + 1]) {
        signal.add(binaryList[i] == 1 ? 1.0 : 0.0);
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
      if (binaryList[i] == 1) {
        invert = !invert;
      }
      
      if (invert) {
        signal.addAll(List.filled(4, -1.0));
      } else {
        signal.addAll(List.filled(4, 1.0));
      }
    }

    return signal;
  }

  List<double> generatePolarRZSignal(List<int> binaryList) {
    List<double> signal = [];
    for (int bit in binaryList) {
      if (bit == 1) {
        signal.addAll([1.0, 1.0, 0.0]);
      } else {
        signal.addAll([-1.0, -1.0, 0.0]);
      }
    }
    return signal;
  }

  List<double> generateManchesterSignal(List<int> binaryList) {
    List<double> signal = [];

    for (int i = 0; i < binaryList.length; i++) {
      // Para bit 0, transición de voltaje de positivo a negativo (de 1 a -1)
      if (binaryList[i] == 0) {
        signal.addAll([1.0, -1.0]);
      } else {
        // Para bit 1, transición de voltaje de negativo a positivo (de -1 a 1)
        signal.addAll([-1.0, 1.0]);
      }
    }
    return signal;
  }


List<double> generateManchesterDifferentialSignal(List<int> binaryList) {
  List<double> signal = [];
  bool positive = binaryList.isNotEmpty? binaryList[0] == 1 : true;

  for (int i = 0; i < binaryList.length; i++) {
    if (binaryList[i] == 0) {
      // Transición continua para el bit 0
      signal.add(positive ? 1.0 : -1.0); // Cambia al voltaje opuesto
    } else {
      if(i == 0) signal.add(1.0);
      // Transición solo a la mitad del intervalo de tiempo para el bit 1
      positive = !positive; // Invierte el nivel de voltaje a mitad de bit
      signal.add(positive ? 1.0 : -1.0); // Cambia a voltaje opuesto a mitad de bit
    }
    // Mantiene el mismo voltaje para la segunda mitad del bit
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
      // Añadir un 0 adicional para el último dígito 0 en la cadena
      if (i == binaryList.length - 1 && binaryList[i] == 0) {
        signal.add(0.0);
      }
    }
    return signal;
  }

}