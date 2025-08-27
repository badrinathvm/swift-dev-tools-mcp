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

let listXcodeVersionsTool = Tool(
    name: "list_xcode_versions",
    description: "Lists all installed Xcode versions and marks the active one",
    inputSchema: .object(["type": .string("object")])
)

let developerToolsStatusTool = Tool(
    name: "developer_tools_status",
    description: "Comprehensive health check of development tools and environment",
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
            systemArchTool,
            listXcodeVersionsTool,
            developerToolsStatusTool
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
    case listXcodeVersionsTool.name:
        return CallTool.Result(content: [.text(listXcodeVersions() ?? "No Xcode installations found")])
    case developerToolsStatusTool.name:
        return CallTool.Result(content: [.text(developerToolsStatus() ?? "Unable to get tools status")])
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

/// Lists all installed Xcode versions on the system, marking the current active one
/// Uses `mdfind` to locate all Xcode installations and reads version info from their Info.plist
/// This technique comes from https://gist.github.com/dive/da0a696f2d51a1cbef04762c3a216192#spotlight
/// - Returns: Formatted list of Xcode installations with versions and paths, or nil if none found
func listXcodeVersions() -> String? {
    var output = "Installed Xcode Versions:\n"
    let activeDir = runShellCommand(["xcode-select", "-p"])
    
    // Find all Xcode installations using mdfind
    let findXcodes = runShellCommand(["mdfind", "kMDItemCFBundleIdentifier=com.apple.dt.Xcode"], 
                                     errorPrefix: "Error finding Xcode installations")
    
    if let xcodePaths = findXcodes?.components(separatedBy: "\n").filter({ !$0.isEmpty }) {
        for path in xcodePaths {
            // Get version from Info.plist
            let versionCmd = ["defaults", "read", "\(path)/Contents/Info", "CFBundleShortVersionString"]
            let buildCmd = ["defaults", "read", "\(path)/Contents/version", "ProductBuildVersion"]
            
            if let version = runShellCommand(versionCmd, errorPrefix: "Error reading Xcode version") {
                let build = runShellCommand(buildCmd) ?? "Unknown Build"
                let isActive = activeDir?.contains(path) ?? false
                let status = isActive ? " [ACTIVE]" : ""
                let appName = URL(fileURLWithPath: path).lastPathComponent
                output += "- \(appName) (\(version), Build \(build)) - \(path)\(status)\n"
            }
        }
    }
    
    output += "\nNote: Use 'sudo xcode-select -s /path/to/Xcode.app/Contents/Developer' to switch versions"
    return output
}

/// Performs a comprehensive health check of the development tools environment
/// Checks Xcode, Swift, SDK versions, license status, and developer mode
/// - Returns: Formatted status report with check marks for each component, or nil if unable to check
func developerToolsStatus() -> String? {
    var output = "Developer Tools Status:\n"
    
    // Check Xcode version
    if let xcodeVersion = runShellCommand(["xcodebuild", "-version"]) {
        let firstLine = xcodeVersion.components(separatedBy: "\n").first ?? ""
        output += "✓ Xcode: \(firstLine)\n"
    } else {
        output += "✗ Xcode: Not installed or not in PATH\n"
    }
    
    // Check active path
    if let activePath = runShellCommand(["xcode-select", "-p"]) {
        let xcodePath = activePath.replacingOccurrences(of: "/Contents/Developer", with: "")
        output += "✓ Active Path: \(xcodePath)\n"
    } else {
        output += "✗ Active Path: Not set\n"
    }
    
    // Check command line tools
    let cltCheck = runShellCommand(["xcode-select", "-p"])
    output += cltCheck != nil ? "✓ Command Line Tools: Installed\n" : "✗ Command Line Tools: Not installed\n"
    
    // Check Swift version
    if let swiftVersion = runShellCommand(["swift", "--version"]) {
        // Extract just the version number
        if let range = swiftVersion.range(of: "Swift version [0-9.]+", options: .regularExpression) {
            let version = String(swiftVersion[range]).replacingOccurrences(of: "Swift version ", with: "")
            output += "✓ Swift: \(version)\n"
        } else {
            output += "✓ Swift: Installed\n"
        }
    } else {
        output += "✗ Swift: Not found\n"
    }
    
    // Check SDK version
    if let sdkVersion = runShellCommand(["xcrun", "--show-sdk-version"]) {
        output += "✓ SDK: macOS \(sdkVersion)\n"
    } else {
        output += "✗ SDK: Not found\n"
    }
    
    // Check Xcode license
    let licenseCheck = runShellCommand(["xcodebuild", "-checkFirstLaunchStatus"])
    if licenseCheck != nil {
        output += "✓ License: Accepted\n"
    } else {
        output += "✗ License: May need acceptance (run 'sudo xcodebuild -license')\n"
    }
    
    // Check developer mode (for iOS device debugging)
    let devModeCheck = runShellCommand(["DevToolsSecurity", "-status"])
    if let status = devModeCheck, status.contains("enabled") {
        output += "✓ Developer Mode: Enabled"
    } else {
        output += "✗ Developer Mode: Disabled (run 'DevToolsSecurity -enable')"
    }
    
    return output
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

