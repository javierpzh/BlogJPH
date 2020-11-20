Title: Actualización de CentOS 7 a CentOS 8
Category: Administración de Sistemas Operativos
Date: 2020/11/20
Header_Cover: theme/images/banner-sistemas.jpg
Tags: Actualización, CentOS7, CentOS8

Vamos a realizar la actualización de la instancia **Quijote**, que creamos en este [post](https://javierpzh.github.io/creacion-del-escenario-de-trabajo-en-openstack.html) la cuál posee **CentOS 7**, a **CentOS 8**, garantizando que todos los servicios previos continúen funcionando.



Para comprobar la versión de *CentOS* que tenemos instalada en este momento:

<pre>
cat /etc/redhat-release
</pre>

Lo primero sería instalar el repositorio epel.

<pre>
yum install epel-release -y
</pre>
