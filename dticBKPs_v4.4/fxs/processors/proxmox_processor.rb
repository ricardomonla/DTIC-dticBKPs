# frozen_string_literal: true

# ==========================================================
#  dticBKPs - Automatic Backup Processor
#  ----------------------------------------------------------
#  APP:         dticBKPs
#  FILE:        fxs/processors/proxmox_processor.rb
#  VERSION:     v4.4.2
#  AUTHOR:      Ricardo MONLA (rmonla@)
#  LICENSE:     MIT License
# ==========================================================

# Carga las constantes, logger y helpers globales
require_relative '../../core/globals'

# --- Función Principal del Procesador Proxmox ---
def procesar_backups_tipo_proxmox(tarea_cfg)
  # 1. --- Extraer configuración y inicializar variables ---
  dir_origen = tarea_cfg[:origen]
  dir_destino_base = tarea_cfg[:destino]
  eliminar_original = tarea_cfg[:eliminar_origen]
  sobrescribir_destino = tarea_cfg[:sobrescribir_destino]
  backups_procesados_llamada = 0

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

  # 2. --- Buscar archivos .log para identificar los sets de backup ---
  archivos_log = Dir.glob(File.join(dir_origen, '*.log'))

  if archivos_log.empty?
    msg = "No se encontraron archivos .log en '#{dir_origen}' para la tarea #{tarea_cfg[:id]}."
    log :warn, msg; puts "#{ICONO_WARN} #{msg}"
    $estadisticas_ejecucion[:tareas_completadas][tarea_cfg[:id]] = { archivos: 0, estado: "OK (Sin archivos)" }
    return
  end

  puts "#{ICONO_INFO} Encontrados #{archivos_log.length} set(s) de backup Proxmox a procesar."

  # 3. --- Iterar y procesar cada set de backup ---
  archivos_log.each do |ruta_log|
    nombre_base_log = File.basename(ruta_log, '.log')
    
    begin
      archivos_fuente_del_backup = Dir.glob(File.join(dir_origen, "#{nombre_base_log}*"))
      
      ruta_notes = archivos_fuente_del_backup.find { |f| f.end_with?('.notes') }
      unless ruta_notes
        log :warn, "No se encontró el archivo .notes para el set '#{nombre_base_log}'. Saltando."
        next
      end
      
      nombre_vm = File.read(ruta_notes).strip
      if nombre_vm.empty?
        log :warn, "El archivo .notes para '#{nombre_base_log}' está vacío. Saltando."
        next
      end

      nombre_final_tar = "#{nombre_vm}_#{File.mtime(ruta_log).strftime('%Y%m%d_%H%M%S')}.tar.gz"
      dir_destino_vm = File.join(dir_destino_base, nombre_vm)
      FileUtils.mkdir_p(dir_destino_vm)
      ruta_salida_tar = File.join(dir_destino_vm, nombre_final_tar)

      if File.exist?(ruta_salida_tar)
        if sobrescribir_destino
          msg = "Destino '#{File.basename(ruta_salida_tar)}' existe. Se sobrescribirá."
          log :info, msg; puts "#{ICONO_WARN} #{msg}"
        else
          msg = "Destino '#{File.basename(ruta_salida_tar)}' existe. No se sobrescribe. Saltando."
          log :warn, msg; puts "#{ICONO_WARN} #{msg}"
          next
        end
      end

      # 4. --- Realizar la compresión ---
      puts "#{CIAN}→ Comprimiendo set #{NEGRITA}#{nombre_base_log}#{RESET} (VM: #{nombre_vm}) a #{File.basename(ruta_salida_tar)}..."
      log :info, "Comprimiendo Proxmox set para '#{nombre_vm}' (base: #{nombre_base_log})"
      
      nombres_para_tar = archivos_fuente_del_backup.map { |f| File.basename(f) }

      if @pv_disponible
        cmd_tar = ['tar', '-cf', '-', '-C', dir_origen] + nombres_para_tar
        cmd_pv = ['pv', '-s', archivos_fuente_del_backup.sum { |f| File.size(f) rescue 0 }.to_s]
        cmd_gzip = ['gzip']
        
        File.open(ruta_salida_tar, 'wb') do |f_out|
          Open3.pipeline(cmd_tar, cmd_pv, cmd_gzip, out: f_out).each_with_index do |status, i|
            unless status.success?
              cmd_name = ['tar', 'pv', 'gzip'][i]
              raise "Error en compresión (falló #{cmd_name} con código: #{status.exitstatus})"
            end
          end
        end
      else
        archivos_escapados = nombres_para_tar.map { |f| Shellwords.escape(f) }.join(' ')
        cmd_tar_directo = "tar -czf #{Shellwords.escape(ruta_salida_tar)} -C #{Shellwords.escape(dir_origen)} #{archivos_escapados}"
        system(cmd_tar_directo)
        raise "Error en compresión (falló tar con código: #{$?.exitstatus})" unless $?.success?
      end

      # 5. --- Finalizar y limpiar ---
      log :info, "Compresión Proxmox set OK: #{ruta_salida_tar}"
      puts "\n#{ICONO_OK} Compresión OK: #{File.basename(ruta_salida_tar)}"
      
      if eliminar_original
        log :info, "Eliminando fuentes Proxmox para '#{nombre_base_log}'..."
        archivos_fuente_del_backup.each { |f| FileUtils.rm_f(f) }
      end
      
      backups_procesados_llamada += 1

    rescue StandardError => e
      err_msg = "Error procesando set '#{nombre_base_log}': #{e.message}"
      log :error, err_msg
      puts "\n#{ICONO_ERROR} #{err_msg}"
      FileUtils.rm_f(ruta_salida_tar)
      next
    end
  end

  # 6. --- Reportar estadísticas finales ---
  $estadisticas_ejecucion[:tareas_completadas][tarea_cfg[:id]] = { archivos: backups_procesados_llamada, estado: "OK" }
  log :info, "Procesados #{backups_procesados_llamada} sets Proxmox para tarea #{tarea_cfg[:id]}."
  puts "#{ICONO_OK} Tarea '#{tarea_cfg[:menu_texto]}' completada. Procesados: #{backups_procesados_llamada}."
  sleep 1.5
end