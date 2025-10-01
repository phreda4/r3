#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <termios.h>
#include <fcntl.h>
#include <errno.h>

// --- Secuencias de escape de Ratón y Terminal ---
#define MOUSE_ON    "\x1b[?1000h" 
#define MOUSE_OFF   "\x1b[?1000l" 
#define MOUSE_PREFIX "\x1b[M" 

// Almacena la configuración original de la terminal y los flags del descriptor de archivo
struct termios original_termios;
int original_flags;

// --- Funciones de Configuración de Terminal ---

/**
 * @brief Restaura el modo canónico, deshabilita el ratón y el modo no bloqueante.
 */
void restore_terminal() {
    // 1. Deshabilita el seguimiento del ratón
    printf(MOUSE_OFF); 
    fflush(stdout);
    
    // 2. Restaura la configuración original (modo canónico, eco, etc.)
    tcsetattr(STDIN_FILENO, TCSANOW, &original_termios); 

    // 3. Restaura los flags del descriptor de archivo (quita O_NONBLOCK)
    fcntl(STDIN_FILENO, F_SETFL, original_flags);
    
    printf("\nTerminal restaurada.\n");
}

/**
 * @brief Configura la terminal en modo "raw" y en modo NO BLOQUEANTE.
 */
void setup_terminal() {
    struct termios new_termios;
    
    // 1. Guarda y registra la función de limpieza
    tcgetattr(STDIN_FILENO, &original_termios);
    atexit(restore_terminal); 

    // 2. Habilita el modo NO BLOQUEANTE
    original_flags = fcntl(STDIN_FILENO, F_GETFL);
    if (fcntl(STDIN_FILENO, F_SETFL, original_flags | O_NONBLOCK) == -1) {
        perror("Error al configurar O_NONBLOCK");
        exit(EXIT_FAILURE);
    }
    
    // 3. Configura el modo "raw"
    new_termios = original_termios;
    new_termios.c_lflag &= ~(ICANON | ECHO); 
    new_termios.c_cc[VMIN] = 0; // Lee 0 o más caracteres
    new_termios.c_cc[VTIME] = 0; // Temporizador 0
    
    tcsetattr(STDIN_FILENO, TCSANOW, &new_termios);
    
    // 4. Habilita el seguimiento del ratón
    printf(MOUSE_ON); 
    printf("Modo NO BLOQUEANTE activo. Bucle ejecutándose continuamente.\n");
    printf("Presiona 'q' para salir.\n");
    fflush(stdout);
}

// --- Procesamiento de Eventos de Ratón (Misno comportamiento) ---

void process_mouse_event(char c, char x_char, char y_char) {
    int button_byte = c - 32; 
    int x = x_char - 32;      
    int y = y_char - 32;      
    
    int button = button_byte & 0x03; 
    int is_drag = (button_byte & 0x08);    
    
    const char *btn_name;
    const char *action;

    if (button_byte == 64) {
        printf("🖱️ Rueda Arriba en Columna %d, Fila %d\n", x, y);
        return;
    } else if (button_byte == 65) {
        printf("🖱️ Rueda Abajo en Columna %d, Fila %d\n", x, y);
        return;
    }
    
    switch (button) {
        case 0: btn_name = "Izquierdo"; break;
        case 1: btn_name = "Central";   break;
        case 2: btn_name = "Derecho";   break;
        default: btn_name = "Desconocido"; break;
    }

    if (is_drag) {
        action = "Arrastre";
    } else {
        action = (button_byte >= 32 && button_byte <= 34) ? "PRESIONAR" : "LIBERAR/Movimiento";
    }

    printf("✨ Ratón %s: %s en Columna %d, Fila %d\n", btn_name, action, x, y);
    fflush(stdout);
}

// --- Procesamiento de Teclas Especiales (Mismo comportamiento) ---

