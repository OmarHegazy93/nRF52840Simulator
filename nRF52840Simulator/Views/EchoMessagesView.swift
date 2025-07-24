import SwiftUI

// MARK: - Echo Messages View
struct EchoMessagesView: View {
    let messages: [EchoMessage]
    let onClear: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Echo Messages")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if !messages.isEmpty {
                    Button("Clear") {
                        onClear()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
            
            if messages.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "message")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text("No echo messages yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Messages from connected devices will appear here")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(messages.reversed()) { message in
                            EchoMessageRow(message: message)
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .frame(maxHeight: 300)
            }
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Echo Message Row
struct EchoMessageRow: View {
    let message: EchoMessage
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(message.deviceName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(formatTimestamp(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Text(message.message)
                .font(.body)
                .foregroundColor(.primary)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.1))
                )
        }
        .padding(.vertical, 4)
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    EchoMessagesView(
        messages: [
            EchoMessage(deviceName: "iPhone 15", message: "Hello Oura!"),
            EchoMessage(deviceName: "iPad Pro", message: "Testing echo functionality"),
            EchoMessage(deviceName: "MacBook Pro", message: "Another test message")
        ],
        onClear: {}
    )
    .padding()
} 