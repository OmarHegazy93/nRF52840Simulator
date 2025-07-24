import Foundation
import CoreBluetooth
import Combine

// MARK: - Bluetooth Peripheral Manager
class BluetoothPeripheralManager: NSObject {
    
    // MARK: - Properties
    let currentState: BluetoothManagerState
    private var peripheralManager: CBPeripheralManager!
    private var service: CBMutableService!
    private var characteristic: CBMutableCharacteristic!
    
    // MARK: - Publishers
    // Individual publishers are now exposed through currentState
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    override init() {
        self.currentState = BluetoothManagerState()
        super.init()
        setupPeripheralManager()
    }
    
    // MARK: - Setup
    private func setupPeripheralManager() {
        // Initialize immediately to ensure it's available
        peripheralManager = CBPeripheralManager(delegate: self, queue: .main)
        
        // Check current state immediately and also after a short delay
        // Use a longer delay to ensure we're outside of any view update cycles
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.checkBluetoothState()
        }
    }
    
    private func checkBluetoothState() {
        guard let peripheralManager = peripheralManager else { return }
        
        // Use async to avoid state updates during view updates
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let isEnabled = peripheralManager.state == .poweredOn
            self.currentState.isBluetoothEnabled = isEnabled
            
            switch peripheralManager.state {
            case .poweredOn:
                self.currentState.clearError()
            case .poweredOff:
                self.currentState.setError("Bluetooth is powered off")
            case .unauthorized:
                self.currentState.setError("Bluetooth permission denied")
            case .unsupported:
                self.currentState.setError("Bluetooth is not supported")
            case .unknown:
                self.currentState.setError("Bluetooth state unknown")
            case .resetting:
                self.currentState.setError("Bluetooth is resetting")
            @unknown default:
                self.currentState.setError("Bluetooth state: \(peripheralManager.state.rawValue)")
            }
        }
    }
    
    // MARK: - Public Methods
    func startAdvertising() {
        guard let peripheralManager = peripheralManager else {
            DispatchQueue.main.async { [weak self] in
                self?.currentState.setError("Bluetooth peripheral manager not initialized")
            }
            return
        }
        
        guard peripheralManager.state == .poweredOn else {
            DispatchQueue.main.async { [weak self] in
                self?.currentState.setError("Bluetooth is not powered on")
            }
            return
        }
        
        setupService()
        peripheralManager.add(service)
        
        let advertisementData: [String: Any] = [
            CBAdvertisementDataServiceUUIDsKey: [DeviceConstants.serviceUUID],
            CBAdvertisementDataLocalNameKey: DeviceConstants.deviceName
        ]
        
        peripheralManager.startAdvertising(advertisementData)
        
        // State updates will be handled by the delegate method
    }
    
    func stopAdvertising() {
        guard let peripheralManager = peripheralManager else {
            DispatchQueue.main.async { [weak self] in
                self?.currentState.setError("Bluetooth peripheral manager not initialized")
            }
            return
        }
        
        peripheralManager.stopAdvertising()
        
        DispatchQueue.main.async { [weak self] in
            self?.currentState.isAdvertising = false
            self?.currentState.clearError()
        }
    }
    
    // MARK: - Private Methods
    private func setupService() {
        service = CBMutableService(type: DeviceConstants.serviceUUID, primary: true)
        
        characteristic = CBMutableCharacteristic(
            type: DeviceConstants.characteristicUUID,
            properties: [.notify, .read, .write, .writeWithoutResponse],
            value: nil,
            permissions: [.readable, .writeable]
        )
        
        service.characteristics = [characteristic]
    }
    
    private func handleStateChange(_ newState: BluetoothManagerState) {
        // Handle state changes if needed
    }
    
    // MARK: - TLV Message Processing
    private func processIncomingMessage(_ data: Data, from central: CBCentral) {
        // Try to decode as different message types
        if VersionRequest.decode(data) != nil {
            handleVersionRequest(from: central)
        } else if let echoRequest = EchoRequest.decode(data) {
            handleEchoRequest(echoRequest, from: central)
        }
    }
    
    private func handleVersionRequest(from central: CBCentral) {
        guard let peripheralManager = peripheralManager else { return }
        
        let response = VersionResponse(major: DeviceConstants.firmwareVersion.major, minor: DeviceConstants.firmwareVersion.minor, patch: DeviceConstants.firmwareVersion.patch)
        let responseData = response.encode()
        
        let success = peripheralManager.updateValue(
            responseData,
            for: characteristic,
            onSubscribedCentrals: [central]
        )
        
        if !success {
            // Try to send it later when the queue has space
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.retryVersionResponse(responseData, to: central)
            }
        }
        
        // Update device version in state - ensure this happens outside view updates
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if let device = self.currentState.connectedDevices.first(where: { $0.central.identifier == central.identifier }) {
                self.currentState.updateDeviceVersion(device.central, version: DeviceConstants.firmwareVersion)
            }
        }
    }
    
    private func retryVersionResponse(_ data: Data, to central: CBCentral) {
        guard let peripheralManager = peripheralManager else { return }
        
        let _ = peripheralManager.updateValue(
            data,
            for: characteristic,
            onSubscribedCentrals: [central]
        )
    }
    
    private func handleEchoRequest(_ request: EchoRequest, from central: CBCentral) {
        guard let peripheralManager = peripheralManager else { return }
        
        print("Handling echo request from central: \(central.identifier)")
        print("Request value: \(String(data: request.value, encoding: .utf8) ?? "invalid")")
        
        // Extract the message text from the request
        let messageText = String(data: request.value, encoding: .utf8) ?? "Invalid message"
        
        // Get device name
        let deviceName = getDeviceName(for: central)
        
        // Add incoming message to state - ensure this happens outside view updates
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let echoMessage = EchoMessage(deviceName: deviceName, message: messageText, isIncoming: true)
            self.currentState.addEchoMessage(echoMessage)
        }
        
        let response = EchoResponse(value: request.value)
        let responseData = response.encode()
        
        print("Sending echo response: \(responseData.map { String(format: "%02X", $0) }.joined())")
        
        let success = peripheralManager.updateValue(
            responseData,
            for: characteristic,
            onSubscribedCentrals: [central]
        )
        
        print("updateValue success: \(success)")
        
        if !success {
            print("updateValue failed, will retry in 0.1 seconds")
            // Try to send it later when the queue has space
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.retryEchoResponse(responseData, to: central)
            }
        }
    }
    
    private func getDeviceName(for central: CBCentral) -> String {
        if let device = self.currentState.connectedDevices.first(where: { $0.central.identifier == central.identifier }) {
            return device.name
        }
        return central.identifier.uuidString
    }
    
    private func retryEchoResponse(_ data: Data, to central: CBCentral) {
        guard let peripheralManager = peripheralManager else { return }
        
        let _ = peripheralManager.updateValue(
            data,
            for: characteristic,
            onSubscribedCentrals: [central]
        )
    }
}

