#!/bin/bash

# Verificar si VBoxManage está instalado
if ! command -v VBoxManage &> /dev/null; then
    echo "❌ VBoxManage no está instalado. Instala VirtualBox primero."
    exit 1
fi

# Función para mostrar un banner con diseño estético
function mostrar_banner() {
    clear
    echo "╔══════════════════════════════════════════╗"
    echo "║       Script de Creación de MV en        ║"
    echo "║        VirtualBox con VBoxManage         ║"
    echo "╚══════════════════════════════════════════╝"
    echo ""
    echo "Cargando el sistema..."
    for i in {1..3}; do
        echo -ne "█"
        sleep 0.5
    done
    echo -e "\n🚀 ¡Listo para comenzar!"
    sleep 1
}

# Función para solicitar la configuración de la máquina virtual
function solicitar_configuracion() {
    echo -n "🖥️  Ingresa el nombre de la máquina virtual: "
    read NOMBRE_VM
    echo -n "📂 Elige el tipo de sistema operativo (ej. Ubuntu_64, Debian_64, RedHat_64): "
    read TIPO_OS

    echo "🔢 Ingrese el número de CPUs (recomendado 4 CPUs): "
    read -p "Número de CPUs (4 recomendado): " NUM_CPUS
    NUM_CPUS=${NUM_CPUS:-4}  # Si no ingresa valor, usa 4 por defecto

    echo "🧠 Ingrese la cantidad de RAM en GB (recomendado: 4GB RAM): "
    read -p "RAM en GB (4GB recomendado): " RAM_GB
    RAM_GB=${RAM_GB:-4}  # Si no ingresa valor, usa 4GB por defecto

    echo "💻 Ingrese la cantidad de VRAM en MB (recomendado: 128MB): "
    read -p "VRAM en MB (128MB recomendado): " VRAM_MB
    VRAM_MB=${VRAM_MB:-128}  # Si no ingresa valor, usa 128MB por defecto

    echo "💾 Ingrese el tamaño del disco duro en GB (recomendado: 20GB): "
    read -p "Tamaño del disco en GB (20GB recomendado): " TAM_DISCO_GB
    TAM_DISCO_GB=${TAM_DISCO_GB:-20}  # Si no ingresa valor, usa 20GB por defecto

    echo -n "📦 Ingrese el nombre del controlador SATA (Ej. SATAController): "
    read CONTROLADOR_SATA
    echo -n "📀 Ingrese el nombre del controlador IDE (Ej. IDEController): "
    read CONTROLADOR_IDE
}

# Función para animar el progreso de una acción
function animacion_progreso() {
    echo -n "$1"
    for i in {1..3}; do
        echo -n "."
        sleep 0.5
    done
    echo ""
}

# Función para crear y configurar la máquina virtual
function crear_maquina_virtual() {
    animacion_progreso "➡️  Creando máquina virtual '$NOMBRE_VM'"
    VBoxManage createvm --name "$NOMBRE_VM" --ostype "$TIPO_OS" --register

    animacion_progreso "🛠️  Configurando CPU ($NUM_CPUS), RAM (${RAM_GB}GB) y VRAM (${VRAM_MB}MB)"
    VBoxManage modifyvm "$NOMBRE_VM" --cpus "$NUM_CPUS" --memory $(($RAM_GB * 1024)) --vram "$VRAM_MB"

    DISCO_VIRTUAL="${NOMBRE_VM}_disk.vdi"
    animacion_progreso "💾 Creando disco duro virtual de $TAM_DISCO_GB GB en '$DISCO_VIRTUAL'"
    VBoxManage createmedium disk --filename "$DISCO_VIRTUAL" --size $(($TAM_DISCO_GB * 1024)) --format VDI

    animacion_progreso "🔗 Creando controlador SATA '$CONTROLADOR_SATA' y asociando el disco"
    VBoxManage storagectl "$NOMBRE_VM" --name "$CONTROLADOR_SATA" --add sata --controller IntelAhci
    VBoxManage storageattach "$NOMBRE_VM" --storagectl "$CONTROLADOR_SATA" --port 0 --device 0 --type hdd --medium "$DISCO_VIRTUAL"

    animacion_progreso "🔗 Creando controlador IDE '$CONTROLADOR_IDE'"
    VBoxManage storagectl "$NOMBRE_VM" --name "$CONTROLADOR_IDE" --add ide
    VBoxManage storageattach "$NOMBRE_VM" --storagectl "$CONTROLADOR_IDE" --port 1 --device 0 --type dvddrive --medium emptydrive

    echo "✅ Máquina virtual '$NOMBRE_VM' creada y configurada con éxito."
    VBoxManage showvminfo "$NOMBRE_VM"
}

# Función principal del script
function main() {
    mostrar_banner
    solicitar_configuracion
    crear_maquina_virtual
}

# Ejecutar el script
main
