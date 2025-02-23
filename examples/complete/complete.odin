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
	ws.socket(&server)
	fmt.printfln("Socket closed")
}
