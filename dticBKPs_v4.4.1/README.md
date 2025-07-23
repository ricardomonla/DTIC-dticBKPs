# dtic_Backups - Procesador de Backups Automatizado v4.ruby.3.5

`dtic_Backups` es un script de terminal interactivo escrito en Ruby, diseñado para automatizar el procesamiento, la compresión y la sincronización de copias de seguridad. Esta versión introduce una estructura de archivos modular, una configuración simplificada y la capacidad de editar tareas directamente desde la aplicación.

## ✨ Características Principales

*   **Menú Interactivo y Editable:** Navega, ejecuta, y ahora también **crea, edita y elimina tareas** sin salir de la aplicación.
*   **Ejecución Automática:** Un reloj con cuenta regresiva permite ejecutar tareas de forma secuencial y desatendida, ideal para scripts programados (`cron`).
*   **Configuración Simplificada:** La definición de tareas se ha estandarizado con claves `origen` y `destino`, independientemente de si la ruta es local o remota (`rclone`).
*   **Estructura Modular:** El código está organizado en archivos separados para la aplicación principal, la configuración, la instalación y el logging, mejorando la mantenibilidad.
*   **Soporte Multi-plataforma:** Procesamiento nativo para backups de **XenServer/XCP-ng** (`.xva`) y **Proxmox VE**.
*   **Sincronización Universal con `rclone`:** Sincroniza archivos entre cualquier combinación de rutas locales y remotas.
*   **Feedback Visual y Logging:** Mantiene la interfaz de usuario clara con colores, íconos, barras de progreso y un registro detallado en `dticBKPs.log`.

## 📂 Estructura del Proyecto

El proyecto se compone de los siguientes archivos:

*   `dticBKPs_app.rb`: El script principal que ejecuta la aplicación y su menú interactivo.
*   `dticBKPs_install.rb`: Un script de instalación para verificar dependencias y generar la configuración inicial.
*   `dticBKPs_conf.rb`: El archivo donde se guardan las tareas y las preferencias. **Este archivo es modificable desde la propia aplicación**.
*   `dticBKPs_log.rb`: Módulo que configura el sistema de registro de actividad (`logging`).
*   `README.md`: Este archivo.
*   `LICENSE`: La licencia del proyecto.

## 🚀 Instalación y Puesta en Marcha (Debian/Ubuntu)

La instalación está diseñada para ser lo más simple posible. Solo necesitas ejecutar un único script que se encargará de todo.

1.  **Clona o descarga todos los archivos** del proyecto en un mismo directorio.

2.  **Otorga permisos de ejecución** al script de instalación principal:
    ```bash
    chmod +x install.sh
    ```

3.  **Ejecuta el instalador:**
    ```bash
    ./install.sh
    ```

El script verificará si tienes `Ruby` instalado. Si no es así, te pedirá permiso para instalarlo. Una vez que el entorno esté listo, lanzará automáticamente el instalador de la aplicación, que a su vez verificará las demás dependencias (`rclone`, `pv`, etc.) y te guiará en el resto del proceso.

## 🔧 Configuración de Tareas

Ahora puedes configurar las tareas de dos maneras:

1.  **Editando `dticBKPs_conf.rb` manualmente** (método tradicional).
2.  **Usando el editor integrado** en la aplicación (opción `E` en el menú principal).

### Formato de Tarea Simplificado

El formato de las tareas se ha estandarizado. `rclone` se usa para cualquier tarea de sincronización, y el script detecta automáticamente si una ruta es remota (si contiene un `:`).

| Clave                  | Descripción                                                                              | Ejemplo                               |
| ---------------------- | ---------------------------------------------------------------------------------------- | ------------------------------------- |
| `id`                   | Símbolo único para la tarea.                                                             | `:xen_procesar`                       |
| `menu_texto`           | Descripción que se muestra en el menú.                                                   | `"Procesar backups Xen01 (.xva)"`     |
| `tipo_proceso`         | `:xva`, `:proxmox_log_notes` o `:rclone_sync`.                                           | `:rclone_sync`                        |
| `origen`               | Ruta de origen (local o remota `rclone`).                                                | `"miRemoto:/var/lib/vz/dump/"`        |
| `destino`              | Ruta de destino (local o remota `rclone`).                                               | `"/media/backups/pmox1_sync/"`        |
| `eliminar_origen`      | `true` o `false`. Borra archivos originales tras el procesamiento. (No aplica a `rclone`) | `true`                                |
| `sobrescribir_destino` | `true` o `false`. Sobrescribe archivos en el destino si ya existen.                       | `false`                               |

## ▶️ Uso de la Aplicación

Ejecuta `./dticBKPs_app.rb` para iniciar el menú. Las opciones son:

*   `[Enter]`: Ejecuta la tarea seleccionada.
*   `[Número]`: Cambia la tarea seleccionada.
*   `[E]`: Entra al modo de edición de tareas.
*   `[P] / [R]`: Pausa o Reanuda el reloj de auto-avance.
*   `[S]`: Sale de la aplicación.

### Modo Edición

Dentro del modo de edición, puedes:
*   **Editar** una tarea existente.
*   Añadir una **Nueva** tarea.
*   **Borrar** una tarea.
*   **Guardar** los cambios en `dticBKPs_conf.rb` y volver al menú principal.

## ✍️ Autor

*   **Ricardo MONLA (rmonla@)**

## 📜 Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo `LICENSE` para más detalles.