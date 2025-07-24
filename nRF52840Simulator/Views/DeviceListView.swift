import SwiftUI
import CoreBluetooth

// MARK: - Device List View
struct DeviceListView: View {
    let devices: [ConnectedDevice]
    let getConnectionTime: (ConnectedDevice) -> String
    let getVersionString: (ConnectedDevice) -> String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .foregroundColor(.blue)
                Text("Connected Devices")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(devices.count)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
            }
            
            if devices.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "antenna.radiowaves.left.and.right.slash")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("No devices connected")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Devices will appear here when they connect")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(devices) { device in
                        DeviceRowView(
                            device: device,
                            getConnectionTime: getConnectionTime,
                            getVersionString: getVersionString
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Device Row View
struct DeviceRowView: View {
    let device: ConnectedDevice
    let getConnectionTime: (ConnectedDevice) -> String
    let getVersionString: (ConnectedDevice) -> String
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "iphone")
                            .foregroundColor(.blue)
                        
                        Text(device.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isExpanded.toggle()
                            }
                        }) {
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    if isExpanded {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Connected:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(getConnectionTime(device))
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            
                            HStack {
                                Text("Version:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(getVersionString(device))
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            
                            HStack {
                                Text("ID:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(device.central.identifier.uuidString)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .lineLimit(1)
                            }
                        }
                        .padding(.top, 4)
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
        }
    }
}

#Preview {
    DeviceListView(
        devices: [],
        getConnectionTime: { _ in "2:30 PM" },
        getVersionString: { device in
            if let version = device.version {
                return version.description
            }
            return "Unknown"
        }
    )
    .padding()
} 