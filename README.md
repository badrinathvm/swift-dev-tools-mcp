# 🚀 Swift Dev Tools MCP Server

> 🛠️ **Essential Swift & iOS/macOS development tools** through the Model Context Protocol (MCP). Bridge your AI assistants with your development environment!

## ✨ What's Inside

🔧 **Development Environment Info**
- 🐦 **Swift Version** - Check your Swift installation
- 📱 **iOS/macOS Simulators** - List all available simulators
- 🔨 **Xcode Details** - Version and build information
- 📦 **Xcode SDKs** - All available development SDKs
- 🔗 **Connected Devices** - Live iOS/macOS device detection
- 🍎 **macOS System Info** - Version and architecture details

## 🎯 Quick Start

### 📋 Requirements
- 🍎 macOS 13.0+
- 🐦 Swift 6.1+
- 🔨 Xcode (for dev tools)

### 🏗️ Installation

**1️⃣ Clone & Build**
```bash
git clone <your-repo-url>
cd swift-dev-tools-mcp

# 🐛 Debug build
swift build

# 🚀 Release build  
swift build -c release
```

**2️⃣ Run the Server**
```bash
# Direct run
swift run swift-dev-tools-mcp

# Or use executable
.build/release/swift-dev-tools-mcp
```

### 🔌 MCP Client Setup

**Configure Claude Desktop:**

```json
{
  "mcpServers": {
    "swift-dev-tools": {
      "command": "/path/to/your/.build/arm64-apple-macosx/release/swift-dev-tools-mcp"
    }
  }
}
```

## 🛠️ Available Tools

| Tool | Description | Example Output |
|------|-------------|----------------|
| 🐦 `swift_version` | Current Swift version | `Apple Swift version 5.9.2` |
| 📱 `list_simulator` | iOS/macOS simulators | `iPhone 15 Pro (Shutdown)` |
| 🔨 `xcode_version` | Xcode build info | `Xcode 15.2 Build 15C500b` |
| 📦 `xcode_sdks` | Available SDKs | `iOS 17.2 -sdk iphoneos17.2` |
| 🔗 `connected_devices` | Live device list | Connected iOS/macOS devices |
| 🍎 `macos_version` | System version | `macOS 14.2.1 (23C71)` |
| ⚙️ `system_architecture` | CPU architecture | `arm64` or `x86_64` |

## 🏗️ Architecture

Built with modern Swift tools:

- 🌟 **Swift MCP SDK** - Official MCP protocol implementation
- 🏛️ **Foundation** - System process execution
- 💬 **Stdio Transport** - Standard I/O communication

## 👨‍💻 Development

### 📁 Project Structure
```
swift-dev-tools-mcp/
├── 📄 Package.swift      # Package configuration
├── 🔒 Package.resolved   # Dependency lock
├── 📁 Sources/
│   └── 🐦 main.swift    # Server implementation
└── 📖 README.md         # This guide
```

### ➕ Adding New Tools

1. 🎯 Define new `Tool` with name & description
2. ➕ Add to `tools` array in `ListTools` handler  
3. 🔀 Add case in `CallTool` handler
4. ⚙️ Implement system command function

## 🤝 Contributing

1. 🍴 Fork the repository
2. 🌿 Create feature branch
3. ✏️ Make your changes
4. 🧪 Add tests (if needed)
5. 📤 Submit pull request

## 📚 Resources

- 🔗 [Swift MCP SDK](https://github.com/modelcontextprotocol/swift-sdk)
- 📖 [MCP Documentation](https://modelcontextprotocol.io/)
- 🐛 [Report Issues](https://github.com/your-repo/issues)

---

💡 **Pro Tip:** This server bridges the gap between AI assistants and your Swift development environment, making your workflow more intelligent and automated!

🎉 **Happy Coding!** 🍎✨
