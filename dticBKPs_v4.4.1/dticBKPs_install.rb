#!/usr/bin/ruby
# frozen_string_literal: true

# NOMBRE DE APP ** dticBKPs_install.rb **
# Ricardo MONLA (rmonla@)
# Script de Instalación y Verificación para dticBKPs (Debian/Ubuntu)

require 'fileutils'

# --- Constantes ---
APP_NOM_BASE = 'dticBKPs'
APP_EJECUTABLE = "#{APP_NOM_BASE}_app.rb"
APP_CFG_NOM_ARCHIVO = "#{APP_NOM_BASE}_conf.rb"
APP_DIR_SCRIPT = File.expand_path(File.dirname($0))
APP_CFG_RUTA_ARCHIVO = File.join(APP_DIR_SCRIPT, APP_CFG_NOM_ARCHIVO)

# --- Colores y Iconos ---
RESET = "\e[0m"; NEGRITA = "\e[1m"
CIAN = "\e[96m"; VERDE = "\e[92m"; ROJO = "\e[91m"; AMARILLO = "\e[93m"
ICONO_OK = "#{VERDE}✔#{RESET}"
ICONO_ERROR = "#{ROJO}✖#{RESET}"
ICONO_WARN = "#{AMARILLO}⚠#{RESET}"
ICONO_INFO = "#{CIAN}ℹ#{RESET}"

def comando_existe?(cmd)
  ENV['PATH'].split(File::PATH_SEPARATOR).any? { |d| File.executable?(File.join(d, cmd)) }
end

def verificar_dependencias
  puts "#{NEGRITA}#{CIAN}--- Verificando Dependencias ---#{RESET}"
  # Nota: 'ruby-full' puede ser necesario para algunas gemas, pero 'ruby' suele ser suficiente.
  # awk, du y tar son parte de coreutils, pero los verificamos por si acaso.
  deps = %w[ruby pv tar gzip rclone du awk]
  faltantes = []

  deps.each do |dep|
    if comando_existe?(dep)
      puts "#{ICONO_OK} Dependencia encontrada: #{dep}"
    else
      puts "#{ICONO_ERROR} Dependencia faltante: #{dep}"
      faltantes << dep
    end
  end

  # Si no falta nada, retornamos éxito.
  return true if faltantes.empty?

  # Si faltan dependencias, preguntamos al usuario si desea instalarlas.
  puts "\n#{ICONO_WARN} Faltan las siguientes dependencias: #{NEGRITA}#{faltantes.join(', ')}#{RESET}."
  print "#{AMARILLO}¿Deseas intentar instalar las dependencias faltantes ahora? (S/N): #{RESET}"
  respuesta = $stdin.gets.chomp.downcase

  if respuesta == 's'
    puts "\n#{ICONO_INFO} Se necesita contraseña de administrador (sudo) para instalar paquetes."
    # Actualizamos la lista de paquetes primero para evitar errores.
    puts "#{ICONO_INFO} Ejecutando: #{NEGRITA}sudo apt-get update#{RESET}..."
    system("sudo apt-get update")
    
    comando_instalacion = "sudo apt-get install -y #{faltantes.join(' ')}"
    puts "#{ICONO_INFO} Ejecutando: #{NEGRITA}#{comando_instalacion}#{RESET}..."
    system(comando_instalacion)

    if $?.success?
      puts "\n#{ICONO_OK} Dependencias instaladas correctamente."
      return true
    else
      puts "\n#{ICONO_ERROR} La instalación de dependencias falló. Por favor, intenta instalarlas manualmente."
      return false
    end
  else
    puts "\n#{ICONO_INFO} Instalación cancelada. Por favor, instala las dependencias manualmente."
    return false
  end
end

