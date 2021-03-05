Title: Despliegue de un cluster de Kubernetes
Date: 2018/03/05
Category: Cloud Computing
Header_Cover: theme/images/banner-kubernetes.jpg
Tags: Kubernetes

En este artículo vamos a desplegar un **cluster de Kubernetes (k8s)** y para ello he decidido utilizar la distribución **k3s**.

Todo el proceso se llevará a cabo en un escenario *Vagrant* que las siguientes máquinas:

- **controlador:** máquina que controlará el *cluster*. Se encuentra conectada a mi red doméstica en modo puente, posee la dirección IP 192.168.0.90
- **worker1:** máquina que actuará como *worker*. Se encuentra conectada a mi red doméstica en modo puente, posee la dirección IP 192.168.0.91
- **worker2:** máquina que actuará como *worker*. Se encuentra conectada a mi red doméstica en modo puente, posee la dirección IP 192.168.0.92

Puedes ver el fichero *Vagrantfile* desde [aquí](images/hlc_despliegue_de_un_cluster_de_kubernetes/Vagrantfile.txt).


## ¿Qué es k3s?

**k3s** es una distribución de *Kubernetes*, desarrollada por Rancher Labs, muy ligera y muy fácil de instalar, que requiere pocos requisitos y un uso de memoria mínimo.

Para el planteamiento de un entorno de desarrollo, esto se convierte en una gran mejora sobre lo que hemos hablado anteriormente en *Kubernetes*; crear un entorno mínimo para desarrollo, donde la creación del entorno es compleja y requiere de muchos recursos, aunque sea *Ansible* el que realice el trabajo difícil.

Entre las herramientas que nos proporciona se incluye **kubectl**. Esta herramienta, es una interfaz de línea de comandos desarrollada en *Go* para gestionar nuestros *clusters* de manera centralizada.

A continuación podemos ver un diagrama acerca de la estructura interna de *k3s*:

![.](images/hlc_despliegue_de_un_cluster_de_kubernetes/estructurainterna.png)


## Instalación de k3s en el controlador

Para llevar a cabo la instalación del *software* de **k3s**, vamos a utilizar el *script* de instalación que se nos proporciona. Para ello, necesitaremos disponer de la herramienta `curl` en nuestro sistema, así que vamos a instalarla:

<pre>
apt install curl -y
</pre>

Una vez instalada, procederemos a la descarga del propio *software* ejecutando el siguiente comando:

<pre>
root@controlador:~# curl -sfL https://get.k3s.io | sh -
[INFO]  Finding release for channel stable
[INFO]  Using v1.20.4+k3s1 as release
[INFO]  Downloading hash https://github.com/k3s-io/k3s/releases/download/v1.20.4+k3s1/sha256sum-amd64.txt
[INFO]  Downloading binary https://github.com/k3s-io/k3s/releases/download/v1.20.4+k3s1/k3s
[INFO]  Verifying binary download
[INFO]  Installing k3s to /usr/local/bin/k3s
[INFO]  Creating /usr/local/bin/kubectl symlink to k3s
[INFO]  Creating /usr/local/bin/crictl symlink to k3s
[INFO]  Creating /usr/local/bin/ctr symlink to k3s
[INFO]  Creating killall script /usr/local/bin/k3s-killall.sh
[INFO]  Creating uninstall script /usr/local/bin/k3s-uninstall.sh
[INFO]  env: Creating environment file /etc/systemd/system/k3s.service.env
[INFO]  systemd: Creating service file /etc/systemd/system/k3s.service
[INFO]  systemd: Enabling k3s unit
Created symlink /etc/systemd/system/multi-user.target.wants/k3s.service → /etc/systemd/system/k3s.service.
[INFO]  systemd: Starting k3s
</pre>

Realizada la instalación, ya dispondríamos de todas las herramientas necesarias, incluyendo `kubectl`. Para comprobarlo vamos a listar los nodos existentes en el *cluster*:

<pre>
root@controlador:~# kubectl get nodes
NAME          STATUS   ROLES                  AGE     VERSION
controlador   Ready    control-plane,master   2m24s   v1.20.4+k3s1
</pre>

Lógicamente tan sólo nos muestra uno, que hace referencia al propio nodo que acabamos de instalar, ya que aún no hemos asociado ningún *worker*.

Es el momento de vincular los *workers*, para ello, necesitaremos conocer el *token* del nodo maestro. Para conocer dicho *token* ejecutamos el siguiente comando:

<pre>
root@controlador:~# cat /var/lib/rancher/k3s/server/node-token
K1029e8b8d41dc51fdadcb3f1a27d19d552c0e6a33a393a0d21c7af242f7493fd5c::server:43add1f59252e7f700f6840d3dd9a700
</pre>

Hecho esto, es el momento de pasar con la instalación de *k3s* en los *workers*.


## Instalación de k3s en los workers

Para llevar a cabo la instalación del *software* de **k3s** en estas máquinas, volveremos a utilizar el *script* de instalación que se nos proporciona, pero esta vez, tendremos que indicarle dos parámetros para llevar a cabo la vinculación al nodo maestro. Dichos parámetros son:

- **K3S_URL:**
- **K3S_TOKEN:**


Para ello, necesitaremos disponer de la herramienta `curl` en nuestro sistema, así que vamos a instalarla:

<pre>
apt install curl -y
</pre>































.
