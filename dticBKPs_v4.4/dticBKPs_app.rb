#!/usr/bin/ruby
# frozen_string_literal: true

# ==========================================================
#  dticBKPs - Automatic Backup Processor
#  ----------------------------------------------------------
#  APP:         dticBKPs
#  FILE:        dticBKPs_app.rb
#  VERSION:     v4.4.2
#  AUTHOR:      Ricardo MONLA (rmonla@)
#  LICENSE:     MIT License
# ==========================================================

# 1. Cargar las constantes globales, el logger y los requires.
#    Este es el primer y más importante require.
require_relative 'core/globals'

# 2. Cargar todas las bibliotecas de funciones.
require_relative 'fxs/config_handler'
require_relative 'fxs/ui_handlers'
require_relative 'fxs/processors/xva_processor'
require_relative 'fxs/processors/rclone_processor'
require_relative 'fxs/processors/proxmox_processor'

# --- Bucle Principal de la Aplicación ---
def bucle_principal
  tareas_config, auto_avanzar = cargar_configuracion

  loop do
    opciones_menu = tareas_config.map.with_index do |tarea_cfg, index|
      { id: index + 1, texto: tarea_cfg[:menu_texto], config: tarea_cfg,
        accion: case tarea_cfg[:tipo_proceso]
                when :xva then -> { procesar_backups_xva(tarea_cfg) }
                when :rclone_sync then -> { sincronizar_rclone(tarea_cfg) }
                when :proxmox_log_notes then -> { procesar_backups_tipo_proxmox(tarea_cfg) }
                else -> { puts "#{ICONO_ERROR} Tipo de proceso desconocido: #{tarea_cfg[:tipo_proceso]}" }
                end
      }
    end
    opciones_menu << { id: 'E', texto: "Editar tareas programadas", accion: -> { modificar_tareas_menu(tareas_config, auto_avanzar); tareas_config, auto_avanzar = cargar_configuracion } }
    opciones_menu << { id: 'S', texto: "Salir del procesador", accion: -> { puts "Saliendo..."; exit 0 } }

    system 'clear' or system 'cls'
    mostrar_encabezado_app
    puts "\n#{CIAN}--- Menú Principal ---#{RESET}"
    opciones_menu.each { |op| puts "#{AMARILLO}#{op[:id]}.#{RESET} #{op[:texto]}" }
    puts "#{CIAN}--------------------#{RESET}"

    opcion_usuario = leer_entrada_simple("Selecciona una opción > ").upcase
    opcion_encontrada = opciones_menu.find { |op| op[:id].to_s == opcion_usuario }

    if opcion_encontrada
      opcion_encontrada[:accion].call
      unless ['E', 'S'].include?(opcion_encontrada[:id].to_s)
        puts "\nPresiona Enter para continuar..."
        $stdin.gets
      end
    else
      puts "#{ICONO_ERROR} Opción no válida."
      sleep 1
    end
  end
end

# --- Inicio del Script ---
Signal.trap("INT") { puts "\n#{ROJO}Ctrl+C detectado. Saliendo...#{RESET}"; log :warn, "Script interrumpido (Ctrl+C)."; exit 130; }

log :info, "===== Inicio script #{APP_NOM} #{APP_VER} ====="
bucle_principal