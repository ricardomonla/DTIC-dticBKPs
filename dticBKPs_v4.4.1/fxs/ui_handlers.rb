# Archivo: fxs/ui_handlers.rb

# Carga las constantes y helpers globales
require_relative '../core/globals'

def leer_entrada_simple(prompt)
  print prompt; $stdout.flush; $stdin.gets.chomp
end

def mostrar_encabezado_app
  puts "#{NEGRITA}#{CIAN}--- dticBKPs - Procesador de Backups #{APP_VER} ---#{RESET}"
end

def editar_tarea(tarea)
  system 'clear' or system 'cls'
  puts "#{NEGRITA}#{CIAN}--- Editando Tarea: #{tarea[:id]} ---#{RESET}"
  puts "Deja el campo en blanco para mantener el valor actual."

  tarea.each do |key, value|
    tipo = value.is_a?(TrueClass) || value.is_a?(FalseClass) ? "(true/false)" : ""
    nuevo_valor = leer_entrada_simple("#{AMARILLO}#{key}#{RESET} #{tipo} [Actual: #{value.inspect}] > ").strip

    unless nuevo_valor.empty?
      if value.is_a?(Symbol)
        tarea[key] = nuevo_valor.to_sym
      elsif tipo == "(true/false)"
        tarea[key] = nuevo_valor.downcase == 'true'
      else
        tarea[key] = nuevo_valor
      end
    end
  end
  puts "#{ICONO_OK} Tarea actualizada."
  sleep 1
end

def modificar_tareas_menu(tareas_actuales, auto_avanzar_actual)
  loop do
    system 'clear' or system 'cls'
    puts "#{NEGRITA}#{CIAN}--- Editor de Tareas ---#{RESET}"
    tareas_actuales.each_with_index do |tarea, index|
      puts "#{AMARILLO}#{index + 1}.#{RESET} #{tarea[:menu_texto]} (#{AMARILLO}id: :#{tarea[:id]}#{RESET})"
    end
    puts "#{CIAN}-------------------------#{RESET}"
    prompt = "[Num]=Editar, [N]=Nueva, [B]=Borrar, [G]=Guardar y Volver > "
    opcion = leer_entrada_simple(prompt).downcase

    case opcion
    when /^\d+$/
      index = opcion.to_i - 1
      editar_tarea(tareas_actuales[index]) if tareas_actuales[index]
    when 'n'
      nueva_tarea = { id: :nueva_tarea, menu_texto: "Nueva Tarea", tipo_proceso: :rclone_sync, origen: "", destino: "", eliminar_origen: false, sobrescribir_destino: false }
      editar_tarea(nueva_tarea)
      tareas_actuales << nueva_tarea
    when 'b'
      index_b = leer_entrada_simple("Número de tarea a borrar > ").to_i - 1
      if tareas_actuales[index_b]
        puts "#{ICONO_WARN} Borrando '#{tareas_actuales[index_b][:menu_texto]}'."
        tareas_actuales.delete_at(index_b)
        sleep 1
      end
    when 'g'
      guardar_configuracion(tareas_actuales, auto_avanzar_actual)
      return
    else
      puts "#{ICONO_ERROR} Opción no válida."
      sleep 1
    end
  end
end