import Foundation

// MARK: - Message Protocols
protocol MessageProtocol {
    var type: UInt8 { get }
    var value: Data { get }
}

protocol RequestMessageProtocol: MessageProtocol {
    func encode() -> Data
    static func decode(_ data: Data) -> Self?
}

extension RequestMessageProtocol {
    func encode() -> Data {
        var data = Data()
        data.append(type)
        data.append(UInt8(value.count))
        data.append(value)
        return data
    }
}

protocol ResponseMessageProtocol: MessageProtocol {
    static func decode(_ data: Data) -> Self?
    func encode() -> Data
}

extension ResponseMessageProtocol {
    func encode() -> Data {
        var data = Data()
        data.append(type)
        data.append(UInt8(value.count))
        data.append(value)
        return data
    }
}

// MARK: - Version Request and Response
struct VersionRequest: RequestMessageProtocol {
    let type: UInt8 = 0x00
    let value = Data()
    
    static func decode(_ data: Data) -> VersionRequest? {
        guard data.count >= 2,
              data[0] == 0x00,
              data[1] == 0x00 else { return nil }
        return VersionRequest()
    }
}

struct VersionResponse: ResponseMessageProtocol {
    static let messageType: UInt8 = 0x80
    var type: UInt8 { Self.messageType }
    let major: UInt8
    let minor: UInt8
    let patch: UInt8
    
    var value: Data {
        Data([major, minor, patch])
    }
    
    static func decode(_ data: Data) -> VersionResponse? {
        guard data.count == 5,
              data[0] == Self.messageType,
              data[1] == 0x03 else { return nil }
        let major = data[2]
        let minor = data[3]
        let patch = data[4]
        
        guard major != 0 || minor != 0 || patch != 0 else { return nil }
        return VersionResponse(major: major, minor: minor, patch: patch)
    }
}

// MARK: - Echo Request and Response
struct EchoRequest: RequestMessageProtocol {
    let type: UInt8 = 0x01
    let value: Data
    
    static func decode(_ data: Data) -> EchoRequest? {
        let headerSize = 2 // type + length fields
        guard data.count >= headerSize,
              data[0] == 0x01 else { return nil }
        let length = data[1]
        guard data.count >= headerSize + Int(length) else { return nil }
        let value = data.dropFirst(headerSize).prefix(Int(length))
        return EchoRequest(value: Data(value))
    }
}

struct EchoResponse: ResponseMessageProtocol {
    static let messageType: UInt8 = 0x81
    var type: UInt8 { Self.messageType }
    let value: Data
    
    static func decode(_ data: Data) -> EchoResponse? {
        let headerSize = 2 // type + length fields
        guard data.count >= headerSize,
              data[0] == Self.messageType,
              data[1] == data.count - headerSize else { return nil }
        let value = data.dropFirst(headerSize)
        return EchoResponse(value: value)
    }
}

struct VersionInfo {
    let major: UInt8
    let minor: UInt8
    let patch: UInt8
    
    func toData() -> Data {
        Data([major, minor, patch])
    }
    
    static func fromData(_ data: Data) -> VersionInfo? {
        guard data.count == 3 else { return nil }
        return VersionInfo(major: data[0], minor: data[1], patch: data[2])
    }
    
    var description: String {
        return "\(major).\(minor).\(patch)"
    }
}