int process_special_key(const char *buffer, int bytes_read) {
    if (bytes_read == 3 && buffer[0] == '\x1b' && buffer[1] == 'O') {
        const char *key_name;
        switch (buffer[2]) {
            case 'P': key_name = "F1"; break;
            case 'Q': key_name = "F2"; break;
            case 'R': key_name = "F3"; break;
            case 'S': key_name = "F4"; break;
            default: return 0;
        }
        printf("⌨️ Tecla ESPECIAL: [%s] PRESIONADA\n", key_name);
        fflush(stdout);
        return 1;
    }
    
    if (bytes_read == 3 && buffer[0] == '\x1b' && buffer[1] == '[') {
        const char *key_name;
        switch (buffer[2]) {
            case 'A': key_name = "Flecha Arriba"; break;
            case 'B': key_name = "Flecha Abajo"; break;
            case 'C': key_name = "Flecha Derecha"; break;
            case 'D': key_name = "Flecha Izquierda"; break;
            case 'H': key_name = "Home"; break;    
            case 'F': key_name = "End"; break;     
            default: return 0;
        }
        printf("⌨️ Tecla ESPECIAL: [%s] PRESIONADA\n", key_name);
        fflush(stdout);
        return 1;
    }
    
    if (bytes_read >= 4 && buffer[0] == '\x1b' && buffer[1] == '[') {
        // Secuencias de teclas más largas (F5-F12, etc.)
        printf("⌨️ Secuencia especial (DEBUG): ");
        for (int i = 0; i < bytes_read; i++) {
            printf("\\x%02x", (unsigned char)buffer[i]);
        }
        printf("\n");
        fflush(stdout);
        return 1;
    }
    
    return 0; 
}

// --- Función Principal ---

int main() {
    setup_terminal(); 
    
    char buffer[10]; 
    int bytes_read;
    
    while (1) {
        // El bucle principal se ejecuta constantemente
        
        // Intentamos leer datos. read() regresa inmediatamente si no hay nada.
        bytes_read = read(STDIN_FILENO, buffer, sizeof(buffer));

        if (bytes_read > 0) {
            // Se leyó un evento (tecla o ratón)
            
            // 1. Condición de salida
            if (buffer[0] == 'q' && bytes_read == 1) {
                break;
            }

            // 2. Detección de Evento de Ratón
            if (bytes_read >= 4 && strncmp(buffer, MOUSE_PREFIX, 3) == 0) {
                process_mouse_event(buffer[3], buffer[4], buffer[5]); 
            } 
            // 3. Detección de Teclas Especiales
            else if (buffer[0] == '\x1b' && process_special_key(buffer, bytes_read)) {
                // Ya procesado
            }
            // 4. Detección de Teclas Regulares
            else if (bytes_read == 1) {
                char display_char = buffer[0];
                if (buffer[0] == '\n' || buffer[0] == '\r') {
                    printf("⌨️ Tecla REGULAR: [ENTER] PRESIONADA\n");
                } else if (buffer[0] == 0x7f) {
                     printf("⌨️ Tecla REGULAR: [BACKSPACE] PRESIONADA\n");
                } else if (display_char >= ' ' && display_char <= '~') {
                    printf("⌨️ Tecla REGULAR: '%c' PRESIONADA\n", display_char);
                } else {
                    printf("⌨️ Tecla REGULAR: Código ASCII %d PRESIONADA\n", buffer[0]);
                }
                fflush(stdout);
            }
        } else if (bytes_read == -1 && errno != EAGAIN && errno != EWOULDBLOCK) {
            // Error real diferente al 'No hay datos'
            perror("Error de lectura");
            break;
        }
        
        // Aquí puedes realizar otras tareas de tu programa que no dependen de la entrada.
        // Por ejemplo: actualizar la pantalla, realizar cálculos, etc.
        // Para que la CPU no se sobrecargue en este ejemplo, agregamos una pausa mínima.
        usleep(1000); // Pausa de 1 milisegundo (opcional)
    }

    return 0;
}