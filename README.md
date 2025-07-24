# nRF52840 Simulator

A SwiftUI-based iOS application that simulates an nRF52840 Bluetooth Low Energy (BLE) peripheral device. This simulator allows developers to test BLE client applications by providing a realistic peripheral that responds to version requests and echo messages.

## 📱 Overview

The nRF52840 Simulator acts as a virtual wearable device named "Wearable" that advertises itself over Bluetooth LE. It implements a custom service with characteristics that support:

- **Version Information**: Responds to version requests with firmware version 2.1.9
- **Echo Functionality**: Echoes back any message sent to it
- **Real-time Status Monitoring**: Shows connection status and device information
- **Multiple Client Support**: Can handle multiple connected devices simultaneously

## 🚀 Features

### Core Functionality
- **Bluetooth LE Peripheral Simulation**: Mimics the behavior of an nRF52840 device
- **Custom Service Implementation**: Uses a proprietary service UUID with read/write/notify characteristics
- **Message Protocol Support**: Implements TLV (Type-Length-Value) message format
- **Real-time Echo Service**: Echoes incoming messages back to connected clients

### User Interface
- **Status Dashboard**: Real-time Bluetooth status and advertising state
- **Device Management**: List of connected devices with connection timestamps
- **Message Logging**: View all echo messages with timestamps and device information
- **Error Handling**: Comprehensive error reporting and user feedback

### Technical Features
- **MVVM Architecture**: Clean separation of concerns using SwiftUI and Combine
- **Reactive Programming**: Real-time UI updates using Combine publishers
- **State Management**: Centralized state management for Bluetooth operations
- **Protocol-Oriented Design**: Extensible message protocol system

## 🛠️ Requirements

- **iOS 15.0+** / **macOS 12.0+**
- **Xcode 14.0+**
- **Swift 5.7+**
- **Bluetooth-enabled device** (for testing)

## 📦 Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd nRF52840Simulator
   ```

2. **Open in Xcode**:
   ```bash
   open nRF52840Simulator.xcodeproj
   ```

3. **Build and Run**:
   - Select your target device (iOS device or simulator)
   - Press `Cmd+R` to build and run the application

## 🔧 Configuration

### Bluetooth Permissions

The app requires Bluetooth permissions. Add the following to your `Info.plist`:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app uses Bluetooth to simulate an nRF52840 peripheral device.</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app uses Bluetooth to simulate an nRF52840 peripheral device.</string>
```

### Device Constants

The simulator uses the following configuration (defined in `DeviceConstants.swift`):

- **Device Name**: "Wearable"
- **Firmware Version**: 2.1.9
- **Service UUID**: `12345678-1234-5678-1234-56789abcdef0`
- **Characteristic UUID**: `12345678-1234-5678-1234-56789abcdef1`

## 📖 Usage

### Starting the Simulator

1. **Launch the app** on your iOS device
2. **Grant Bluetooth permissions** when prompted
3. **Tap "Start Advertising"** to begin broadcasting as a peripheral
4. **Monitor the status** to ensure Bluetooth is enabled and advertising

### Testing with BLE Clients

#### Version Request
Send a version request to get firmware information:
```
Type: 0x00
Length: 0x00
Value: (empty)
```

Expected response:
```
Type: 0x80
Length: 0x03
Value: [0x02, 0x01, 0x09] (version 2.1.9)
```

#### Echo Request
Send any message to have it echoed back:
```
Type: 0x01
Length: [message length]
Value: [message bytes]
```

Expected response:
```
Type: 0x81
Length: [message length]
Value: [original message bytes]
```

### Monitoring Connections

- **Status View**: Shows current Bluetooth state and advertising status
- **Device List**: Displays all connected devices with connection times
- **Echo Messages**: View all incoming and echoed messages
- **Error Alerts**: Automatic error reporting for connection issues

## 🏗️ Architecture

### Project Structure

```
nRF52840Simulator/
├── Models/
│   ├── BluetoothState.swift          # State management and data models
│   ├── DeviceConstants.swift         # Device configuration constants
│   └── MessageProtocol.swift         # Message protocol definitions
├── Services/
│   └── BluetoothPeripheralManager.swift  # Core Bluetooth functionality
├── ViewModels/
│   └── MainViewModel.swift           # Main view model
├── Views/
│   ├── ContentView.swift             # Main app view
│   ├── DeviceListView.swift          # Connected devices display
│   ├── EchoMessagesView.swift        # Message logging view
│   └── StatusView.swift              # Status dashboard
└── nRF52840SimulatorApp.swift        # App entry point
```

### Key Components

#### BluetoothPeripheralManager
- Manages CoreBluetooth peripheral operations
- Handles service and characteristic setup
- Processes incoming messages and generates responses
- Manages device connections and subscriptions

#### MessageProtocol System
- **RequestMessageProtocol**: Base protocol for incoming messages
- **ResponseMessageProtocol**: Base protocol for outgoing messages
- **VersionRequest/Response**: Handles firmware version queries
- **EchoRequest/Response**: Handles message echoing

#### State Management
- **BluetoothManagerState**: Centralized state using Combine
- **Reactive Updates**: Real-time UI updates through publishers
- **Error Handling**: Comprehensive error state management

## 🧪 Testing

### Manual Testing
1. **Bluetooth State Testing**: Test with Bluetooth enabled/disabled
2. **Connection Testing**: Connect multiple BLE clients
3. **Message Testing**: Send various message types and verify responses
4. **Error Handling**: Test with invalid messages and connection drops

## 🔍 Debugging

### Console Logging
The app includes comprehensive logging for debugging:
- Bluetooth state changes
- Message processing
- Connection events
- Error conditions

### Common Issues

#### Bluetooth Not Available
- Ensure Bluetooth is enabled on the device
- Check app permissions in Settings
- Verify the device supports BLE

#### Messages Not Echoing
- Verify the client is writing to the correct characteristic
- Check message format (TLV structure)
- Ensure the client has subscribed to notifications

---

**Note**: This simulator is intended for development and testing purposes. It does not implement all features of a real nRF52840 device and should not be used in production environments. 