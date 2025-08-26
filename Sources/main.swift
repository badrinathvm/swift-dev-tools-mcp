// The Swift Programming Language
// https://docs.swift.org/swift-book

import MCP
import Foundation

let server = Server(
    name: "Swift Dev Tools Server",
    version: "1.0.0",
    capabilities: .init(tools: .init(listChanged: false))
)

let transport = StdioTransport()
try await server.start(transport: transport)

let swiftVersionTool = Tool(
    name: "swift_version",
    description: "Returns the current Swift version",
    inputSchema: .object(["type": .string("object")])
)

let listSimulatorTool = Tool(
    name: "list_simulator",
    description: "Lists available simulators",
    inputSchema: .object(["type": .string("object")])
)

let xcodeVersionTool = Tool(
    name: "xcode_version",
    description: "Returns Xcode version and build information",
    inputSchema: .object(["type": .string("object")])
)

let xcodeSDKsTool = Tool(
    name: "xcode_sdks",
    description: "Lists all available Xcode SDKs",
    inputSchema: .object(["type": .string("object")])
)

let connectedDevicesTool = Tool(
    name: "connected_devices",
    description: "Lists all connected iOS/macOS devices",
    inputSchema: .object(["type": .string("object")])
)

let macOSVersionTool = Tool(
    name: "macos_version",
    description: "Returns macOS version information",
    inputSchema: .object(["type": .string("object")])
)

let systemArchTool = Tool(
    name: "system_architecture",
    description: "Returns system architecture (arm64/x86_64)",
    inputSchema: .object(["type": .string("object")])
)

await server.withMethodHandler(ListTools.self) { params in
    ListTools.Result(
        tools: [
            swiftVersionTool,
            listSimulatorTool,
            xcodeVersionTool,
            xcodeSDKsTool,
            connectedDevicesTool,
            macOSVersionTool,
            systemArchTool
        ]
    )
}

await server.withMethodHandler(CallTool.self) { params in
    switch params.name {
    case swiftVersionTool.name:
        return CallTool.Result(content: [.text(swiftVersion() ?? "No version")])
    case listSimulatorTool.name:
        return CallTool.Result(content: [.text(listSimulator() ?? "No simulators found")])
    case xcodeVersionTool.name:
        return CallTool.Result(content: [.text(xcodeVersion() ?? "No Xcode version")])
    case xcodeSDKsTool.name:
        return CallTool.Result(content: [.text(xcodeSDKs() ?? "No SDKs found")])
    case connectedDevicesTool.name:
        return CallTool.Result(content: [.text(connectedDevices() ?? "No devices found")])
    case macOSVersionTool.name:
        return CallTool.Result(content: [.text(macOSVersion() ?? "No macOS version")])
    case systemArchTool.name:
        return CallTool.Result(content: [.text(systemArchitecture() ?? "No architecture info")])
    default:
        throw MCPError.invalidParams("Wrong tool name: \(params.name)")
    }
}

// MARK: - Tool Functions

func swiftVersion() -> String? {
    return runShellCommand(["swift", "--version"], errorPrefix: "Error getting Swift version")
}

func listSimulator() -> String? {
    return runShellCommand(["xcrun", "simctl", "list", "devices"], errorPrefix: "Error listing simulators")
}

func xcodeVersion() -> String? {
    return runShellCommand(["xcodebuild", "-version"], errorPrefix: "Error getting Xcode version")
}

func xcodeSDKs() -> String? {
    return runShellCommand(["xcodebuild", "-showsdks"], errorPrefix: "Error listing Xcode SDKs")
}

func connectedDevices() -> String? {
    return runShellCommand(["xcrun", "xctrace", "list", "devices"], errorPrefix: "Error listing connected devices")
}

func macOSVersion() -> String? {
    return runShellCommand(["sw_vers"], errorPrefix: "Error getting macOS version")
}

func systemArchitecture() -> String? {
    return runShellCommand(["uname", "-m"], errorPrefix: "Error getting system architecture")
}

// MARK: - Generic Shell Command Runner

/// Executes a shell command and returns the output
/// - Parameters:
///   - arguments: Array of command arguments (first element is the command)
///   - errorPrefix: Custom error message prefix for failures
/// - Returns: Command output as string, or error message if failed
func runShellCommand(_ arguments: [String], errorPrefix: String = "Command failed") -> String? {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = arguments
    
    let outputPipe = Pipe()
    let errorPipe = Pipe()
    process.standardOutput = outputPipe
    process.standardError = errorPipe
    
    do {
        try process.run()
        process.waitUntilExit()
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        
        // Check if process succeeded
        guard process.terminationStatus == 0 else {
            let errorMessage = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            return "\(errorPrefix): Process failed with status \(process.terminationStatus). \(errorMessage)"
        }
        
        return String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
    } catch {
        return "\(errorPrefix): \(error.localizedDescription)"
    }
}

await server.waitUntilCompleted()

