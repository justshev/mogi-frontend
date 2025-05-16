import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:jamur/screens/analysis_screen.dart';
import 'package:jamur/screens/history_screen.dart';
import 'package:jamur/widgets/sensor_card.dart';
import 'package:jamur/widgets/health_card.dart';

import 'package:jamur/models/sensor_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:jamur/pages/login_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late WebSocketChannel channel;
  String latestData = "Waiting for data...";
  int _currentCarouselIndex = 0;
  int _currentNavIndex = 0; // For BottomNavigationBar
  final PageController _pageController = PageController(
    initialPage: 0,
    viewportFraction: 0.92,
  );
  String _userName = "User";
  bool _isLoading = true;
  bool _isWebSocketConnected = false;
  DateTime _lastConnectionAttempt = DateTime.now();
  int _reconnectAttempts = 0;

  @override
  void initState() {
    super.initState();

    _fetchUserData();
    _connectWebSocket();
  }

  // Function to handle BottomNavigationBar navigation
  void _onItemTapped(int index) {
    // If user taps the already active tab, do nothing
    if (_currentNavIndex == index) return;

    setState(() {
      _currentNavIndex = index;
    });

    // Navigate to the appropriate page
    switch (index) {
      case 0: // Home (already on this page)
        break;
      case 1: // Analysis
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AnalysisScreen()),
        ).then((_) {
          // When returning from analysis screen, set index back to home
          setState(() {
            _currentNavIndex = 0;
          });
        });
        break;
      case 2: // History/Profile
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HistoryScreen()),
        ).then((_) {
          // When returning from profile screen, set index back to home
          setState(() {
            _currentNavIndex = 0;
          });
        });
        break;
    }
  }

  void _connectWebSocket() {
    // Prevent too many reconnection attempts in a short time
    final now = DateTime.now();
    if (now.difference(_lastConnectionAttempt).inSeconds < 3 &&
        _reconnectAttempts > 0) {
      Future.delayed(const Duration(seconds: 3), _connectWebSocket);
      return;
    }

    _lastConnectionAttempt = now;
    _reconnectAttempts++;

    setState(() {
      latestData = "Connecting to server...";
    });

    try {
      // Replace with your WebSocket server URL
      channel = WebSocketChannel.connect(
        Uri.parse(
          // 'ws://192.168.1.5:3000',
          'ws://192.168.0.112:3000',
        ), // Adjust to your WebSocket server address
      );

      channel.stream.listen(
        (data) {
          setState(() {
            _isWebSocketConnected = true;
            latestData = data;
            print('Received from WebSocket: $data');

            // If data is JSON, parse and update sensor data
            try {
              Map<String, dynamic> jsonData = jsonDecode(data);
              print('Parsed JSON data: $jsonData'); // Debug log

              // Example: update sensor data based on WebSocket data
              if (jsonData.containsKey('temperature') &&
                  jsonData.containsKey('humidity')) {
                print(
                  'Updating sensor with: Temp=${jsonData['temperature']}, Humidity=${jsonData['humidity']}',
                );

                // Handle various data types (number or string)
                try {
                  double temp =
                      jsonData['temperature'] is num
                          ? (jsonData['temperature'] as num).toDouble()
                          : double.parse(jsonData['temperature'].toString());

                  double humid =
                      jsonData['humidity'] is num
                          ? (jsonData['humidity'] as num).toDouble()
                          : double.parse(jsonData['humidity'].toString());

                  print('Converted values: Temp=$temp, Humidity=$humid');
                  _updateSensorData(temperature: temp, humidity: humid);
                } catch (e) {
                  print('Error converting values: $e');
                }
              } else {
                print(
                  'JSON data does not contain temperature/humidity: $jsonData',
                );
              }

              // Update device status if available
              if (jsonData.containsKey('status')) {
                _updateDeviceStatus(jsonData['status']);
              }

              // Reset reconnect counter when successfully receiving data
              _reconnectAttempts = 0;
            } catch (e) {
              print('Error parsing WebSocket data: $e');
            }
          });
        },
        onError: (error) {
          print("WebSocket error: $error");
          setState(() {
            _isWebSocketConnected = false;
            latestData = "Connection error: $error. Trying to reconnect...";
          });
          // Reconnect with delay
          Future.delayed(const Duration(seconds: 3), _connectWebSocket);
        },
        onDone: () {
          print("WebSocket connection closed");
          setState(() {
            _isWebSocketConnected = false;
            latestData = "Connection lost. Trying to reconnect...";
          });
          // Reconnect with delay
          Future.delayed(const Duration(seconds: 3), _connectWebSocket);
        },
      );
    } catch (e) {
      print("Error connecting to WebSocket: $e");
      setState(() {
        _isWebSocketConnected = false;
        latestData = "Connection failed: $e. Trying to reconnect...";
      });
      // Reconnect with delay
      Future.delayed(const Duration(seconds: 5), _connectWebSocket);
    }
  }

  void _updateSensorData({
    required double temperature,
    required double humidity,
  }) {
    print('Updating sensor data: T=$temperature, H=$humidity'); // Debug log

    // Update sensor data with new values
    setState(() {
      _sensorData[0] = SensorData(
        id: 1,
        name: 'Temperature',
        value: temperature,
        unit: '°C',
        icon: Icons.thermostat,
        color: Colors.red,
        status: _getSensorStatus(temperature, 'temperature'),
        lastUpdated: DateTime.now(),
      );

      _sensorData[1] = SensorData(
        id: 2,
        name: 'Humidity',
        value: humidity,
        unit: '%',
        icon: Icons.water_drop,
        color: Colors.blue,
        status: _getSensorStatus(humidity, 'humidity'),
        lastUpdated: DateTime.now(),
      );

      // Update health data based on sensors
      _updateHealthData(temperature, humidity);
    });
  }

  void _updateHealthData(double temperature, double humidity) {
    // Simple logic to determine mushroom health
    String healthStatus;
    String prediction;
    String quality;

    // Evaluate growth conditions based on temperature and humidity
    if (temperature >= 20 &&
        temperature <= 28 &&
        humidity >= 80 &&
        humidity <= 90) {
      healthStatus = 'Excellent';
      prediction = '7 Days Left';
      quality = 'Premium';
    } else if (temperature >= 18 &&
        temperature <= 30 &&
        humidity >= 75 &&
        humidity <= 95) {
      healthStatus = 'Good';
      prediction = '10 Days Left';
      quality = 'Standard';
    } else {
      healthStatus = 'Needs Attention';
      prediction = 'Adjustment Required';
      quality = 'Below Standard';
    }

    setState(() {
      _healthData = [
        {
          'title': 'Mushroom Health',
          'status': healthStatus,
          'description': 'Based on current environmental conditions',
          'icon': Icons.check_circle,
          'color':
              healthStatus == 'Excellent'
                  ? Colors.green
                  : healthStatus == 'Good'
                  ? Colors.lightGreen
                  : Colors.orange,
        },
        {
          'title': 'Harvest Prediction',
          'status': prediction,
          'description': 'Estimated harvest time based on growth data',
          'icon': Icons.calendar_today,
          'color': Colors.blue,
        },
        {
          'title': 'Mushroom Quality',
          'status': quality,
          'description': 'Based on current growth parameters',
          'icon': Icons.star,
          'color':
              quality == 'Premium'
                  ? Colors.amber
                  : quality == 'Standard'
                  ? Colors.lightBlue
                  : Colors.grey,
        },
      ];
    });
  }

  // Device status
  bool _heaterConnected = true;
  bool _humidifierConnected = true;
  bool _lightConnected = false;

  void _updateDeviceStatus(Map<String, dynamic> statusData) {
    setState(() {
      _heaterConnected = statusData['heater'] == 'on';
      _humidifierConnected = statusData['humidifier'] == 'on';
      _lightConnected = statusData['light'] == 'on';
    });
  }

  String _getSensorStatus(double value, String type) {
    if (type == 'temperature') {
      if (value < 20) return 'Low';
      if (value > 30) return 'High';
      return 'Normal';
    } else if (type == 'humidity') {
      if (value < 70) return 'Low';
      if (value > 90) return 'High';
      return 'Normal';
    }
    return 'Normal';
  }

  @override
  void dispose() {
    try {
      channel.sink.close();
    } catch (e) {
      print('Error closing WebSocket: $e');
    }
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('idToken') ?? '';
      final uid = prefs.getString('uid') ?? '';
      final userName = prefs.getString('userName') ?? '';

      if (token.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        _redirectToLogin();
        return;
      }

      // Replace URL with your user profile API endpoint
      final response = await http.get(
        Uri.parse(
          'https://c969-149-113-224-229.ngrok-free.app/api/prediksi-jamur/history',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Log data
        print('User data: $data');

        // Log user ID
        print('User ID: $uid');
        print('User name: $userName');
        setState(() {
          // Adjust according to your API response
          _userName = data['userName'] ?? uid.split('@')[0];
          _isLoading = false;
        });

        // Save user name for use elsewhere
        await prefs.setString('userName', _userName);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Invalid token
        await _handleInvalidToken();
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleInvalidToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('idToken');
    await prefs.remove('uid');
    await prefs.remove('userName');
    setState(() {
      _isLoading = false;
    });
    _redirectToLogin();
  }

  void _redirectToLogin() {
    Future.delayed(Duration.zero, () {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder:
                (context) => LoginPage(
                  onLoginSuccess: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  },
                ),
          ),
          (route) => false, // Remove all previous pages from stack
        );
      }
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    String greeting = '';

    if (hour < 12) {
      greeting = 'Morning';
    } else if (hour < 15) {
      greeting = 'Good Evening';
    } else if (hour < 19) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Night';
    }

    return '$greeting, $_userName';
  }

  // Add refresh function to update data
  Future<void> _refreshData() async {
    await _fetchUserData();

    // Reconnect WebSocket if needed
    if (!_isWebSocketConnected) {
      try {
        channel.sink.close();
      } catch (e) {
        print('Error closing channel: $e');
      }
      _connectWebSocket();
    }

    // Show notification if still not connected
    Future.delayed(const Duration(seconds: 2), () {
      if (!_isWebSocketConnected && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.cloud_off, color: Colors.white),
                SizedBox(width: 16),
                Text('Sensor not connected'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Try Again',
              textColor: Colors.white,
              onPressed: () {
                _connectWebSocket();
              },
            ),
          ),
        );
      }
    });
  }

  // Sample data to be updated based on sensors
  List<Map<String, dynamic>> _healthData = [
    {
      'title': 'Mushroom Health',
      'status': 'Waiting for Data',
      'description': 'Mushroom growth in optimal conditions',
      'icon': Icons.check_circle,
      'color': Colors.grey,
    },
    {
      'title': 'Harvest Prediction',
      'status': 'Waiting for Data',
      'description': 'Estimated harvest time based on growth data',
      'icon': Icons.calendar_today,
      'color': Colors.grey,
    },
    {
      'title': 'Mushroom Quality',
      'status': 'Waiting for Data',
      'description': 'Based on current growth parameters',
      'icon': Icons.star,
      'color': Colors.grey,
    },
  ];

  List<SensorData> _sensorData = [
    SensorData(
      id: 1,
      name: 'Temperature',
      value: 0,
      unit: '°C',
      icon: Icons.thermostat,
      color: Colors.red,
      status: 'Normal',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    SensorData(
      id: 2,
      name: 'Humidity',
      value: 0,
      unit: '%',
      icon: Icons.water_drop,
      color: Colors.blue,
      status: 'Normal',
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getGreeting(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 248, 248, 248),
        centerTitle: false,
        actions: [
          // WebSocket connection status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Icon(
                  _isWebSocketConnected ? Icons.wifi : Icons.wifi_off,
                  color: _isWebSocketConnected ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _isWebSocketConnected ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: _isWebSocketConnected ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _refreshData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display latest WebSocket data for debugging
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _isWebSocketConnected
                                          ? Icons.wifi
                                          : Icons.wifi_off,
                                      color:
                                          _isWebSocketConnected
                                              ? Colors.green
                                              : Colors.red,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Realtime Status:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            _isWebSocketConnected
                                                ? Colors.black
                                                : Colors.red,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      DateFormat(
                                        'HH:mm:ss',
                                      ).format(DateTime.now()),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _isWebSocketConnected
                                      ? 'Connected to realtime server'
                                      : 'Not connected to realtime server',
                                  style: TextStyle(
                                    color:
                                        _isWebSocketConnected
                                            ? Colors.green
                                            : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Health Status Carousel
                      Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Text(
                                'Growth Status',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Add left padding to carousel to align with title
                            Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: SizedBox(
                                height: 180,
                                child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: _healthData.length,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentCarouselIndex = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    final item = _healthData[index];
                                    return Padding(
                                      padding: EdgeInsets.only(right: 16.0),
                                      child: Stack(
                                        children: [
                                          HealthCard(
                                            title: item['title'],
                                            status:
                                                _isWebSocketConnected
                                                    ? item['status']
                                                    : 'Not Connected',
                                            description: item['description'],
                                            icon: item['icon'],
                                            color:
                                                _isWebSocketConnected
                                                    ? item['color']
                                                    : Colors.grey,
                                          ),
                                          if (!_isWebSocketConnected)
                                            Positioned.fill(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.4),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: Center(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: const [
                                                      Icon(
                                                        Icons.cloud_off,
                                                        color: Colors.white,
                                                        size: 32,
                                                      ),
                                                      SizedBox(height: 8),
                                                      Text(
                                                        "Not Connected",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:
                                  _healthData.asMap().entries.map((entry) {
                                    return GestureDetector(
                                      onTap:
                                          () => _pageController.animateToPage(
                                            entry.key,
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            curve: Curves.easeInOut,
                                          ),
                                      child: Container(
                                        width: 12.0,
                                        height: 12.0,
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                          horizontal: 4.0,
                                        ),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: (Theme.of(
                                                        context,
                                                      ).brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black)
                                              .withOpacity(
                                                _currentCarouselIndex ==
                                                        entry.key
                                                    ? 0.9
                                                    : 0.4,
                                              ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ],
                        ),
                      ),

                      // Sensor Data Section
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sensor Data',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Adjust the aspect ratio to give more height to the cards
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio:
                                        1.1, // Adjusted for more height
                                  ),
                              itemCount: _sensorData.length,
                              itemBuilder: (context, index) {
                                final sensor = _sensorData[index];
                                return Stack(
                                  children: [
                                    SensorCard(
                                      sensorData: sensor,
                                      onTap: () {
                                        // Show detailed sensor data
                                        _showSensorDetails(sensor);
                                      },
                                    ),
                                    if (!_isWebSocketConnected)
                                      Positioned.fill(
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              _showSensorDetails(sensor);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(
                                                  0.6,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: const [
                                                    Icon(
                                                      Icons.cloud_off,
                                                      color: Colors.white,
                                                      size: 32,
                                                    ),
                                                    SizedBox(height: 8),
                                                    Text(
                                                      "Not Connected",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Prediction Chart

                      // Device Status
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Device Status',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    _buildDeviceStatusItem(
                                      'Sensor Hub',
                                      _isWebSocketConnected,
                                      _isWebSocketConnected
                                          ? 'Connected'
                                          : 'Not Connected',
                                      Icons.router,
                                    ),
                                    const Divider(),
                                    _buildDeviceStatusItem(
                                      'Temperature Controller',
                                      _isWebSocketConnected && _heaterConnected,
                                      !_isWebSocketConnected
                                          ? 'Not Connected'
                                          : (_heaterConnected
                                              ? 'Active'
                                              : 'Inactive'),
                                      Icons.thermostat,
                                    ),
                                    const Divider(),
                                    _buildDeviceStatusItem(
                                      'Humidity Controller',
                                      _isWebSocketConnected &&
                                          _humidifierConnected,
                                      !_isWebSocketConnected
                                          ? 'Not Connected'
                                          : (_humidifierConnected
                                              ? 'Active'
                                              : 'Inactive'),
                                      Icons.water,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped, // Use the navigation function created earlier
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analysis',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }

  void _showSensorDetails(SensorData sensor) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      sensor.icon,
                      color: _isWebSocketConnected ? sensor.color : Colors.grey,
                      size: 36,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      sensor.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _isWebSocketConnected
                        ? Text(
                          '${sensor.value.toStringAsFixed(1)}${sensor.unit}',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: sensor.color,
                          ),
                        )
                        : Column(
                          children: const [
                            Icon(Icons.cloud_off, color: Colors.grey, size: 40),
                            SizedBox(height: 8),
                            Text(
                              "Not Connected",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSensorDetailItem(
                      'Status',
                      _isWebSocketConnected ? sensor.status : "Not Available",
                    ),
                    _buildSensorDetailItem(
                      'Last Update',
                      _isWebSocketConnected
                          ? DateFormat('HH:mm:ss').format(sensor.lastUpdated)
                          : "No Data Yet",
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Information:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  sensor.name == 'Temperature'
                      ? 'Optimal temperature for mushroom growth is 20-28°C. Temperatures that are too high or too low can inhibit growth.'
                      : 'Optimal humidity for mushroom growth is 80-90%. Excessive humidity can cause contamination, while low humidity inhibits growth.',
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isWebSocketConnected ? sensor.color : Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(context);

                      // If not connected, show message and try to connect again
                      if (!_isWebSocketConnected) {
                        _connectWebSocket();
                        Future.delayed(Duration(milliseconds: 300), () {
                          if (!_isWebSocketConnected && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: const [
                                    Icon(Icons.cloud_off, color: Colors.white),
                                    SizedBox(width: 16),
                                    Text('Attempting to connect to sensor...'),
                                  ],
                                ),
                                backgroundColor: Colors.blue,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        });
                      }
                    },
                    child: Text(
                      _isWebSocketConnected ? 'Close' : 'Try Connect',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildSensorDetailItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDeviceStatusItem(
    String name,
    bool isConnected,
    String status,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: isConnected ? Colors.green : Colors.red, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    color: isConnected ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isConnected ? Icons.check_circle : Icons.error,
            color: isConnected ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }
}
