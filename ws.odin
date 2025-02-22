package wsserver

import "core:c"

// Opaque type for `pthread_t` from libpthread
PThread :: [size_of(rawptr)]u8
// Opaque type for `pthread_mutex_t` from libpthread
PThread_Mutex :: [40]u8
// Opaque type for `pthread_cond_t` from libpthread
PThread_Cond :: [48]u8

// Alias for `ws_server`
Server :: struct {
	host:        cstring,
	port:        u16,
	thread_loop: c.int,
	timeout_ms:  u32,
	evs:         Events,
	ctx:         rawptr,
}

// Alias for `ws_cli_conn_t`
Client_Connection :: u64

// Alias for  `ws_connection`
Connection :: struct {
	client_sock:        c.int,
	state:              c.int,
	ws_srv:             Server,
	mtx_state:          PThread_Mutex,
	cnd_state_close:    PThread_Cond,
	thrd_tout:          PThread,
	close_thrd:         bool,
	mtx_snd:            PThread_Mutex,
	ip:                 [1024]u8,
	port:               [32]u8,
	last_pong_id:       i32,
	current_ping_id:    i32,
	mtx_ping:           PThread_Mutex,
	connection_context: rawptr,
	client_id:          Client_Connection,
}

MESSAGE_LENGTH :: 2048

Frame_Data :: struct {
	frm:        [MESSAGE_LENGTH]u8,
	msg:        [^]u8,
	msg_ctrl:   [125]u8,
	cur_pos:    c.size_t,
	amt_rad:    c.size_t,
	frame_type: Frame_Type,
	frame_size: u64,
	error:      c.int,
	client:     ^Connection,
}

Connection_State :: enum (c.int) {
	Invalid_Client = -1,
	Connecting     = 0,
	Open           = 1,
	Closing        = 2,
	Closed         = 3,
}

Frame_Type :: enum (c.int) {
	Fin          = 128,
	Fin_Shift    = 7,
	Continuation = 0,
	Text         = 1,
	Binary       = 2,
	Close        = 8,
	Ping         = 9,
	Pong         = 0xA,
	Unsupported  = 0xF,
}

Events :: struct {
	onopen:    proc(client: Client_Connection),
	onclose:   proc(client: Client_Connection),
	onmessage: proc(client: Client_Connection, msg: [^]u8, size: u64, type: Frame_Type),
}

when ODIN_OS == .Windows do foreign import ws "libws.lib"
when ODIN_OS == .Linux do foreign import ws "libws.a"
when ODIN_OS == .Darwin do foreign import ws "libws.a"

@(link_prefix = "ws_")
foreign ws {
	get_server_context :: proc(client: Client_Connection) -> rawptr ---
	get_connection_context :: proc(client: Client_Connection) -> rawptr ---
	set_connection_context :: proc(client: Client_Connection, ptr: rawptr) ---
	getaddress :: proc(client: Client_Connection) -> cstring ---
	getport :: proc(client: Client_Connection) -> cstring ---
	sendframe :: proc(client: Client_Connection, msg: [^]u8, size: u64, type: Frame_Type) -> c.int ---
	sendframe_bcast :: proc(port: u16, msg: [^]u8, size: u64, type: Frame_Type) -> c.int ---
	ping :: proc(client: Client_Connection, threshold: c.int) ---
	sendframe_txt :: proc(client: Client_Connection, msg: cstring) -> c.int ---
	sendframe_txt_bcast :: proc(port: u16, msg: cstring) -> c.int ---
	sendframe_bin :: proc(client: Client_Connection, msg: []u8, size: u64) -> c.int ---
	sendframe_bin_bcast :: proc(port: u16, msg: [^]u8, size: u64) -> c.int ---
	get_state :: proc(client: Client_Connection) -> Connection_State ---
	close_client :: proc(client: Client_Connection) -> c.int ---
	socket :: proc(server: ^Server) -> c.int ---
}
