# dticBKPs - Procesador de Backups Automatizado v4.4.2

`dticBKPs` es un script de terminal interactivo escrito en Ruby, diseñado para automatizar el procesamiento, la compresión y la sincronización de copias de seguridad. Esta versión introduce una estructura de archivos modular, una configuración simplificada y la capacidad de editar tareas directamente desde la aplicación.

## ✨ Características Principales

*   **Menú Interactivo y Editable:** Navega, ejecuta, y ahora también **crea, edita y elimina tareas** sin salir de la aplicación.
*   **Configuración Simplificada:** La definición de tareas se ha estandarizado con claves `origen` y `destino`, independientemente de si la ruta es local o remota (`rclone`).
*   **Estructura Modular:** El código está organizado en módulos para la aplicación principal, configuración, instalación, logging y procesadores específicos.
*   **Soporte Multiplataforma:** Procesamiento nativo para backups de **XenServer/XCP-ng** (`.xva`) y **Proxmox VE**.
*   **Sincronización Universal con `rclone`:** Sincroniza archivos entre cualquier combinación de rutas locales y remotas.
*   **Feedback Visual y Logging:** Mantiene la interfaz de usuario clara con colores, íconos, barras de progreso y un registro detallado en `dticBKPs.log`.

## 📂 Estructura del Proyecto

El proyecto tiene una estructura modular para facilitar su mantenimiento. Los archivos principales son:

*   `install.sh`: Script principal de instalación que prepara el entorno.
*   `dticBKPs_app.rb`: El script que ejecuta la aplicación y su menú interactivo.
*   `dticBKPs_install.rb`: Script en Ruby para verificar dependencias y generar la configuración inicial.
*   `dticBKPs_conf.rb`: Aquí se guardan las tareas y preferencias. **Este archivo es modificable desde la propia aplicación**.
*   `core/globals.rb`: Define constantes, colores y el logger global.
*   `fxs/`: Contiene los módulos con las funciones principales (UI, manejo de configuración y procesadores).
*   `LICENSE`: La licencia del proyecto (MIT).

## 🚀 Instalación y Puesta en Marcha (Debian/Ubuntu)

La instalación está diseñada para ser lo más simple posible.

1.  **Clona o descarga todos los archivos** del proyecto en un mismo directorio.

2.  **Otorga permisos de ejecución** al script de instalación principal:
    ```bash
    chmod +x install.sh
    ```

3.  **Ejecuta el instalador:**
    ```bash
    ./install.sh
    ```

El script verificará si tienes `Ruby` instalado y te guiará para instalarlo si es necesario. Luego, lanzará el instalador de la aplicación (`dticBKPs_install.rb`), que verificará el resto de las dependencias (`rclone`, `pv`, etc.).

## 🔧 Configuración de Tareas

Puedes configurar las tareas de dos maneras:

1.  **Editando `dticBKPs_conf.rb` manualmente** (método tradicional).
2.  **Usando el editor integrado** en la aplicación (opción `E` en el menú principal).

### Formato de Tarea Simplificado

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

*   `[Enter]` / `[Número]`: Ejecuta la tarea seleccionada.
*   `[E]`: Entra al modo de edición de tareas.
*   `[S]`: Sale de la aplicación.

### Modo Edición

Dentro del modo de edición, puedes:
*   **Editar** una tarea existente (`[Número]`).
*   Añadir una **Nueva** tarea (`[N]`).
*   **Borrar** una tarea (`[B]`).
*   **Guardar** los cambios en `dticBKPs_conf.rb` y volver al menú principal (`[G]`).

## ✍️ Autor

*   **Ricardo MONLA (rmonla@)**

## 📜 Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo `LICENSE` para más detalles.