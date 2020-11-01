Title: Configuración de apache mediante archivo .htaccess asasa
Date: 2020/10/31
Category: Servicios de Red e Internet
Header_Cover: theme/images/banner-servicios.jpg
Tags: Apache, web, htaccess

## Configuración de apache mediante archivo .htaccess

Un fichero `.htaccess` (hypertext access), también conocido como archivo de configuración distribuida, es un fichero especial, popularizado por el **Servidor HTTP Apache** que nos permite definir diferentes directivas de configuración para cada directorio (con sus respectivos subdirectorios) sin necesidad de editar el archivo de configuración principal de Apache.

Para permitir el uso de los ficheros `.htaccess` o restringir las directivas que se pueden aplicar usamos la directiva `AllowOverride`, que puede ir acompañada de una o varias opciones: `All`, `AuthConfig`, `FileInfo`, `Indexes`, `Limit`, … Estudia para que sirve cada una de las opciones.

#### Ejercicios

**Date de alta en un *proveedor de hosting*. ¿Si necesitamos configurar el servidor web que han configurado los administradores del proveedor?, ¿qué podemos hacer? Explica la directiva `AllowOverride` de apache2. Utilizando archivos `.htaccess` realiza las siguientes configuraciones:**

**1. Habilita el listado de ficheros en la URL `http://host.dominio/nas`.**

En el fichero `.htaccess` introducimos la siguiente línea para que nos muestre la lista de los ficheros:

<pre>
Options +Indexes
</pre>

**2. Crea una redirección permanente: cuando entremos en `ttp://host.dominio/google` salte a `www.google.es`.**

En el fichero `.htaccess` introducimos la siguiente línea para que nos haga la redirección:

<pre>
Redirect /google www.google.es
</pre>

**3. Pedir autentificación para entrar en la URL `http://host.dominio/prohibido`. (No la hagas si has elegido como proveedor CDMON, en la plataforma de prueba, no funciona.)**
