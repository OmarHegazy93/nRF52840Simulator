//
//  ContentView.swift
//  nRF52840Simulator
//
//  Created by Omar Hegazy on 18/07/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MainViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                    
                    Text("nRF52840 Simulator")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Bluetooth LE Peripheral")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Status View
                StatusView(
                    isBluetoothEnabled: viewModel.isBluetoothEnabled,
                    isAdvertising: viewModel.isAdvertising,
                    statusText: viewModel.statusText,
                    statusColor: viewModel.statusColor,
                    connectedDevicesCount: viewModel.connectedDevices.count
                )
                
                // Control Button
                Button(action: {
                    viewModel.toggleAdvertising()
                }) {
                    HStack {
                        Image(systemName: viewModel.isAdvertising ? "stop.circle.fill" : "play.circle.fill")
                        Text(viewModel.advertisingButtonTitle)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.isButtonEnabled ? viewModel.advertisingButtonColor : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .opacity(viewModel.isButtonEnabled ? 1.0 : 0.6)
                }
                .disabled(!viewModel.isButtonEnabled)
                .help(viewModel.isButtonEnabled ? 
                      (viewModel.isAdvertising ? "Stop advertising to disconnect devices" : "Start advertising to allow device connections") :
                      "Bluetooth must be enabled to start advertising")
                
                // Echo Messages
                EchoMessagesView(
                    messages: viewModel.echoMessages,
                    onClear: {
                        viewModel.clearEchoMessages()
                    }
                )
                
                // Device List
                DeviceListView(
                    devices: viewModel.connectedDevices,
                    getConnectionTime: { device in
                        viewModel.getDeviceConnectionTime(device)
                    },
                    getVersionString: { device in
                        viewModel.getDeviceVersionString(device)
                    }
                )
                
                Spacer()
            }
            .padding()
            .navigationTitle("")
            // Navigation bar is not available on macOS
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") {
                viewModel.dismissError()
            }
        } message: {
            if let error = viewModel.lastError {
                Text(error)
            }
        }
    }
}

#Preview {
    ContentView()
}
