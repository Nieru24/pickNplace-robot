import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'dart:async';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const PickNPlaceApp());
}

class PickNPlaceApp extends StatelessWidget {
  const PickNPlaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'pickNplace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A1A2E),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
      ),
      home: const ControllerScreen(),
    );
  }
}

class ControllerScreen extends StatefulWidget {
  const ControllerScreen({super.key});

  @override
  State<ControllerScreen> createState() => _ControllerScreenState();
}

class ArmJointConfig {
  const ArmJointConfig({
    required this.id,
    required this.label,
    required this.incrementCommand,
    required this.decrementCommand,
    required this.defaultAngle,
  });

  final String id;
  final String label;
  final String incrementCommand;
  final String decrementCommand;
  final int defaultAngle;
}

class _ControllerScreenState extends State<ControllerScreen> {
  final _bt = BluetoothClassic();
  
  Device? _connectedDevice;
  bool _isConnecting = false;
  StreamSubscription? _dataSubscription;
  
  // Motor control values
  int _motorSpeed = 100;
  
  static const int _servoStep = 10;
  static const List<String> _leftJointIds = ['leftLift', 'leftElbow'];
  static const List<String> _rightJointIds = ['rightLift', 'rightElbow', 'rightGrip'];

  static const Map<String, ArmJointConfig> _jointConfigs = {
    'leftLift': ArmJointConfig(
      id: 'leftLift',
      label: 'LIFT',
      incrementCommand: 'I',
      decrementCommand: 'K',
      defaultAngle: 90,
    ),
    'leftElbow': ArmJointConfig(
      id: 'leftElbow',
      label: 'ELBOW',
      incrementCommand: 'J',
      decrementCommand: 'L',
      defaultAngle: 90,
    ),
    'rightLift': ArmJointConfig(
      id: 'rightLift',
      label: 'LIFT',
      incrementCommand: 'T',
      decrementCommand: 'G',
      defaultAngle: 90,
    ),
    'rightElbow': ArmJointConfig(
      id: 'rightElbow',
      label: 'ELBOW',
      incrementCommand: 'Y',
      decrementCommand: 'H',
      defaultAngle: 90,
    ),
    'rightGrip': ArmJointConfig(
      id: 'rightGrip',
      label: 'GRIP',
      incrementCommand: 'U',
      decrementCommand: 'N',
      defaultAngle: 100,
    ),
  };

  late final Map<String, int> _jointAngles = {
    for (final joint in _jointConfigs.values) joint.id: joint.defaultAngle,
  };
  
  // Continuous control variables for dead man's switch
  String _currentCommand = 'Q'; // Default stop command
  Timer? _commandStreamTimer;
  Timer? _repeatActionTimer;
  
  // Track touch state
  bool _isForwardPressed = false;
  bool _isReversePressed = false;
  bool _isLeftPressed = false;
  bool _isRightPressed = false;
  
  // Feedback data
  String _receivedData = '';

  int _angleFor(String jointId) {
    final config = _jointConfigs[jointId];
    return _jointAngles[jointId] ?? (config?.defaultAngle ?? 90);
  }

  void _updateJoint(String jointId, bool increment) {
    final config = _jointConfigs[jointId];
    if (config == null) return;

    final delta = increment ? _servoStep : -_servoStep;
    final command = increment ? config.incrementCommand : config.decrementCommand;

    setState(() {
      final current = _angleFor(jointId);
      _jointAngles[jointId] = (current + delta).clamp(0, 180);
    });
    _sendCommand(command);
  }

  void _resetArmState() {
    setState(() {
      for (final joint in _jointConfigs.values) {
        _jointAngles[joint.id] = joint.defaultAngle;
      }
    });
    _sendCommand('X');
  }

  // ── BT Commands ───────────────────────────────────────────────────────────
  
