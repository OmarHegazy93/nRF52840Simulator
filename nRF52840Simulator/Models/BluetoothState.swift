import Foundation
import CoreBluetooth
import Combine

// MARK: - Bluetooth Connection State
enum BluetoothConnectionState {
    case disconnected
    case connecting
    case connected
    case disconnecting
    case error(String)
    
    var description: String {
        switch self {
        case .disconnected:
            return "Disconnected"
        case .connecting:
            return "Connecting..."
        case .connected:
            return "Connected"
        case .disconnecting:
            return "Disconnecting..."
        case .error(let message):
            return "Error: \(message)"
        }
    }
    
    var isConnected: Bool {
        if case .connected = self {
            return true
        }
        return false
    }
}

// MARK: - Echo Message
struct EchoMessage: Identifiable, Equatable {
    let id = UUID()
    let deviceName: String
    let message: String
    let timestamp: Date
    let isIncoming: Bool
    
    init(deviceName: String, message: String, isIncoming: Bool = true) {
        self.deviceName = deviceName
        self.message = message
        self.timestamp = Date()
        self.isIncoming = isIncoming
    }
    
    static func == (lhs: EchoMessage, rhs: EchoMessage) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Connected Device
struct ConnectedDevice: Identifiable, Equatable {
    let id = UUID()
    let central: CBCentral
    let name: String
    let version: VersionInfo?
    let connectionDate: Date
    
    init(central: CBCentral, name: String, version: VersionInfo? = nil) {
        self.central = central
        self.name = name
        self.version = version
        self.connectionDate = Date()
    }
    
    static func == (lhs: ConnectedDevice, rhs: ConnectedDevice) -> Bool {
        return lhs.central.identifier == rhs.central.identifier
    }
}

// MARK: - Bluetooth Manager State
class BluetoothManagerState {
    // MARK: - Publishers
    private let isAdvertisingSubject = CurrentValueSubject<Bool, Never>(false)
    private let isBluetoothEnabledSubject = CurrentValueSubject<Bool, Never>(false)
    private let connectedDevicesSubject = CurrentValueSubject<[ConnectedDevice], Never>([])
    private let echoMessagesSubject = CurrentValueSubject<[EchoMessage], Never>([])
    private let lastErrorSubject = CurrentValueSubject<String?, Never>(nil)
    
    // MARK: - Public Publishers
    var isAdvertisingPublisher: AnyPublisher<Bool, Never> {
        isAdvertisingSubject.eraseToAnyPublisher()
    }
    
    var isBluetoothEnabledPublisher: AnyPublisher<Bool, Never> {
        isBluetoothEnabledSubject.eraseToAnyPublisher()
    }
    
    var connectedDevicesPublisher: AnyPublisher<[ConnectedDevice], Never> {
        connectedDevicesSubject.eraseToAnyPublisher()
    }
    
    var echoMessagesPublisher: AnyPublisher<[EchoMessage], Never> {
        echoMessagesSubject.eraseToAnyPublisher()
    }
    
    var lastErrorPublisher: AnyPublisher<String?, Never> {
        lastErrorSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Computed Properties
    var isAdvertising: Bool {
        get { isAdvertisingSubject.value }
        set { isAdvertisingSubject.send(newValue) }
    }
    
    var isBluetoothEnabled: Bool {
        get { isBluetoothEnabledSubject.value }
        set { isBluetoothEnabledSubject.send(newValue) }
    }
    
    var connectedDevices: [ConnectedDevice] {
        get { connectedDevicesSubject.value }
        set { connectedDevicesSubject.send(newValue) }
    }
    
    var echoMessages: [EchoMessage] {
        get { echoMessagesSubject.value }
        set { echoMessagesSubject.send(newValue) }
    }
    
    var lastError: String? {
        get { lastErrorSubject.value }
        set { lastErrorSubject.send(newValue) }
    }
    
    var connectedDevicesCount: Int {
        return connectedDevices.count
    }
    
    func addConnectedDevice(_ device: ConnectedDevice) {
        if !connectedDevices.contains(device) {
            connectedDevices.append(device)
        }
    }
    
    func removeConnectedDevice(with central: CBCentral) {
        connectedDevices.removeAll { $0.central.identifier == central.identifier }
    }
    
    func updateDeviceVersion(_ central: CBCentral, version: VersionInfo) {
        if let index = connectedDevices.firstIndex(where: { $0.central.identifier == central.identifier }) {
            let updatedDevice = ConnectedDevice(
                central: central,
                name: connectedDevices[index].name,
                version: version
            )
            connectedDevices[index] = updatedDevice
        }
    }
    
    func clearError() {
        lastError = nil
    }
    
    func setError(_ error: String) {
        lastError = error
    }
    
    func addEchoMessage(_ message: EchoMessage) {
        echoMessages.append(message)
    }
    
    func clearEchoMessages() {
        echoMessages.removeAll()
    }
} 