#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <linux/input.h>
#include <string.h>
#include <dirent.h>
#include <errno.h>
#include <sys/ioctl.h>
#include <sys/select.h>

// === Mapas de nombres simples ===
const char* key_name(int code) {
    switch (code) {
        case KEY_A: return "A";
        case KEY_B: return "B";
        case KEY_C: return "C";
        case KEY_ENTER: return "ENTER";
        case KEY_ESC: return "ESC";
        case KEY_SPACE: return "SPACE";
        default: return "OTRA_TECLA";
    }
}

const char* mouse_button_name(int code) {
    switch (code) {
        case BTN_LEFT: return "Izquierdo";
        case BTN_RIGHT: return "Derecho";
        case BTN_MIDDLE: return "Central";
        default: return "OtroBoton";
    }
}

const char* rel_name(int code) {
    switch (code) {
        case REL_X: return "RelX";
        case REL_Y: return "RelY";
        case REL_WHEEL: return "Rueda";
        default: return "OtroRel";
    }
}

const char* abs_name(int code) {
    switch (code) {
        case ABS_X: return "AbsX";
        case ABS_Y: return "AbsY";
        default: return "OtroAbs";
    }
}

// === Buscar dispositivo con palabra clave ===
int find_device(const char *keyword, char *out_path, size_t out_size) {
    struct dirent *de;
    DIR *dr = opendir("/dev/input/");
    if (!dr) return -1;

    while ((de = readdir(dr)) != NULL) {
        if (strncmp("event", de->d_name, 5) == 0) {
            char fname[512];
            snprintf(fname, sizeof(fname), "/dev/input/%s", de->d_name);
            int fd = open(fname, O_RDONLY);
            if (fd < 0) continue;

            char name[256] = "Desconocido";
            if (ioctl(fd, EVIOCGNAME(sizeof(name)), name) >= 0) {
                if (strcasestr(name, keyword)) {
                    strncpy(out_path, fname, out_size);
                    close(fd);
                    closedir(dr);
                    return 0;
                }
            }
            close(fd);
        }
    }
    closedir(dr);
    return -1;
}

// === Programa principal ===
int main() {
    char teclado[512], mouse[512];
    if (find_device("keyboard", teclado, sizeof(teclado)) != 0) {
        fprintf(stderr, "No se encontro teclado.\n");
        return 1;
    }
    if (find_device("mouse", mouse, sizeof(mouse)) != 0) {
        fprintf(stderr, "No se encontro raton.\n");
        return 1;
    }

    printf("Usando teclado: %s\n", teclado);
    printf("Usando mouse  : %s\n", mouse);

    int fd_kb = open(teclado, O_RDONLY);
    int fd_ms = open(mouse, O_RDONLY);
    if (fd_kb < 0 || fd_ms < 0) {
        perror("Error abriendo dispositivos");
        return 1;
    }

    struct input_event ev;
    fd_set readfds;

    while (1) {
        FD_ZERO(&readfds);
        FD_SET(fd_kb, &readfds);
        FD_SET(fd_ms, &readfds);
        int maxfd = (fd_kb > fd_ms ? fd_kb : fd_ms) + 1;

        int ret = select(maxfd, &readfds, NULL, NULL, NULL);
        if (ret > 0) {
            // --- Teclado ---
            if (FD_ISSET(fd_kb, &readfds)) {
                if (read(fd_kb, &ev, sizeof(ev)) == sizeof(ev)) {
                    if (ev.type == EV_KEY) {
                        printf("[KB] %s %s\n",
                               key_name(ev.code),
                               ev.value ? "PRESIONADA" : "LIBERADA");
                    }
                }
            }

            // --- Mouse ---
            if (FD_ISSET(fd_ms, &readfds)) {
                if (read(fd_ms, &ev, sizeof(ev)) == sizeof(ev)) {
                    if (ev.type == EV_KEY) {
                        printf("[MS] Boton %s %s\n",
                               mouse_button_name(ev.code),
                               ev.value ? "PRESIONADO" : "LIBERADO");
                    }
                    else if (ev.type == EV_REL) {
                        printf("[MS] Movimiento %s = %d\n",
                               rel_name(ev.code), ev.value);
                    }
                    else if (ev.type == EV_ABS) {
                        printf("[MS] Coordenada %s = %d\n",
                               abs_name(ev.code), ev.value);
                    }
                }
            }
        }
    }

    close(fd_kb);
    close(fd_ms);
    return 0;
}
