# Usar la imagen base de Kali Linux
FROM kalilinux/kali-rolling

# Establecer el entorno para que no se solicite confirmación durante la instalación de paquetes
ENV DEBIAN_FRONTEND=noninteractive

# Actualizar e instalar herramientas básicas y el conjunto completo de Kali Linux
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get dist-upgrade -y && \
    apt-get install -y kali-linux-large iputils-ping net-tools curl && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configurar el entorno de trabajo
WORKDIR /root

# Definir el comando por defecto al iniciar el contenedor
CMD ["/bin/bash"]
