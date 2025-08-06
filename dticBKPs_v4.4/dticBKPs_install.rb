#!/usr/bin/ruby
# frozen_string_literal: true

# ==========================================================
#  dticBKPs - Automatic Backup Processor
#  ----------------------------------------------------------
#  APP:         dticBKPs
#  FILE:        dticBKPs_install.rb
#  VERSION:     v4.4.2
#  AUTHOR:      Ricardo MONLA (rmonla@)
#  LICENSE:     MIT License
# ==========================================================

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
  deps = %w[ruby pv tar gzip rclone]
  faltantes = []

  deps.each do |dep|
    if comando_existe?(dep)
      puts "#{ICONO_OK} Dependencia encontrada: #{dep}"
    else
      puts "#{ICONO_ERROR} Dependencia faltante: #{dep}"
      faltantes << dep
    end
  end

  return true if faltantes.empty?

  puts "\n#{ICONO_WARN} Faltan las siguientes dependencias: #{NEGRITA}#{faltantes.join(', ')}#{RESET}."
  print "#{AMARILLO}¿Deseas intentar instalar las dependencias faltantes ahora? (S/N): #{RESET}"
  respuesta = $stdin.gets.chomp.downcase

  if respuesta == 's'
    puts "\n#{ICONO_INFO} Se necesita contraseña de administrador (sudo) para instalar paquetes."
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
  contenido_defecto = <<~CFG
    # Archivo de Configuración para dticBKPs
    # Generado automáticamente el #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}
    AUTO_AVANZAR_TAREA_MENU = true
    TAREAS_CONFIG = [
      # Agrega aquí tus tareas...
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
    exec("./#{APP_EJECUTABLE}")
  else
    puts "\n#{ICONO_INFO} Entendido. Puedes ejecutar la aplicación en cualquier momento con: #{CIAN}./#{APP_EJECUTABLE}#{RESET}"
  end
else
  puts "\n#{NEGRITA}#{ROJO}La instalación no pudo completarse.#{RESET}"
  puts "Por favor, soluciona los problemas de dependencias y vuelve a ejecutar este script."
  exit 1
end