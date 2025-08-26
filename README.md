# Swift Dev Tools MCP Server

A Model Context Protocol (MCP) server that provides essential Swift and iOS/macOS development tools through a standardized interface. This server enables AI assistants and other MCP clients to access common development environment information and tools.

## Features

The server provides the following tools:

- **Swift Version** - Get the current Swift version installed on the system
- **List Simulators** - List all available iOS/macOS simulators
- **Xcode Version** - Get Xcode version and build information
- **Xcode SDKs** - List all available Xcode SDKs
- **Connected Devices** - List all connected iOS/macOS devices
- **macOS Version** - Get macOS version information
- **System Architecture** - Get system architecture (arm64/x86_64)

## Requirements

- macOS 13.0 or later
- Swift 6.1 or later
- Xcode (for development tools functionality)

## Installation

### Building from Source

1. Clone the repository:
```bash
git clone <repository-url>
cd swift-dev-tools-mcp
```

2. Build the project:
```bash
swift build -c release
```

3. The executable will be available at `.build/release/swift-dev-tools-mcp`

### Using Swift Package Manager

Add this package as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(url: "<repository-url>", from: "1.0.0")
]
```

## Usage

### As an MCP Server

Run the server directly:

```bash
swift run swift-dev-tools-mcp
```

Or use the built executable:

```bash
.build/release/swift-dev-tools-mcp
```

The server communicates via stdio using the Model Context Protocol.

### Integration with MCP Clients

Configure your MCP client to use this server. For example, with Claude Desktop, add to your configuration:

```json
{
  "mcpServers": {
    "swift-dev-tools": {
        "command": "<Path of the project>/swift-dev-tools-mcp/.build/arm64-apple-macosx/debug/swift-dev-tools-mcp"
    }
  }
}
```

## Available Tools

### `swift_version`
Returns the current Swift version installed on the system.

**Example output:**
```
swift-driver version: 1.87.3 Apple Swift version 5.9.2
```

### `list_simulator`
Lists all available iOS/macOS simulators using `xcrun simctl`.

**Example output:**
```
== Devices ==
-- iOS 17.2 --
    iPhone 15 (12345678-1234-1234-1234-123456789012) (Shutdown)
    iPhone 15 Pro (87654321-4321-4321-4321-210987654321) (Shutdown)
```

### `xcode_version`
Returns Xcode version and build information.

**Example output:**
```
Xcode 15.2
Build version 15C500b
```

### `xcode_sdks`
Lists all available Xcode SDKs.

**Example output:**
```
iOS SDKs:
    iOS 17.2                        -sdk iphoneos17.2

macOS SDKs:
    macOS 14.2                      -sdk macosx14.2
```

### `connected_devices`
Lists all connected iOS/macOS devices using `xcrun xctrace`.

### `macos_version`
Returns macOS version information using `sw_vers`.

**Example output:**
```
ProductName:        macOS
ProductVersion:     14.2.1
BuildVersion:       23C71
```

### `system_architecture`
Returns the system architecture (arm64 or x86_64).

**Example output:**
```
arm64
```

## Architecture

The server is built using:

- **Swift MCP SDK** - Official Swift SDK for Model Context Protocol
- **Foundation** - For system process execution
- **Stdio Transport** - Communication via standard input/output

The server executes system commands using `Process` and returns formatted results through the MCP protocol.

## Development

### Project Structure

```
swift-dev-tools-mcp/
├── Package.swift           # Swift package configuration
├── Package.resolved        # Dependency lock file
├── Sources/
│   └── main.swift         # Main server implementation
└── README.md              # This file
```

### Adding New Tools

To add a new development tool:

1. Define a new `Tool` instance with name, description, and input schema
2. Add the tool to the `tools` array in the `ListTools` handler
3. Add a case for the tool in the `CallTool` handler
4. Implement the corresponding function that executes the system command

### Dependencies

- [Swift MCP SDK](https://github.com/modelcontextprotocol/swift-sdk) - Official MCP implementation for Swift

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

[Add your license information here]

## Support

For issues and questions:
- Open an issue on GitHub
- Check the [Model Context Protocol documentation](https://modelcontextprotocol.io/)
