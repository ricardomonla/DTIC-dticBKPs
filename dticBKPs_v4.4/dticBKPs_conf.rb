# frozen_string_literal: true

# ==========================================================
#  dticBKPs - Automatic Backup Processor
#  ----------------------------------------------------------
#  APP:         dticBKPs
#  FILE:        dticBKPs_conf.rb
#  VERSION:     v4.4.2
#  AUTHOR:      Ricardo MONLA (rmonla@)
#  LICENSE:     MIT License
# ==========================================================
#
#  Este archivo contiene las tareas de backup.
#  Puede ser modificado manualmente o a través del editor
#  integrado en la aplicación (opción 'E').
#
# ==========================================================

# Generado automáticamente el 2025-07-31 16:26:42
AUTO_AVANZAR_TAREA_MENU = true

TAREAS_CONFIG = [
  {
    id: :xen01_proc_xvas,
    menu_texto: "🔧 Procesar BKPs XEN01 (archivos .xva)",
    tipo_proceso: :xva,
    origen: "/mnt/ns8Disco2/syncs_XEN01/",
    destino: "/mnt/ns8Disco3/dtic_BACKUPS/bkps_XEN01/",
    eliminar_origen: true,
    sobrescribir_destino: false,
  },
  {
    id: :pmox1_sinc_ns8,
    menu_texto: "🔄 Sincronizar BKPs desde PMOX1 → NS8",
    tipo_proceso: :rclone_sync,
    origen: "pve_PMOX1:/var/lib/vz/dump/",
    destino: "/mnt/ns8Disco2/syncs_PMOX1/",
    eliminar_origen: false,
    sobrescribir_destino: false,
  },
  {
    id: :pmox2_sinc_ns8,
    menu_texto: "🔄 Sincronizar BKPs desde PMOX2 → NS8",
    tipo_proceso: :rclone_sync,
    origen: "pve_PMOX2:/var/lib/vz/dump/",
    destino: "/mnt/ns8Disco2/syncs_PMOX2/",
    eliminar_origen: false,
    sobrescribir_destino: false,
  },
  {
    id: :pmox3_sinc1_ns8,
    menu_texto: "🔄 Sincronizar BKPs desde PMOX3 → NS8",
    tipo_proceso: :rclone_sync,
    origen: "pve_PMOX3:/var/lib/vz/dump/",
    destino: "/mnt/ns8Disco2/syncs_PMOX3/",
    eliminar_origen: false,
    sobrescribir_destino: false,
  },
  {
    id: :pmox3_sinc2_ns8,
    menu_texto: "🔄 Sincronizar BKPs desde PMOX3 zfsDISCO1 → NS8",
    tipo_proceso: :rclone_sync,
    origen: "pve_PMOX3:/zfsDISCO1/backups/dump",
    destino: "/mnt/ns8Disco2/syncs_PMOX3/",
    eliminar_origen: false,
    sobrescribir_destino: false,
  },
  {
    id: :ns8_proc_bkps_pmox1,
    menu_texto: "🗂  Procesar BKPs PMOX1 (archivos .log / .notes)",
    tipo_proceso: :proxmox_log_notes,
    origen: "/mnt/ns8Disco2/syncs_PMOX1/",
    destino: "/mnt/ns8Disco3/dtic_BACKUPS/bkps_PMOX1/",
    eliminar_origen: true,
    sobrescribir_destino: false,
  },
  {
    id: :ns8_proc_bkps_pmox2,
    menu_texto: "🗂  Procesar BKPs PMOX2 (archivos .log / .notes)",
    tipo_proceso: :proxmox_log_notes,
    origen: "/mnt/ns8Disco2/syncs_PMOX2/",
    destino: "/mnt/ns8Disco3/dtic_BACKUPS/bkps_PMOX2/",
    eliminar_origen: true,
    sobrescribir_destino: false,
  },
  {
    id: :ns8_proc_bkps_pmox3,
    menu_texto: "🗂  Procesar BKPs PMOX3 (archivos .log / .notes)",
    tipo_proceso: :proxmox_log_notes,
    origen: "/mnt/ns8Disco2/syncs_PMOX3/",
    destino: "/mnt/ns8Disco3/dtic_BACKUPS/bkps_PMOX3/",
    eliminar_origen: true,
    sobrescribir_destino: false,
  },
  {
    id: :ns8_sinc_nube,
    menu_texto: "☁️  Sincronizar BKPs desde NS8 → rmOneDrive (Backup en la nube)",
    tipo_proceso: :rclone_sync,
    origen: "/mnt/ns8Disco3/dtic_BACKUPS/",
    destino: "rmOneDrive:/dtic_BACKUPS/",
    eliminar_origen: false,
    sobrescribir_destino: false,
  },
]