  Future<void> _sendCommand(String command) async {
    if (_connectedDevice == null) return;
    
    try {
      await _bt.write(command);
      debugPrint('Sent: $command');
    } catch (e) {
      debugPrint('Failed to send: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send: $e'),
            backgroundColor: const Color(0xFF1A1A2E),
          ),
        );
      }
    }
  }
  
  Future<void> _sendSpeedCommand(int step) async {
    if (_connectedDevice == null) return;
    
    String command = step > 0 ? '+' : '-';
    int newSpeed = _motorSpeed + step;
    newSpeed = newSpeed.clamp(10, 250);
    
    setState(() => _motorSpeed = newSpeed);
    await _sendCommand(command);
  }
  
  // Start continuous command streaming (Dead Man's Switch)
  void _startCommandStreaming() {
    _commandStreamTimer?.cancel();
    _commandStreamTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_connectedDevice != null) {
        _sendCommand(_currentCommand);
      }
    });
  }
  
  // Stop continuous command streaming
  void _stopCommandStreaming() {
    _commandStreamTimer?.cancel();
    _commandStreamTimer = null;
  }

  void _startRepeatAction(VoidCallback action) {
    if (_connectedDevice == null) return;
    action();
    _repeatActionTimer?.cancel();
    _repeatActionTimer = Timer.periodic(const Duration(milliseconds: 140), (_) {
      action();
    });
  }

  void _stopRepeatAction() {
    _repeatActionTimer?.cancel();
    _repeatActionTimer = null;
  }
  
  // Update current command based on pressed buttons
  void _updateCurrentCommand() {
    // Priority: Forward/Reverse > Turning > Stop
    if (_isForwardPressed) {
      _currentCommand = 'W';
    } else if (_isReversePressed) {
      _currentCommand = 'S';
    } else if (_isLeftPressed) {
      _currentCommand = 'A';
    } else if (_isRightPressed) {
      _currentCommand = 'D';
    } else {
      _currentCommand = 'Q';
    }
    
    // Update UI to show active command
    setState(() {});
  }
  
  // Handle touch events for direction buttons
  void _onDirectionPressed(String direction) {
    switch (direction) {
      case 'W':
        setState(() => _isForwardPressed = true);
        break;
      case 'S':
        setState(() => _isReversePressed = true);
        break;
      case 'A':
        setState(() => _isLeftPressed = true);
        break;
      case 'D':
        setState(() => _isRightPressed = true);
        break;
    }
    _updateCurrentCommand();
  }
  
  void _onDirectionReleased(String direction) {
    switch (direction) {
      case 'W':
        setState(() => _isForwardPressed = false);
        break;
      case 'S':
        setState(() => _isReversePressed = false);
        break;
      case 'A':
        setState(() => _isLeftPressed = false);
        break;
      case 'D':
        setState(() => _isRightPressed = false);
        break;
    }
    _updateCurrentCommand();
  }
  
  // Stop all movement (emergency stop)
  void _emergencyStop() {
    setState(() {
      _isForwardPressed = false;
      _isReversePressed = false;
      _isLeftPressed = false;
      _isRightPressed = false;
      _currentCommand = 'Q';
    });
    _sendCommand('Q');
  }

  // ── BT Connection ─────────────────────────────────────────────────────────
  
  Future<void> _showDeviceList() async {
    List<Device> devices = [];
    bool loading = true;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            if (loading && devices.isEmpty) {
              _bt.getPairedDevices().then((list) {
                setSheet(() {
                  devices = list;
                  loading = false;
                });
              }).catchError((_) {
                setSheet(() => loading = false);
              });
            }

            return SafeArea(
              child: DraggableScrollableSheet(
                initialChildSize: 0.6,
                minChildSize: 0.4,
                maxChildSize: 0.8,
                expand: false,
                builder: (context, scrollController) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: Text(
                          'Select Device',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Divider(color: Color(0xFF2A2A3E), height: 1),
                      Expanded(
                        child: loading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF4FC3F7),
                                  strokeWidth: 2,
                                ),
                              )
                            : devices.isEmpty
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 20),
                                      child: Text(
                                        'No paired devices.\nPair HC-05 in Android Bluetooth settings first.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Color(0xFF555566), fontSize: 13),
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    controller: scrollController,
                                    itemCount: devices.length,
                                    separatorBuilder: (_, __) =>
                                        const Divider(color: Color(0xFF1E1E2E), height: 1, indent: 56),
                                    itemBuilder: (_, i) {
                                      final d = devices[i];
                                      return ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                                        leading: const Icon(Icons.bluetooth, color: Color(0xFF4FC3F7), size: 20),
                                        title: Text(
                                          d.name ?? 'Unknown',
                                          style: const TextStyle(color: Colors.white, fontSize: 14),
                                        ),
                                        subtitle: Text(
                                          d.address,
                                          style: const TextStyle(
                                            color: Color(0xFF555566),
                                            fontSize: 11,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                        trailing: const Icon(Icons.chevron_right, color: Color(0xFF444455)),
                                        onTap: () {
                                          Navigator.pop(ctx);
                                          _connect(d);
                                        },
                                      );
                                    },
                                  ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _connect(Device device) async {
    setState(() => _isConnecting = true);
    try {
      await _bt.connect(device.address, '00001101-0000-1000-8000-00805f9b34fb');
      setState(() {
        _connectedDevice = device;
        _isConnecting = false;
        _currentCommand = 'Q';
      });
      
      // Start listening for incoming data - using onDeviceDataReceived stream
      _dataSubscription = _bt.onDeviceDataReceived().listen((data) {
        if (mounted) {
          setState(() {
            // data is Uint8List of bytes
            _receivedData = String.fromCharCodes(data);
            // Try to parse as speed if it's numeric
            final int? speed = int.tryParse(_receivedData);
            if (speed != null && speed >= 10 && speed <= 250) {
              _motorSpeed = speed;
            }
          });
        }
      });
      
      // Start command streaming
      _startCommandStreaming();
      
    } catch (e) {
      setState(() => _isConnecting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: const Color(0xFF1A1A2E),
          ),
        );
      }
    }
  }

  Future<void> _disconnect() async {
    _stopCommandStreaming();
    _stopRepeatAction();
    await _dataSubscription?.cancel();
    await _bt.disconnect();
    setState(() {
      _connectedDevice = null;
      _isForwardPressed = false;
      _isReversePressed = false;
      _isLeftPressed = false;
      _isRightPressed = false;
      _currentCommand = 'Q';
      _receivedData = '';
    });
  }

  // ── UI Components ─────────────────────────────────────────────────────────
  
  Widget _buildSpeedControl() {
    return SizedBox(
      width: 84,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'SPEED',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          _buildSpeedButton(
            icon: Icons.add,
            onPressStart: _connectedDevice != null ? () => _startRepeatAction(() => _sendSpeedCommand(10)) : null,
            onPressEnd: _stopRepeatAction,
            color: const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 10),
          Container(
            width: 66,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(128),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  '$_motorSpeed',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'RPM',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildSpeedButton(
            icon: Icons.remove,
            onPressStart: _connectedDevice != null ? () => _startRepeatAction(() => _sendSpeedCommand(-10)) : null,
            onPressEnd: _stopRepeatAction,
            color: const Color(0xFFF44336),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedButton({
    required IconData icon,
    required VoidCallback? onPressStart,
    required VoidCallback onPressEnd,
    required Color color,
  }) {
    return GestureDetector(
      onTapDown: onPressStart == null ? null : (_) => onPressStart(),
      onTapUp: (_) => onPressEnd(),
      onTapCancel: onPressEnd,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(128),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(128), width: 1),
        ),
        child: Icon(
          icon,
          color: onPressStart != null ? color : color.withAlpha(80),
          size: 28,
        ),
      ),
    );
  }

  Widget _buildDPad() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Up (Forward)
        GestureDetector(
          onTapDown: (_) => _onDirectionPressed('W'),
          onTapUp: (_) => _onDirectionReleased('W'),
          onTapCancel: () => _onDirectionReleased('W'),
          child: _buildDirectionButton(
            icon: Icons.arrow_upward,
            isActive: _isForwardPressed,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Left
            GestureDetector(
              onTapDown: (_) => _onDirectionPressed('A'),
              onTapUp: (_) => _onDirectionReleased('A'),
              onTapCancel: () => _onDirectionReleased('A'),
              child: _buildDirectionButton(
                icon: Icons.arrow_back,
                isActive: _isLeftPressed,
              ),
            ),
            const SizedBox(width: 8),
            // Stop (Emergency)
            GestureDetector(
              onTapDown: (_) => _emergencyStop(),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(128),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF44336).withAlpha(128), width: 1),
                ),
                child: const Icon(Icons.stop, color: Color(0xFFF44336), size: 28),
              ),
            ),
            const SizedBox(width: 8),
            // Right
            GestureDetector(
              onTapDown: (_) => _onDirectionPressed('D'),
              onTapUp: (_) => _onDirectionReleased('D'),
              onTapCancel: () => _onDirectionReleased('D'),
              child: _buildDirectionButton(
                icon: Icons.arrow_forward,
                isActive: _isRightPressed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Down (Reverse)
        GestureDetector(
          onTapDown: (_) => _onDirectionPressed('S'),
          onTapUp: (_) => _onDirectionReleased('S'),
          onTapCancel: () => _onDirectionReleased('S'),
          child: _buildDirectionButton(
            icon: Icons.arrow_downward,
            isActive: _isReversePressed,
          ),
        ),
      ],
    );
  }

  Widget _buildDirectionButton({
    required IconData icon,
    required bool isActive,
  }) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4FC3F7).withAlpha(77) : Colors.black.withAlpha(128),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? const Color(0xFF4FC3F7) : Colors.grey.withAlpha(128),
          width: isActive ? 2 : 1,
        ),
      ),
      child: Icon(
        icon, 
        color: isActive ? const Color(0xFF4FC3F7) : Colors.white70, 
        size: 28
      ),
    );
  }

  Widget _buildServoControl(String title, VoidCallback onIncrement, VoidCallback onDecrement) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildServoStepButton(
              icon: Icons.remove,
              color: const Color(0xFFF44336),
              onPressStart: _connectedDevice != null ? () => _startRepeatAction(onDecrement) : null,
            ),
            const SizedBox(width: 8),
            _buildServoStepButton(
              icon: Icons.add,
              color: const Color(0xFF4CAF50),
              onPressStart: _connectedDevice != null ? () => _startRepeatAction(onIncrement) : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServoStepButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressStart,
  }) {
    return GestureDetector(
      onTapDown: onPressStart == null ? null : (_) => onPressStart(),
      onTapUp: (_) => _stopRepeatAction(),
      onTapCancel: _stopRepeatAction,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha(120)),
        ),
        child: Icon(
          icon,
          color: onPressStart != null ? color : color.withAlpha(80),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return Expanded(
      child: Container(
        height: 46,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFCCCCCC), width: 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _connectedDevice != null ? onPressed : null,
            borderRadius: BorderRadius.circular(6),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _connectedDevice != null ? const Color(0xFF333333) : const Color(0xFF999999),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArmCard(String title, List<String> jointIds) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE3E3E3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF660000),
              ),
            ),
            for (final jointId in jointIds) ...[
              _buildServoControl(
                _jointConfigs[jointId]!.label,
                () => _updateJoint(jointId, true),
                () => _updateJoint(jointId, false),
              ),
              const SizedBox(height: 4),
            ],
          ],
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final connected = _connectedDevice != null;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Container(
              height: 44,
              color: const Color(0xFF12121F),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  connected
                      ? OutlinedButton(
                          onPressed: _disconnect,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEF9A9A),
                            side: const BorderSide(color: Color(0xFFEF9A9A)),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            minimumSize: const Size(0, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text('Disconnect', style: TextStyle(fontSize: 10)),
                        )
                      : ElevatedButton.icon(
                          onPressed: _isConnecting ? null : _showDeviceList,
                          icon: _isConnecting
                              ? const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF4FC3F7),
                                  ),
                                )
                              : const Icon(Icons.bluetooth, size: 14),
                          label: Text(
                            _isConnecting ? 'Connecting…' : 'Connect',
                            style: const TextStyle(fontSize: 10),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A5F),
                            foregroundColor: const Color(0xFF4FC3F7),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            minimumSize: const Size(0, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                  const SizedBox(width: 8),
                  if (connected) ...[
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF66BB6A),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${_connectedDevice!.address}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFF888898),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    if (_receivedData.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3A5F),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$_receivedData RPM',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Color(0xFF4FC3F7),
                          ),
                        ),
                      ),
                    ],
                  ] else
                    const Text(
                      'Not connected',
                      style: TextStyle(fontSize: 10, color: Color(0xFF444455)),
                    ),
                  const Spacer(),
                  const Text(
                    'pickNplace',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF333344),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF1E1E2E), height: 1),
            
            // Main Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Row(
                  children: [
                    // Left Panel - Locomotion
                    Container(
                      width: screenWidth * 0.35,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF8B0000), Color(0xFF660000)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildSpeedControl(),
                          _buildDPad(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Right Panel - Arm Controls
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              // Action Buttons
                              Row(
                                children: [
                                  _buildActionButton('RESET', _resetArmState),
                                ],
                              ),
                              const SizedBox(height: 14),
                              
                              // Arm Controls
                              Expanded(
                                child: Row(
                                  children: [
                                    _buildArmCard('LEFT ARM', _leftJointIds),
                                    const SizedBox(width: 10),
                                    _buildArmCard('RIGHT ARM', _rightJointIds),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _stopCommandStreaming();
    _stopRepeatAction();
    _dataSubscription?.cancel();
    super.dispose();
  }
}