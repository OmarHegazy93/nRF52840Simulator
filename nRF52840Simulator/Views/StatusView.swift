import SwiftUI

// MARK: - Status View
struct StatusView: View {
    let isBluetoothEnabled: Bool
    let isAdvertising: Bool
    let statusText: String
    let statusColor: Color
    let connectedDevicesCount: Int
    
    var body: some View {
        VStack(spacing: 16) {
            // Main Status Card
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: statusIcon)
                        .font(.title2)
                        .foregroundColor(statusColor)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Bluetooth Status")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(statusText)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Status Indicator
                    Circle()
                        .fill(statusColor)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(statusColor.opacity(0.3), lineWidth: 2)
                                .frame(width: 20, height: 20)
                        )
                }
                
                // Connection Stats
                if isBluetoothEnabled {
                    HStack(spacing: 20) {
                        StatItem(
                            icon: "antenna.radiowaves.left.and.right",
                            title: "Advertising",
                            value: isAdvertising ? "Active" : "Inactive",
                            color: isAdvertising ? .green : .orange
                        )
                        
                        StatItem(
                            icon: "iphone",
                            title: "Connected",
                            value: "\(connectedDevicesCount)",
                            color: .blue
                        )
                    }
                }
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            
            // Service Information
            if isBluetoothEnabled {
                ServiceInfoView()
            }
        }
    }
    
    private var statusIcon: String {
        if !isBluetoothEnabled {
            return "bluetooth.slash"
        }
        
        if isAdvertising {
            return "antenna.radiowaves.left.and.right"
        } else {
            return "antenna.radiowaves.left.and.right.slash"
        }
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
        }
    }
}

// MARK: - Service Info View
struct ServiceInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
                Text("Service Information")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(
                    title: "Device Name",
                    value: DeviceConstants.deviceName
                )
                
                InfoRow(
                    title: "Service UUID",
                    value: DeviceConstants.serviceUUIDString
                )
                
                InfoRow(
                    title: "Characteristic UUID",
                    value: DeviceConstants.characteristicUUIDString
                )
                
                InfoRow(
                    title: "Firmware Version",
                    value: DeviceConstants.firmwareVersionString
                )
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 120, alignment: .leading)
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
            
            Spacer()
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        StatusView(
            isBluetoothEnabled: true,
            isAdvertising: true,
            statusText: "Advertising as 'Oura demo' - 2 device(s) connected",
            statusColor: .green,
            connectedDevicesCount: 2
        )
        
        StatusView(
            isBluetoothEnabled: false,
            isAdvertising: false,
            statusText: "Bluetooth is not available",
            statusColor: .red,
            connectedDevicesCount: 0
        )
    }
    .padding()
} 
