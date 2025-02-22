# Odin-wsServer

Odin bindings for the [wsServer](https://github.com/Theldus/wsServer) C WebSocket library.

## Overview

**Odin-wsServer** provides bindings to the lightweight and efficient [wsServer](https://github.com/Theldus/wsServer) WebSocket server library, enabling seamless WebSocket support in Odin applications. This library allows Odin developers to create WebSocket servers with minimal overhead and strong performance.

## Features

- Lightweight and efficient WebSocket server implementation.
- Direct bindings to `wsServer`, maintaining C-level performance.
- Supports multiple concurrent connections.
- Easy-to-use API for handling WebSocket messages.

## Installation

To use **odin-wsServer**, ensure that you have a copy of the static `wsServer` library (`libws.a`) in your working directory.

Follow these instructions to compile the library: [wsServer CMake Instructions](https://github.com/Theldus/wsServer/tree/master?tab=readme-ov-file#cmake)

## Usage

### Example WebSocket Server

- [Echo Server](./examples/echo/echo.odin)

## API Documentation

For API details, I recommend checking the [ws.odin](./ws.odin) file and reading the source code of the underlying library.

## Contributing

Contributions are welcome! Feel free to submit issues and pull requests to improve this library.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

For more details on `wsServer`, visit the official repository: [Theldus/wsServer](https://github.com/Theldus/wsServer).

