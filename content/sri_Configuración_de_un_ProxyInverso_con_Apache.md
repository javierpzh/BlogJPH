Title: Configuración de un proxy inverso con Apache
Date: 2018/03/03
Category: Servicios de Red e Internet
Header_Cover: theme/images/banner-servicios.jpg
Tags: Proxy Inverso, Apache

En este artículo vamos a instalar un **proxy inverso** con *Apache*.

El escenario en el que vamos a trabajar, está definido en este [Vagrantfile](images/sri_Configuración_de_un_ProxyInverso_con_Apache/Vagrantfile.txt).

Tendremos una máquina llamada **balanceador** que estará conectada a nuestra red doméstica, de manera que podremos acceder a ella, además de estar conectada a una red privada, a la que también pertenecerán dos máquinas, cada una con un servidor *Apache* y que servirán webs distintas.

Este *proxy inverso* se encargará de servir

 para que sirva dos páginas webs distintas mediante la misma dirección IP.
