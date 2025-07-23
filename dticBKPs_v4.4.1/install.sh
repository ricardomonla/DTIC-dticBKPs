#!/bin/bash
# Este script ahora también es compatible con /bin/sh (dash)

# --- Colores para la salida ---
CIAN='\033[0;96m'
AMARILLO='\033[0;93m'
VERDE='\033[0;92m'
ROJO='\033[0;91m'
NEGRITA='\033[1m'
NC='\033[0m' # Sin color

# --- Iconos ---
ICONO_OK="${VERDE}✔${NC}"
ICONO_ERROR="${ROJO}✖${NC}"
ICONO_INFO="${CIAN}ℹ${NC}"
ICONO_WARN="${AMARILLO}⚠${NC}"

echo -e "${NEGRITA}${CIAN}--- Instalador de dticBKPs ---${NC}"

# 1. VERIFICAR SI RUBY ESTÁ INSTALADO
echo -e "\n${ICONO_INFO} Verificando si Ruby está instalado..."

if command -v ruby > /dev/null 2>&1
then
    # Ruby ya está instalado
    RUBY_VERSION=$(ruby -v)
    echo -e "${ICONO_OK} Ruby ya está instalado: ${AMARILLO}${RUBY_VERSION}${NC}"
else
    # Ruby no está instalado
    echo -e "${ICONO_WARN} Ruby no se encuentra en el sistema."
    
    # Manera compatible con 'sh' para pedir entrada
    echo -n -e "${AMARILLO}¿Deseas instalar Ruby (a través de 'sudo apt install ruby-full')? (S/N): ${NC}"
    read respuesta

    # Usamos 'case' en lugar de 'if [[ ... =~ ... ]]' para máxima compatibilidad
    case "$respuesta" in
        [Ss] | [Ss][Ii]) # Acepta S, s, Si, si
            echo -e "\n${ICONO_INFO} Se necesita contraseña de administrador para instalar paquetes."
            echo -e "${ICONO_INFO} Actualizando lista de paquetes (sudo apt-get update)..."
            sudo apt-get update
            
            echo -e "${ICONO_INFO} Instalando ruby-full..."
            sudo apt-get install -y ruby-full
            
            if ! command -v ruby > /dev/null 2>&1
            then
                echo -e "\n${ICONO_ERROR} La instalación de Ruby falló. Por favor, instálalo manualmente y vuelve a ejecutar este script."
                exit 1
            fi
            echo -e "\n${ICONO_OK} Ruby instalado correctamente."
            ;;
        *)
            echo -e "\n${ICONO_ERROR} Instalación cancelada. Ruby es necesario para continuar."
            exit 1
            ;;
    esac
fi

# 2. EJECUTAR EL SCRIPT DE INSTALACIÓN DE RUBY
echo -e "\n${ICONO_INFO} Lanzando el instalador de la aplicación (dticBKPs_install.rb)..."
echo -e "${CIAN}--------------------------------------------------${NC}"

ruby ./dticBKPs_install.rb

exit 0