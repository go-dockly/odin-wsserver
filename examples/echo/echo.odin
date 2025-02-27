package echo

import ws "../.."
import "base:runtime"
import "core:c"
import "core:c/libc"
import "core:fmt"
import "core:mem"
import "core:slice"
import "core:strings"

PORT :: 8080

on_open :: proc(client: ws.Client_Connection) {
	client_addr := ws.getaddress(client)
	client_port := ws.getport(client)

	fmt.printf("Connection opened, addr: %s, port: %s\n", client_addr, client_port)
}


on_close :: proc(client: ws.Client_Connection) {
	client_addr := ws.getaddress(client)

	fmt.printf("Connection closed, addr: %s\n", client_addr)
}

on_message :: proc(client: ws.Client_Connection, msg: []u8, type: ws.Frame_Type) {
	client_addr := ws.getaddress(client)

	message := "<not parsed>"
	if type == .Text {
		message = string(msg)
	}

	fmt.printf(
		"I received a message '%s', size %d, type %s from client %s\n",
		message,
		len(msg),
		type,
		client_addr,
	)

	ws.send_frame(client, msg, type)
}

main :: proc() {
	socket := ws.Server {
		host = "0.0.0.0",
		port = PORT,
		timeout_ms = 1000,
		evs = {onopen = on_open, onclose = on_close, onmessage = on_message},
	}

	fmt.printfln("Listening on port %d", PORT)
	ws.listen(&socket)
	fmt.printfln("Socket closed")
}
