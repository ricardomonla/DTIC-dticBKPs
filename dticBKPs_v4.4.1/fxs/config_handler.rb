def cargar_configuracion
  unless File.exist?(APP_CFG_RUTA_ARCHIVO)
    puts "#{ICONO_ERROR} Archivo de configuración no encontrado: #{APP_CFG_RUTA_ARCHIVO}"
    puts "#{ICONO_INFO} Ejecute primero el script de instalación: #{CIAN}./#{APP_NOM_BASE}_install.rb#{RESET}"
    exit 1
  end

  begin
    load APP_CFG_RUTA_ARCHIVO
    unless defined?(TAREAS_CONFIG) && TAREAS_CONFIG.is_a?(Array)
      puts "#{ICONO_ERROR} TAREAS_CONFIG no está definida correctamente."
      exit 1
    end
    auto_avanzar = defined?(AUTO_AVANZAR_TAREA_MENU) ? AUTO_AVANZAR_TAREA_MENU : true
    return TAREAS_CONFIG, auto_avanzar
  rescue LoadError, SyntaxError => e
    puts "#{ICONO_ERROR} Error cargando config '#{APP_CFG_RUTA_ARCHIVO}':\n#{e.message}"
    exit 1
  end
end

def guardar_configuracion(tareas, auto_avanzar)
  begin
    File.open(APP_CFG_RUTA_ARCHIVO, 'w') do |f|
      f.puts "# Archivo de Configuración para #{APP_NOM_BASE}"
      f.puts "# Generado automáticamente el #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}\n"
      f.puts "AUTO_AVANZAR_TAREA_MENU = #{auto_avanzar}\n"
      f.puts "TAREAS_CONFIG = ["
      tareas.each do |tarea|
        f.puts "  {"
        tarea.each { |key, value| f.puts "    #{key}: #{value.inspect}," }
        f.puts "  },"
      end
      f.puts "]"
    end
    puts "\n#{ICONO_OK} Configuración guardada en '#{APP_CFG_NOM_ARCHIVO}'."
    log :info, "Configuración actualizada y guardada por el usuario."
    sleep 1.5
    return true
  rescue StandardError => e
    puts "\n#{ICONO_ERROR} No se pudo guardar la configuración: #{e.message}"
    log :error, "Fallo al guardar configuración: #{e.message}"
    sleep 2
    return false
  end
end