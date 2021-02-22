Title: Aumento de rendimiento de servidores web con Varnish
Date: 2021/02/22
Category: Servicios de Red e Internet
Header_Cover: theme/images/banner-servicios.jpg
Tags: Nginx, PHP_FPM, Varnish

En este artículo vamos a ver como podemos aumentar el rendimiento de nuestro servidor web con **Varnish**.

Para ello, antes, vamos a comparar el rendimiento de distintas configuraciones de servidores web sirviendo páginas dinámicas programadas con *PHP*, en concreto, vamos a servir un *CMS Wordpress*.

Las configuraciones que vamos a realizar son las siguientes:

- Módulo Apache2-PHP5
- Apache2 + PHP-FPM (socket unix)
- Apache2 + PHP-FPM (socket TCP)
- Nginx + PHP-FPM (socket unix)
- Nginx + PHP-FPM (socket TCP)

Para cada una de las configuraciones he hecho una prueba de rendimiento con el comando `ab`, por ejemplo, durante 10 segundos, he hecho 200 peticiones concurrentes.

<pre>
ab -t 10 -c 200 -k http://172.22.x.x/wordpress/index.php
</pre>

Después de hacer muchas pruebas de rendimiento con un número variable de peticiones concurrentes (1, 10, 25, 50, 75, 100, 250, 500, 1000) y distintas direcciones del *Wordpress*, los resultados obtenidos son los siguientes:

![.](images/sri_aumento_de_rendimiento_de_servidores_web_con_Varnish/grafica.png)

**NOTA:** No es importante el número concreto de peticiones/segundo. Puede variar por muchas razones, como pueden ser:

- Desde donde haga las pruebas (no es lo mismo hacerlas desde *localhost*, o desde una máquina en la misma red, o desde internet).
- Del estado del servidor, que recursos tenga libre,...

Lo importante es calcular una media intentando hacer las pruebas en un escenario lo más similar posible (por eso después de realizar cada prueba es recomendable reiniciar los servicios).

Podemos determinar que la opción que nos ofrece más rendimiento es **Nginx + PHP-FPM (socket unix)**, cuyo resultado es aproximadamente unas 600 peticiones/segundo (parámetro *Requests per second* de `ab`).

A partir de esa configuración vamos a intentar aumentar el rendimiento de nuestro servidor.

Para ello vamos a llevar a cabo los siguientes apartados:

**1. Vamos a configurar una máquina con la configuración ganadora: Nginx + PHP-FPM (socket unix). Para ello ejecuta la receta *ansible* que encontraras en [este repositorio](https://github.com/josedom24/ansible_nginx_fpm_php). Accede al *Wordpress* y termina la configuración del sitio.**



**2. Vamos a hacer las pruebas de rendimiento desde la misma máquina, es decir vamos a ejecutar instrucciones similares a esta:**

<pre>
ab -t 10 -c 200 -k http:/127.0.0.1/wordpress/index.php
</pre>

Realiza algunas prueba de rendimiento con varios valores distintos para el nivel de concurrencia (50,100,250,500) y apunta el resultado de peticiones/segundo (parámetro Requests per second de ab). Puedes hacer varias pruebas y quedarte con la media. Reinicia el servidor nginx y el fpm-php entre cada prueba para que los resultados sean los más reales posibles.



**3. Configura un *proxy inverso - caché Varnish* escuchando en el puerto 80 y que se comunica con el servidor web por el puerto 8080. Entrega y muestra una comprobación de que *Varnish* está funcionando con la nueva configuración. Realiza pruebas de rendimiento (quedate con el resultado del parámetro Requests per second) y comprueba si hemos aumentado el rendimiento. Si hacemos varias peticiones a la misma URL, ¿cuantas peticiones llegan al servidor web? (comprueba el fichero access.log para averiguarlo).**



.
