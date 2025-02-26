package chat

import ws "../.."
import "base:runtime"
import "core:fmt"
import "core:mem"
import "core:os"
import "core:slice"
import "core:strings"
import "core:sync"

on_open :: proc "c" (client: ws.Client_Connection) {
	context = runtime.default_context()
	tid := os.current_thread_id()
	fmt.printfln("[client %d][thread %d] connected", client, tid)

	ctx := cast(^Server_Context)ws.get_server_context(client)
	ctx_add_client(ctx, client)
}

on_close :: proc "c" (client: ws.Client_Connection) {
	context = runtime.default_context()
	tid := os.current_thread_id()
	fmt.printfln("[client %d][thread %d] disconnected", client, tid)

	ctx := cast(^Server_Context)ws.get_server_context(client)
	ctx_remove_client(ctx, client)
}

on_message :: proc "c" (
	client: ws.Client_Connection,
	data: [^]u8,
	size: u64,
	type: ws.Frame_Type,
) {
	context = runtime.default_context()
	defer free_all(context.temp_allocator)

	tid := os.current_thread_id()
	fmt.printfln("[client %d][thread %d] sent message", client, tid)

	if type != .Text {
		ws.send_text_frame(client, "invalid message")
		ws.close_client(client)
		return
	}

	ctx := cast(^Server_Context)ws.get_server_context(client)
	clients := ctx_clone_clients(ctx, context.temp_allocator)

	message := strings.string_from_null_terminated_ptr(data, int(size))
	chat_message := fmt.tprintf("[client %d] says: %s", client, message)
	chat_message_for_self := fmt.tprintf("You said: %s", message)
	for connection in clients {
		if connection == client {
			ws.send_text_frame(client, chat_message_for_self)
		} else {
			ws.send_text_frame(connection, chat_message)
		}
	}
}

Server_Context :: struct {
	clients: [dynamic]ws.Client_Connection,
	mutex:   ^sync.Mutex,
}

ctx_add_client :: proc(ctx: ^Server_Context, client: ws.Client_Connection) {
	sync.lock(ctx.mutex)
	defer sync.unlock(ctx.mutex)
	append_elem(&ctx.clients, client)
}

ctx_remove_client :: proc(ctx: ^Server_Context, client: ws.Client_Connection) {
	sync.lock(ctx.mutex)
	defer sync.unlock(ctx.mutex)
	idx := -1
	for other_client, index in ctx.clients {
		if other_client == client {
			idx = index
			break
		}
	}

	assert(idx >= 0)
	unordered_remove(&ctx.clients, idx)
	shrink(&ctx.clients)
}

ctx_clone_clients :: proc(
	ctx: ^Server_Context,
	allocator: mem.Allocator,
) -> []ws.Client_Connection {
	sync.lock(ctx.mutex)
	defer sync.unlock(ctx.mutex)
	return slice.clone(ctx.clients[:], allocator)
}

PORT :: 8080

main :: proc() {
	clients: [dynamic]ws.Client_Connection
	defer delete(clients)

	lock: sync.Mutex
	ctx := Server_Context{clients, &lock}


	tid := os.current_thread_id()
	server := ws.Server {
		host = "0.0.0.0",
		port = PORT,
		timeout_ms = 1000,
		evs = {onopen = on_open, onclose = on_close, onmessage = on_message},
		ctx = &ctx,
	}

	fmt.printfln("[thread %d] server started on port %d", tid, PORT)
	ws.listen(&server)
	fmt.printfln("server closed")

}
