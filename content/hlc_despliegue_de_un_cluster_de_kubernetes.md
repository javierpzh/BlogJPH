Title: Despliegue de un cluster de Kubernetes
Date: 2018/03/05
Category: Cloud Computing
Header_Cover: theme/images/banner-kubernetes.jpg
Tags: Kubernetes

En este artículo vamos a configurar un **cluster de Kubernetes (k8s)** y para ello he decidido utilizar la distribución **k3s**.

Todo el proceso se llevará a cabo en un escenario *Vagrant* que las siguientes máquinas:

- **controlador:** máquina que controlará el *cluster*. Se encuentra conectada a mi red doméstica en modo puente.
- **worker1:** máquina que actuará como *worker*. Se encuentra conectada a mi red doméstica en modo puente.
- **worker2:** máquina que actuará como *worker*. Se encuentra conectada a mi red doméstica en modo puente.

Puedes descargar el fichero *Vagrantfile* desde [aquí](images/hlc_despliegue_de_un_cluster_de_kubernetes/Vagrantfile.txt).

## ¿Qué es k3s?
s
