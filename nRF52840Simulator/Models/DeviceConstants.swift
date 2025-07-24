import Foundation
import CoreBluetooth

// MARK: - Device Constants
enum DeviceConstants {
    
    // MARK: - Device Information
    static let deviceName = "Wearable"
    
    // MARK: - Firmware Version
    static let firmwareVersion = VersionInfo(major: 2, minor: 1, patch: 9)
    static let firmwareVersionString = Self.firmwareVersion.description // Display version for UI
    
    // MARK: - Bluetooth Service and Characteristic UUIDs
    static let serviceUUID = CBUUID(string: "12345678-1234-5678-1234-56789abcdef0")
    static let characteristicUUID = CBUUID(string: "12345678-1234-5678-1234-56789abcdef1")
    
    // MARK: - UUID Strings (for display purposes)
    static let serviceUUIDString = "12345678-1234-5678-1234-56789abcdef0"
    static let characteristicUUIDString = "12345678-1234-5678-1234-56789abcdef1"
} 
