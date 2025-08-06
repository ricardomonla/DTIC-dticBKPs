# frozen_string_literal: true

# ==========================================================
#  dticBKPs - Automatic Backup Processor
#  ----------------------------------------------------------
#  APP:         dticBKPs
#  FILE:        fxs/processors/xva_processor.rb
#  VERSION:     v4.4.2
#  AUTHOR:      Ricardo MONLA (rmonla@)
#  LICENSE:     MIT License
# ==========================================================

# Carga las constantes, logger y helpers globales
require_relative '../../core/globals'

# --- Función Principal del Procesador XVA ---
def procesar_backups_xva(tarea_cfg)
  # 1. --- Extraer configuración y inicializar variables ---
  dir_origen = tarea_cfg[:origen]
  dir_destino_base = tarea_cfg[:destino]
  eliminar_original = tarea_cfg[:eliminar_origen]
  sobrescribir_destino = tarea_cfg[:sobrescribir_destino]
  archivos_procesados_llamada = 0

  puts "\n#{NEGRITA}#{CIAN}--- #{tarea_cfg[:menu_texto]} ---#{RESET}"
  log :info, "Iniciando #{tarea_cfg[:id]} desde #{dir_origen}. Eliminar: #{eliminar_original}, Sobrescribir: #{sobrescribir_destino}"

  @pv_disponible ||= !`which pv`.to_s.strip.empty?
  unless @pv_disponible
    if @pv_notificado.nil?
      msg = "Comando 'pv' no encontrado. La compresión se realizará sin barra de progreso."
      log :warn, msg; puts "#{ICONO_WARN} #{msg}"
      @pv_notificado = true
    end
  end

  # 2. --- Buscar archivos a procesar ---
  archivos_disponibles = Dir.glob(File.join(dir_origen, '*.xva'))

  if archivos_disponibles.empty?
    msg = "No hay archivos .xva en '#{dir_origen}' para la tarea #{tarea_cfg[:id]}."
    log :warn, msg; puts "#{ICONO_WARN} #{msg}"
    $estadisticas_ejecucion[:tareas_completadas][tarea_cfg[:id]] = { archivos: 0, estado: "OK (Sin archivos)" }
    return
  end
  
  puts "#{ICONO_INFO} Encontrados #{archivos_disponibles.length} archivo(s) .xva a procesar."

  # 3. --- Iterar y procesar cada archivo ---
  archivos_disponibles.each do |ruta_completa_xva_origen|
    nombre_base_xva = File.basename(ruta_completa_xva_origen)
    
    nombre_vm = nombre_base_xva.split('_').first
    dir_dest_especifico_vm = File.join(dir_destino_base, nombre_vm)
    
    begin
      FileUtils.mkdir_p(dir_dest_especifico_vm)
    rescue StandardError => e
      log(:error, "Error creando dir '#{dir_dest_especifico_vm}': #{e.message}")
      next
    end
    
    nombre_sin_ext = File.basename(nombre_base_xva, '.xva')
    ruta_salida_comp = File.join(dir_dest_especifico_vm, "#{nombre_sin_ext}.tar.gz")

    if File.exist?(ruta_salida_comp)
      if sobrescribir_destino
        msg = "Destino '#{File.basename(ruta_salida_comp)}' existe. Se sobrescribirá."
        log :info, msg; puts "#{ICONO_WARN} #{msg}"
      else
        msg = "Destino '#{File.basename(ruta_salida_comp)}' existe, no se sobrescribe. Saltando."
        log :warn, msg; puts "#{ICONO_WARN} #{msg}"
        next
      end
    end
    
    # 4. --- Realizar la compresión ---
    puts "#{CIAN}→ Comprimiendo #{NEGRITA}#{nombre_base_xva}#{RESET} a #{File.basename(ruta_salida_comp)}..."
    log :info, "Comprimiendo XVA #{ruta_completa_xva_origen} a #{ruta_salida_comp}"

    begin
      if @pv_disponible
        cmd_tar = ['tar', '-czf', '-', '-C', dir_origen, nombre_base_xva]
        cmd_pv = ['pv', '-s', File.size(ruta_completa_xva_origen).to_s]
        
        File.open(ruta_salida_comp, 'wb') do |f_out|
          Open3.pipeline(cmd_tar, cmd_pv, out: f_out).each_with_index do |status, i|
            unless status.success?
              cmd_name = i == 0 ? 'tar' : 'pv'
              raise "Error en compresión (falló #{cmd_name} con código: #{status.exitstatus})"
            end
          end
        end
      else
        cmd_tar_directo = "tar -czf #{Shellwords.escape(ruta_salida_comp)} -C #{Shellwords.escape(dir_origen)} #{Shellwords.escape(nombre_base_xva)}"
        system(cmd_tar_directo)
        raise "Error en compresión (falló tar con código: #{$?.exitstatus})" unless $?.success?
      end

      # 5. --- Finalizar y limpiar ---
      log :info, "Compresión XVA OK: #{ruta_salida_comp}"
      puts "\n#{ICONO_OK} Compresión OK: #{File.basename(ruta_salida_comp)}"
      
      if eliminar_original
        log :info, "Eliminando XVA original: #{ruta_completa_xva_origen}"
        FileUtils.rm_f(ruta_completa_xva_origen)
      end
      
      archivos_procesados_llamada += 1

    rescue StandardError => e
      err_msg = "Error al comprimir #{nombre_base_xva}: #{e.message}"
      log :error, err_msg; puts "\n#{ICONO_ERROR} #{err_msg}"
      FileUtils.rm_f(ruta_salida_comp)
      next
    end
  end

  # 6. --- Reportar estadísticas finales ---
  $estadisticas_ejecucion[:tareas_completadas][tarea_cfg[:id]] = { archivos: archivos_procesados_llamada, estado: "OK" }
  log :info, "Procesados #{archivos_procesados_llamada} .xva para tarea #{tarea_cfg[:id]}."
  puts "#{ICONO_OK} Tarea '#{tarea_cfg[:menu_texto]}' completada. Procesados: #{archivos_procesados_llamada}."
  sleep 1.5
end