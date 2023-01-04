import socket

HOST = "127.0.0.1"  # Standard loopback interface address (localhost)
PORT = 65432  # Port to listen on (non-privileged ports are > 1023)

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:

    s.bind((HOST, PORT))
    s.listen()

    conn, addr = s.accept()
    with conn:
        print(f"Connected by {addr}")
        while True:
            data = conn.recv(1).decode('utf-8')
            if data == 'S':
                print('Success!')
            if not data:
                break
            # print(data)
            # conn.sendall(data)

    # while True:
    #     conn, adr = s.accept()
    #     print('connected with' + adr[0] + ':' + str(adr[1]))
    #     while True:
    #         data = conn.recv(1)
    #         print(data)
    #         if not data:
    #             break
    #         # conn.sendall(data)
    #     conn.close()
    # s.close()