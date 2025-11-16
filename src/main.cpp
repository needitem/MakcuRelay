#define WIN32_LEAN_AND_MEAN

#include <windows.h>
#include <winsock2.h>
#include <ws2tcpip.h>

#include <atomic>
#include <csignal>
#include <iostream>
#include <string>

#include "MakcuConnection.h"

static std::atomic<bool> g_running{ true };

void signalHandler(int)
{
    g_running.store(false);
}

int main(int argc, char** argv)
{
    std::string comPort = "COM3";
    unsigned short udpPort = 5005;

    if (argc >= 2) {
        comPort = argv[1];
    }
    if (argc >= 3) {
        try {
            udpPort = static_cast<unsigned short>(std::stoi(argv[2]));
        } catch (...) {
            std::cerr << "[MakcuRelay] Invalid UDP port, using default 5005\n";
        }
    }

    std::cout << "[MakcuRelay] COM port: " << comPort
              << ", UDP port: " << udpPort << std::endl;

    WSADATA wsaData;
    int wsaErr = WSAStartup(MAKEWORD(2, 2), &wsaData);
    if (wsaErr != 0) {
        std::cerr << "[MakcuRelay] WSAStartup failed: " << wsaErr << std::endl;
        return 1;
    }

    SOCKET sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (sock == INVALID_SOCKET) {
        std::cerr << "[MakcuRelay] socket() failed: " << WSAGetLastError() << std::endl;
        WSACleanup();
        return 1;
    }

    sockaddr_in addr{};
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(INADDR_ANY);
    addr.sin_port = htons(udpPort);

    if (bind(sock, reinterpret_cast<SOCKADDR*>(&addr), sizeof(addr)) == SOCKET_ERROR) {
        std::cerr << "[MakcuRelay] bind() failed: " << WSAGetLastError() << std::endl;
        closesocket(sock);
        WSACleanup();
        return 1;
    }

    int timeoutMs = 50;
    setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO,
               reinterpret_cast<const char*>(&timeoutMs), sizeof(timeoutMs));

    MakcuConnection makcu(comPort, 4000000);
    if (!makcu.isOpen()) {
        std::cerr << "[MakcuRelay] Failed to open Makcu on " << comPort << std::endl;
        closesocket(sock);
        WSACleanup();
        return 1;
    }

    std::cout << "[MakcuRelay] Listening for UDP commands (MOVE:x,y / CLICK:LEFT|RIGHT)...\n";
    std::cout << "[MakcuRelay] Press Ctrl+C to exit.\n";

    std::signal(SIGINT, signalHandler);
    std::signal(SIGTERM, signalHandler);

    char buffer[256];

    while (g_running.load()) {
        sockaddr_in from{};
        int fromLen = sizeof(from);
        int ret = recvfrom(sock, buffer, sizeof(buffer) - 1, 0,
                           reinterpret_cast<SOCKADDR*>(&from), &fromLen);

        if (ret == SOCKET_ERROR) {
            int err = WSAGetLastError();
            if (err == WSAETIMEDOUT || err == WSAEWOULDBLOCK) {
                continue;
            }
            if (!g_running.load()) {
                break;
            }
            std::cerr << "[MakcuRelay] recvfrom() error: " << err << std::endl;
            continue;
        }

        if (ret <= 0) {
            continue;
        }

        buffer[ret] = '\0';
        std::string msg(buffer);

        while (!msg.empty() && (msg.back() == '\r' || msg.back() == '\n' || msg.back() == ' ')) {
            msg.pop_back();
        }

        if (msg.rfind("MOVE:", 0) == 0) {
            std::string rest = msg.substr(5);
            auto commaPos = rest.find(',');
            if (commaPos != std::string::npos) {
                try {
                    int dx = std::stoi(rest.substr(0, commaPos));
                    int dy = std::stoi(rest.substr(commaPos + 1));
                    makcu.move(dx, dy);
                } catch (...) {
                    std::cerr << "[MakcuRelay] Invalid MOVE payload: " << msg << std::endl;
                }
            }
        } else if (msg.rfind("PRESS:", 0) == 0) {
            std::string btn = msg.substr(6);
            if (btn == "LEFT") {
                makcu.press(1);
            } else if (btn == "RIGHT") {
                makcu.press(2);
            }
        } else if (msg.rfind("RELEASE:", 0) == 0) {
            std::string btn = msg.substr(8);
            if (btn == "LEFT") {
                makcu.release(1);
            } else if (btn == "RIGHT") {
                makcu.release(2);
            }
        } else if (msg.rfind("CLICK:", 0) == 0) {
            std::string btn = msg.substr(6);
            if (btn == "LEFT") {
                makcu.click(1);
            } else if (btn == "RIGHT") {
                makcu.click(2);
            }
        }
    }

    closesocket(sock);
    WSACleanup();

    std::cout << "[MakcuRelay] Exiting.\n";
    return 0;
}
