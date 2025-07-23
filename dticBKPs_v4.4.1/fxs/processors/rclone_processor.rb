# Archivo: fxs/processors/rclone_processor.rb

# Carga las constantes y helpers globales
require_relative '../../core/globals'

def sincronizar_rclone(tarea_cfg)
  origen = tarea_cfg[:origen]
  destino = tarea_cfg[:destino]
  puts "\n#{NEGRITA}#{CIAN}--- #{tarea_cfg[:menu_texto]} ---#{RESET}"
  log :info, "Iniciando rclone sync #{tarea_cfg[:id]}. Origen: #{origen}, Destino: #{destino}"

  comando_rclone = "rclone sync #{Shellwords.escape(origen)} #{Shellwords.escape(destino)} --progress -v"
  log :info, "Ejecutando: #{comando_rclone}"
  puts "#{CIAN}Ejecutando rclone sync... (Origen: #{origen} -> Destino: #{destino})#{RESET}"

  exito = system(comando_rclone)
  codigo_salida = $?.exitstatus
  estado_final = exito ? "Éxito" : "Fallo (cód: #{codigo_salida})"
  $estadisticas_ejecucion[:tareas_completadas][tarea_cfg[:id]] = { estado: estado_final }

  if exito
    log :info, "Sincronización rclone OK para #{tarea_cfg[:id]}."
    puts "#{ICONO_OK} Sincronización rclone OK."
  else
    log :error, "Fallo sincronización rclone para #{tarea_cfg[:id]} (#{estado_final})."
    puts "#{ICONO_ERROR} Fallo sincronización rclone (#{estado_final})."
  end
  sleep 1.5
  return exito
end