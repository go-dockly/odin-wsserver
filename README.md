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
- [Sample Server](./examples/complete/complete.odin)

### Sample
<details>
<summary>Click to expand code sample</summary>

```odin
package complete

import ws "../.."
import "base:runtime"
import "core:c"
import "core:fmt"
import "core:mem"
import "core:strings"
import "core:time"

PORT :: 8080

on_open :: proc "c" (client: ws.Client_Connection) {
	context = runtime.default_context()

	client_addr := ws.getaddress(client)
	client_port := ws.getport(client)

	fmt.printf("Connection opened, addr: %s, port: %s\n", client_addr, client_port)
	ws.send_text_frame(client, "you are now connected!")
}


on_close :: proc "c" (client: ws.Client_Connection) {
	context = runtime.default_context()

	client_addr := ws.getaddress(client)
	fmt.printf("Connection closed, addr: %s\n", client_addr)
}

on_message :: proc "c" (client: ws.Client_Connection, msg: [^]u8, size: u64, type: ws.Frame_Type) {
	context = runtime.default_context()

	client_addr := ws.getaddress(client)

	message := "<not parsed>"
	if type == .Text {
		message = strings.string_from_null_terminated_ptr(msg, int(size))
	}

	fmt.printf(
		"I received a message '%s', size %d, type %s from client %s\n",
		message,
		size,
		type,
		client_addr,
	)


	ws.send_text_frame(client, "hello")
	time.sleep(2 * time.Second)
	ws.send_text_frame(client, "world")
	time.sleep(2 * time.Second)

	out_msg := fmt.aprintf("you sent a %s message", type)
	defer delete(out_msg)

	ws.send_text_frame(client, out_msg)
	time.sleep(2 * time.Second)

	ws.send_text_frame(client, "closing connection in 2 seconds")
	time.sleep(2 * time.Second)

	ws.send_text_frame(client, "bye!")
	ws.close_client(client)
}

main :: proc() {
	server := ws.Server {
		host = "0.0.0.0",
		port = PORT,
		timeout_ms = 1000,
		thread_loop = 0,
		evs = {onmessage = on_message, onclose = on_close, onopen = on_open},
	}

	fmt.printfln("Listening on port %d", PORT)
	ws.listen(&server)
	fmt.printfln("Socket closed")
}
```
</details>

## API Documentation

For API details, I recommend checking the [ws.odin](./ws.odin) file and reading the source code of the underlying library.

## Contributing

Contributions are welcome! Feel free to submit issues and pull requests to improve this library.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

For more details on `wsServer`, visit the official repository: [Theldus/wsServer](https://github.com/Theldus/wsServer).
