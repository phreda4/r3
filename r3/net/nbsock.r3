
#WSAData * 512

#AF_INET 2
#SOCK_STREAM 1
#IPPROTO_TCP 6

#PORT 80

#server_socket
#server_addr 0 0

#client_addr 0 0
#client_size 16

:BUFF_SIZE 4096 ;
#LOCALHOST "127.0.0.1"

#sock
#rx_buf 4096
#rx_len

:init_winsock 
  WSADATA wsa;
  if (WSAStartup(MAKEWORD(2, 2), &wsa)) {
    fprintf(stderr, "WSAStartup error\n");
    exit(1);
  ;

void cleanup_winsock(void) {
#ifdef _WIN32
  WSACleanup();
#endif
}

int server_create(int port) {
  struct sockaddr_in addr;
  
  conn.sock = socket(AF_INET, SOCK_STREAM, 0);
  if (conn.sock == INVALID_SOCKET) {
    perror("socket");
    return -1;
  }
  
  SET_NONBLOCK(conn.sock);
  
  int reuse = 1;
  if (setsockopt(conn.sock, SOL_SOCKET, SO_REUSEADDR, (char*)&reuse, sizeof(reuse)) < 0) {
    perror("setsockopt");
    CLOSE_SOCK(conn.sock);
    return -1;
  }
  
  memset(&addr, 0, sizeof(addr));
  addr.sin_family = AF_INET;
  addr.sin_addr.s_addr = inet_addr(LOCALHOST);
  addr.sin_port = htons(port);
  
  if (bind(conn.sock, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
    perror("bind");
    CLOSE_SOCK(conn.sock);
    return -1;
  }
  
  if (listen(conn.sock, 1) < 0) {
    perror("listen");
    CLOSE_SOCK(conn.sock);
    return -1;
  }
  
  printf("Servidor escuchando en 127.0.0.1:%d\n", port);
  conn.rx_len = 0;
  return 0;
}

int client_connect(int port) {
  struct sockaddr_in addr;
  
  conn.sock = socket(AF_INET, SOCK_STREAM, 0);
  if (conn.sock == INVALID_SOCKET) {
    perror("socket");
    return -1;
  }
  
  SET_NONBLOCK(conn.sock);
  
  memset(&addr, 0, sizeof(addr));
  addr.sin_family = AF_INET;
  addr.sin_addr.s_addr = inet_addr(LOCALHOST);
  addr.sin_port = htons(port);
  
  if (connect(conn.sock, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
#ifdef _WIN32
    if (LAST_ERROR != WSAEWOULDBLOCK) {
#else
    if (LAST_ERROR != EINPROGRESS) {
#endif
      perror("connect");
      CLOSE_SOCK(conn.sock);
      return -1;
    }
  }
  
  printf("Conectando a 127.0.0.1:%d\n", port);
  conn.rx_len = 0;
  return 0;
}

int server_accept(void) {
  struct sockaddr_in addr;
  socklen_t len = sizeof(addr);
  SOCKET cli_sock = accept(conn.sock, (struct sockaddr*)&addr, &len);
  
  if (cli_sock == INVALID_SOCKET) {
    return -1;
  }
  
  CLOSE_SOCK(conn.sock);
  conn.sock = cli_sock;
  conn.rx_len = 0;
  SET_NONBLOCK(conn.sock);
  
  printf("Cliente conectado\n");
  return 0;
}

int sock_send(const char *data, int len) {
  int n = send(conn.sock, data, len, 0);
  return (n > 0) ? n : 0;
}

int sock_recv(void) {
  int n = recv(conn.sock, conn.rx_buf + conn.rx_len, BUFF_SIZE - conn.rx_len - 1, 0);
  
  if (n > 0) {
    conn.rx_len += n;
    conn.rx_buf[conn.rx_len] = '\0';
    return n;
  }
  
  if (n == 0) {
    return -1;
  }
  
  if (n < 0) {
#ifdef _WIN32
    if (LAST_ERROR == WSAECONNRESET || LAST_ERROR == WSAECONNABORTED) {
      return -1;
    }
#else
    if (LAST_ERROR == ECONNRESET || LAST_ERROR == ECONNABORTED) {
      return -1;
    }
#endif
  }
  
  return 0;
}

void sock_close(void) {
  CLOSE_SOCK(conn.sock);
}

void sock_flush(void) {
  conn.rx_len = 0;
  conn.rx_buf[0] = '\0';
}

conn_t* get_conn(void) {
  return &conn;
}