def generar_archivo_cfg_defecto(ruta_cfg)
  puts "\n#{NEGRITA}#{CIAN}--- Generando Archivo de Configuración ---#{RESET}"
  if File.exist?(ruta_cfg)
    puts "#{ICONO_INFO} El archivo de configuración '#{File.basename(ruta_cfg)}' ya existe. No se realizarán cambios."
    return true
  end

  puts "#{ICONO_WARN} Archivo de configuración no encontrado. Se creará uno por defecto."
  # (El contenido del archivo de configuración por defecto se mantiene igual)
  contenido_defecto = <<~CFG
    # Archivo de Configuración para dticBKPs
    # Modifica estas tareas o añade nuevas editando este archivo
    # o usando la opción 'E' en el menú de la aplicación.

    AUTO_AVANZAR_TAREA_MENU = true

    TAREAS_CONFIG = [
      {
        id: :xen01_procesar_xva,
        menu_texto: "Procesar backups Xen01 (.xva)",
        tipo_proceso: :xva,
        origen: "/media/NS8_Disco2/syncs_XEN01/",
        destino: "/media/rmonla/NS8_Disco3/dtic_BACKUPS/bkps_XEN01/",
        eliminar_origen: true,
        sobrescribir_destino: false,
      },
      {
        id: :pmox1_sincronizar,
        menu_texto: "Sincronizar backups PMOX1 (Remoto -> Local)",
        tipo_proceso: :rclone_sync,
        origen: "pve_PMOX1:/var/lib/vz/dump/",
        destino: "/media/NS8_Disco2/syncs_PMOX1/",
        eliminar_origen: false,
        sobrescribir_destino: false,
      },
      {
        id: :pmox1_procesar,
        menu_texto: "Procesar backups PMOX1 (.log/.notes)",
        tipo_proceso: :proxmox_log_notes,
        origen: "/media/NS8_Disco2/syncs_PMOX1/",
        destino: "/media/rmonla/NS8_Disco3/dtic_BACKUPS/bkps_PMOX1/",
        eliminar_origen: true,
        sobrescribir_destino: false
      },
      {
        id: :nube_sincronizar,
        menu_texto: "Sincronizar backups procesados -> Nube (Local -> Remoto)",
        tipo_proceso: :rclone_sync,
        origen: "/media/rmonla/NS8_Disco3/dtic_BACKUPS/",
        destino: "rmOneDrive:/dtic_BACKUPS/",
        eliminar_origen: false,
        sobrescribir_destino: false,
      },
      {
        id: :servidor_a_servidor_sync,
        menu_texto: "Sincronizar PMOX2 -> PMOX1 (Remoto -> Remoto)",
        tipo_proceso: :rclone_sync,
        origen: "pve_PMOX2:/var/lib/vz/dump/",
        destino: "pve_PMOX1:/var/lib/vz/dump/",
        eliminar_origen: false,
        sobrescribir_destino: false,
      }
    ]
  CFG
  begin
    File.write(ruta_cfg, contenido_defecto)
    puts "#{ICONO_OK} Archivo de configuración '#{File.basename(ruta_cfg)}' generado con éxito."
    puts "#{ICONO_INFO} Revisa el archivo para ajustar las rutas a tu entorno."
    true
  rescue StandardError => e
    puts "#{ICONO_ERROR} Error generando el archivo de configuración '#{ruta_cfg}': #{e.message}"
    false
  end
end

# --- Ejecución del Instalador ---
if verificar_dependencias
  generar_archivo_cfg_defecto(APP_CFG_RUTA_ARCHIVO)
  
  puts "\n#{ICONO_INFO} Asegurando permisos de ejecución para '#{APP_EJECUTABLE}'..."
  system("chmod +x #{APP_EJECUTABLE}")

  puts "\n#{NEGRITA}#{VERDE}¡Instalación completa y lista para usar!#{RESET}"
  
  print "#{AMARILLO}¿Deseas iniciar la aplicación ahora? (S/N): #{RESET}"
  respuesta_lanzar = $stdin.gets.chomp.downcase
  
  if respuesta_lanzar == 's'
    puts "\n#{ICONO_INFO} Lanzando la aplicación..."
    # 'exec' reemplaza el proceso actual del instalador con el de la aplicación.
    # Es la forma más limpia de "pasar el control".
    exec("./#{APP_EJECUTABLE}")
  else
    puts "\n#{ICONO_INFO} Entendido. Puedes ejecutar la aplicación en cualquier momento con: #{CIAN}./#{APP_EJECUTABLE}#{RESET}"
  end
else
  puts "\n#{NEGRITA}#{ROJO}La instalación no pudo completarse.#{RESET}"
  puts "Por favor, soluciona los problemas de dependencias y vuelve a ejecutar este script."
  exit 1
end