// MARK: - CBPeripheralManagerDelegate
extension BluetoothPeripheralManager: CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        // Use async to avoid state updates during view updates
        DispatchQueue.main.async { [weak self] in
            self?.checkBluetoothState()
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if let error = error {
                self.currentState.setError("Failed to add service: \(error.localizedDescription)")
            }
        }
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if let error = error {
                self.currentState.setError("Failed to start advertising: \(error.localizedDescription)")
                self.currentState.isAdvertising = false
            } else {
                self.currentState.clearError()
                self.currentState.isAdvertising = true
            }
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let device = ConnectedDevice(
                central: central,
                name: central.identifier.uuidString
            )
            self.currentState.addConnectedDevice(device)
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
       DispatchQueue.main.async { [weak self] in
           guard let self else { return }
           self.currentState.removeConnectedDevice(with: central)
           self.currentState.echoMessages.removeAll()
       }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            guard request.characteristic.uuid == DeviceConstants.characteristicUUID else { 
                continue 
            }
            
            if let data = request.value {
                processIncomingMessage(data, from: request.central)
            }
            
            peripheral.respond(to: request, withResult: .success)
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        guard request.characteristic.uuid == DeviceConstants.characteristicUUID else {
            peripheral.respond(to: request, withResult: .invalidHandle)
            return
        }
        
        // Return empty data for read requests
        request.value = Data()
        peripheral.respond(to: request, withResult: .success)
    }
} 
