Title: Despliegue de un cluster de Kubernetes
Date: 2018/03/05
Category: Cloud Computing
Header_Cover: theme/images/banner-kubernetes.jpg
Tags: Kubernetes

En este artículo vamos a desplegar un **cluster de Kubernetes (k8s)** y para ello he decidido utilizar la distribución **k3s**.

Todo el proceso se llevará a cabo en un escenario *Vagrant* que las siguientes máquinas:

- **controlador:** máquina que controlará el *cluster*. Se encuentra conectada a mi red doméstica en modo puente.
- **worker1:** máquina que actuará como *worker*. Se encuentra conectada a mi red doméstica en modo puente.
- **worker2:** máquina que actuará como *worker*. Se encuentra conectada a mi red doméstica en modo puente.

Puedes ver el fichero *Vagrantfile* desde [aquí](images/hlc_despliegue_de_un_cluster_de_kubernetes/Vagrantfile.txt).


## ¿Qué es k3s?

**k3s** es una distribución de *Kubernetes*, desarrollada por Rancher Labs, muy ligera y muy fácil de instalar, que requiere pocos requisitos y un uso de memoria mínimo.

Para el planteamiento de un entorno de desarrollo, esto se convierte en una gran mejora sobre lo que hemos hablado anteriormente en *Kubernetes*; crear un entorno mínimo para desarrollo, donde la creación del entorno es compleja y requiere de muchos recursos, aunque sea *Ansible* el que realice el trabajo difícil.

Entre las herramientas que nos proporciona se incluye **kubectl**.
Esta herramienta, es una interfaz de línea de comandos desarrollada en *Go* para gestionar nuestros *clusters* de manera centralizada.

A continuación podemos ver un diagrama acerca de la estructura interna de *k3s*:

![.](images/hlc_despliegue_de_un_cluster_de_kubernetes/estructurainterna.png)

## Instalación de k3s















































.
