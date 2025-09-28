#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <sys/stat.h>
#include <errno.h>

struct dirent {
    ino_t d_ino;       /* Número de inodo */
    off_t d_off;       /* Desplazamiento al siguiente dirent */
    unsigned short d_reclen; /* Longitud de este dirent */
    unsigned char d_type;  /* Tipo de archivo (ej. DT_DIR, DT_REG) */
    char d_name[256];    /* Nombre del archivo (¡El dato que más te interesa!) */
};

// Definimos el tamaño máximo para las rutas
#define PATH_MAX 4096

/**
 * Función que recorre recursivamente un directorio
 * @param ruta_actual La ruta del directorio a explorar
 */
void recorrer_recursivo(const char *ruta_actual) {
    DIR *dir;
    struct dirent *entrada;
    struct stat sb;
    char ruta_completa[PATH_MAX];

    // Abrir el directorio (opendir)
    if ((dir = opendir(ruta_actual)) == NULL) {
        fprintf(stderr, "Error abriendo el directorio %s: %s\n", ruta_actual, strerror(errno));
        return;
    }

    // Leer las entradas del directorio (readdir)
    while ((entrada = readdir(dir)) != NULL) {
        
        // 1. Excluir las entradas especiales "." y ".."
        if (strcmp(entrada->d_name, ".") == 0 || strcmp(entrada->d_name, "..") == 0) {
            continue;
        }

        // 2. Construir la ruta completa del elemento
        snprintf(ruta_completa, PATH_MAX, "%s/%s", ruta_actual, entrada->d_name);

        // 3. Obtener los metadatos (stat)
        if (stat(ruta_completa, &sb) == -1) {
            perror("Error en stat");
            continue;
        }

        // 4. Procesar el elemento
        if (S_ISDIR(sb.st_mode)) {
            // Si es un directorio: Imprimir y hacer la llamada recursiva
            printf("[DIRECTORIO]: %s\n", ruta_completa);
            recorrer_recursivo(ruta_completa); // Llamada recursiva
        } else if (S_ISREG(sb.st_mode)) {
            // Si es un archivo regular
            printf("  [ARCHIVO]: %s (Tamaño: %ld bytes)\n", ruta_completa, (long)sb.st_size);
        } else {
            // Otros tipos (enlaces simbólicos, pipes, etc.)
            printf("  [OTRO]: %s\n", ruta_completa);
        }
    }

    // Cerrar el directorio (closedir)
    closedir(dir);
}

int main(int argc, char *argv[]) {
    // Si no se proporciona una ruta, usa el directorio actual "."
    const char *ruta_inicial = (argc > 1) ? argv[1] : ".";
    
    printf("--- Iniciando recorrido recursivo desde: %s ---\n", ruta_inicial);
    recorrer_recursivo(ruta_inicial);
    printf("--- Recorrido finalizado ---\n");
    
    return 0;
}
#include <sys/types.h>
#include <time.h>

struct stat {
    dev_t     st_dev;      /* ID del dispositivo que contiene el archivo */
    ino_t     st_ino;      /* Número de inodo */
    mode_t    st_mode;     /* Modo de protección y tipo de archivo */
    nlink_t   st_nlink;    /* Número de enlaces duros (hard links) */
    uid_t     st_uid;      /* ID de usuario del propietario */
    gid_t     st_gid;      /* ID de grupo del propietario */
    dev_t     st_rdev;     /* ID del dispositivo (si es un archivo especial) */
    off_t     st_size;     /* Tamaño total del archivo en bytes */
    blksize_t st_blksize;  /* Tamaño de bloque preferido para E/S */
    blkcnt_t  st_blocks;   /* Número de bloques de 512B asignados */

    /* Timestamps (Tiempos de Acceso, Modificación y Cambio de Estado) */
    struct timespec st_atim;  /* Hora del último acceso (st_atime) */
    struct timespec st_mtim;  /* Hora de la última modificación (st_mtime) */
    struct timespec st_ctim;  /* Hora del último cambio de estado (st_ctime) */

    #ifdef __USE_XOPEN2K8
    /* Esto se define a veces para mantener la compatibilidad con nombres antiguos: */
    #define st_atime st_atim.tv_sec
    #define st_mtime st_mtim.tv_sec
    #define st_ctime st_ctim.tv_sec
    #endif
};