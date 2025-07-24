import Foundation
import Combine
import SwiftUI

// MARK: - Main View Model
class MainViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isAdvertising = false
    @Published var isBluetoothEnabled = false
    @Published var connectedDevices: [ConnectedDevice] = []
    @Published var echoMessages: [EchoMessage] = []
    @Published var lastError: String?
    @Published var showError = false
    
    // MARK: - Cached UI Properties (to avoid computed properties during view updates)
    @Published var advertisingButtonTitle = "Start Advertising"
    @Published var advertisingButtonColor: Color = .green
    @Published var statusText = "Bluetooth is not available"
    @Published var statusColor: Color = .red
    @Published var isButtonEnabled = false
    
    // MARK: - Private Properties
    private let bluetoothManager = BluetoothPeripheralManager()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        setupBindings()
    }
    
    // MARK: - Setup
    private func setupBindings() {
        // Bind individual state publishers to view model
        bluetoothManager.currentState.isAdvertisingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAdvertising in
                self?.isAdvertising = isAdvertising
                self?.updateUIProperties()
            }
            .store(in: &cancellables)
        
        bluetoothManager.currentState.isBluetoothEnabledPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isBluetoothEnabled in
                self?.isBluetoothEnabled = isBluetoothEnabled
                self?.updateUIProperties()
            }
            .store(in: &cancellables)
        
        bluetoothManager.currentState.connectedDevicesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] connectedDevices in
                self?.connectedDevices = connectedDevices
                self?.updateUIProperties()
            }
            .store(in: &cancellables)
        
        bluetoothManager.currentState.echoMessagesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] echoMessages in
                self?.echoMessages = echoMessages
            }
            .store(in: &cancellables)
        
        bluetoothManager.currentState.lastErrorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.lastError = error
                self?.showError = error != nil
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Private Methods
    private func updateUIProperties() {
        // Update button properties
        advertisingButtonTitle = isAdvertising ? "Stop Advertising" : "Start Advertising"
        advertisingButtonColor = isAdvertising ? .red : .green
        
        // Update button enabled state with more granular control
        isButtonEnabled = isBluetoothEnabled && !isBluetoothInTransition()
        
        // Update status text with more detailed information
        if !isBluetoothEnabled {
            statusText = getBluetoothStatusText()
        } else if isAdvertising {
            statusText = "Advertising as '\(DeviceConstants.deviceName)' - \(connectedDevices.count) device(s) connected"
        } else {
            statusText = "Ready to advertise - Bluetooth is available"
        }
        
        // Update status color
        if !isBluetoothEnabled {
            statusColor = .red
        } else if isAdvertising {
            statusColor = .green
        } else {
            statusColor = .orange
        }
    }
    
    private func isBluetoothInTransition() -> Bool {
        // Check if Bluetooth is in a transitional state
        // This could be expanded based on specific Bluetooth states
        return false // For now, we'll keep it simple
    }
    
    private func getBluetoothStatusText() -> String {
        // Return more specific status messages based on the error
        if let error = lastError {
            if error.contains("powered off") {
                return "Bluetooth is turned off - Please enable Bluetooth in Settings"
            } else if error.contains("unauthorized") {
                return "Bluetooth permission denied - Please allow Bluetooth access"
            } else if error.contains("unsupported") {
                return "Bluetooth is not supported on this device"
            } else if error.contains("resetting") {
                return "Bluetooth is resetting - Please wait"
            } else {
                return "Bluetooth is not available - \(error)"
            }
        }
        return "Bluetooth is not available"
    }
    
    // MARK: - Public Methods
    func toggleAdvertising() {
        if isAdvertising {
            bluetoothManager.stopAdvertising()
        } else {
            bluetoothManager.startAdvertising()
        }
    }
    
    func dismissError() {
        showError = false
        bluetoothManager.currentState.clearError()
    }
    
    func clearEchoMessages() {
        bluetoothManager.currentState.clearEchoMessages()
    }
    
    // MARK: - Device Management
    
    func getDeviceConnectionTime(_ device: ConnectedDevice) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: device.connectionDate)
    }
    
    func getDeviceVersionString(_ device: ConnectedDevice) -> String {
        if let version = device.version {
            return version.description
        } else {
            return "Unknown"
        }
    }
} 
