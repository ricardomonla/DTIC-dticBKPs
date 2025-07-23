# Archivo: core/globals.rb

# --- REQUIRES GLOBALES ---
require 'fileutils'
require 'open3'
require 'time'
require 'io/console'
require 'shellwords'

# Carga de la clase del Logger desde el directorio raíz
require_relative '../dticBKPs_log.rb'

# --- CONSTANTES GLOBALES DEL SCRIPT ---
APP_NOM_BASE = 'dticBKPs'
APP_NOM = "#{APP_NOM_BASE}_app.rb"
APP_VER = 'v4.4.1' # Versión actualizada
APP_AUTOR = "Ricardo MONLA (rmonla@)"

# La ruta del script ahora se calcula desde este archivo para ser consistente
APP_DIR_SCRIPT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
APP_CFG_NOM_ARCHIVO = "#{APP_NOM_BASE}_conf.rb"
APP_LOG_NOM_ARCHIVO = "#{APP_NOM_BASE}.log"
APP_CFG_RUTA_ARCHIVO = File.join(APP_DIR_SCRIPT, APP_CFG_NOM_ARCHIVO)
APP_LOG_RUTA_ARCHIVO = File.join(APP_DIR_SCRIPT, APP_LOG_NOM_ARCHIVO)

# --- COLORES E ICONOS GLOBALES ---
RESET = "\e[0m"; NEGRITA = "\e[1m"; SUBRAYADO="\e[4m"; INTERMITENTE = "\e[5m"
CIAN = "\e[96m"; AMARILLO = "\e[93m"; ROJO = "\e[91m"; VERDE = "\e[92m"
ICONO_OK = "#{VERDE}✔#{RESET}"; ICONO_ERROR = "#{ROJO}✖#{RESET}"; ICONO_WARN = "#{AMARILLO}⚠#{RESET}"; ICONO_INFO = "#{CIAN}ℹ#{RESET}"

# --- CONFIGURACIÓN GLOBAL ---
$logger = DticBKPsLogger.setup_logger(APP_LOG_RUTA_ARCHIVO)
$estadisticas_ejecucion = { tareas_completadas: {} }

# --- FUNCIÓN DE LOGGING GLOBAL ---
def log(nivel, mensaje)
  msg_l = mensaje.gsub(/\e\[\d+(;\d+)*m/, '')
  case nivel
  when :info then $logger.info(msg_l)
  when :error then $logger.error(msg_l)
  when :warn then $logger.warn(msg_l)
  else $logger.debug(msg_l)
  end
end