Title: Certificados digitales. HTTPS
Date: 2020/11/17
Category: Seguridad y Alta Disponibilidad
Header_Cover: theme/images/banner-seguridad.jpg
Tags: Criptografía, Certificado digital, HTTPS

## Certificado digital de persona física

#### Tarea 1: Instalación del certificado

**1. Una vez que hayas obtenido tu certificado, explica brevemente como se instala en tu navegador favorito.**

Una vez hemos solicitado y descargado nuestro certificado digital, se nos guardará en forma de una especie de carpeta/fichero que son los que tendremos que utilizar.

En mi caso utilizo **Mozilla Firefox**, por tanto lo voy a instalar en este navegador.

Nos dirigimos al menú de **Preferencias** del navegador, y en el apartado de **Privacidad & Seguridad**, nos desplazamos hasta la último opción, llamada **Certificados**. Aquí hacremos *click* en **Ver certificados** y se nos abrirá una pequeña ventana en la que tendremos distintas secciones. Nos interesa la sección **Sus certificados**, y aquí haremos *click* en **Importar** y se nos abrirá una ventana donde tendremos que seleccionar el certificado que hemos descargado antes, y con esto, ya tendremos instalado nuestro certificado en nuestro navegador.

**2. Muestra una captura de pantalla donde se vea las preferencias del navegador donde se ve instalado tu certificado.**

![.](images/sad_certificados_digitales_HTTPS/certinstalado.png)

**3. ¿Cómo puedes hacer una copia de tu certificado? ¿Como vas a realizar la copia de seguridad de tu certificado? Razona la respuesta.**

En la ventana de la imagen anterior, si seleccionamos nuestro certificado, y seleccionamos la opción **Hacer copia...** y elegimos una ruta en nuestro PC, habremos hecho una copia del certificado instalado.

...

...

...

...

**4. Investiga como exportar la clave pública de tu certificado.**

Para exportar nuestra clave pública, debemos hacer doble *click* en nuestro certificado, y se nos abrirá una nueva pestaña con la información del certificado. Nos dirigimos hasta el apartado **Información de clave pública** y aquí encontraremos nuestra clave pública y ya podremos exportarla y compartirla:

![.](images/sad_certificados_digitales_HTTPS/infoclavepublica.png)


#### Tarea 2: Validación del certificado

**1. Instala en tu ordenador el software [autofirma](https://firmaelectronica.gob.es/Home/Descargas.html) y desde la página de *VALIDe*, valida tu certificado. Muestra capturas de pantalla donde se comprueba la validación.**

Para instalar **Autofirma** sobre *Debian*, tenemos que tener en cuenta que necesitamos tener instalado **Java**. Para instalar *Java* ejecutamos:

<pre>
sudo apt install default-jdk openjdk-11-jdk libnss3-tools -y
</pre>

Verificamos la versión instalada:

<pre>
javier@debian:~/Descargas/AutoFirma_Linux$ java -version
openjdk version "11.0.9" 2020-10-20
OpenJDK Runtime Environment (build 11.0.9+11-post-Debian-1deb10u1)
OpenJDK 64-Bit Server VM (build 11.0.9+11-post-Debian-1deb10u1, mixed mode, sharing)
</pre>

Ahora nos descargamos el programa de instalación de *Autofirma* desde este [enlace](https://firmaelectronica.gob.es/Home/Descargas.html).

Una vez descargado y descomprimido, instalamos el paquete `.deb`:

<pre>
sudo dpkg -i AutoFirma_1_6_5.deb
</pre>

Y ya tendríamos instalado **Autofirma**. Comprobamos que lo podemos abrir:

![.](images/sad_certificados_digitales_HTTPS/autofirma.png)

Para validar nuestro certificado, nos dirigimos a la página de **VALIDe** y al apartado **[Validar Certificado](https://valide.redsara.es/valide/validarCertificado/ejecutar.html)**. Seleccionamos el certificado mediante el software de *Autofirma*:

 ![.](images/sad_certificados_digitales_HTTPS/certautofirma.png)

Seleccionamos nuestro certificado y hacemos *click* en **Validar**, y obtendremos una respuesta sobre sí el certificado es válido o no. En mi caso:

![.](images/sad_certificados_digitales_HTTPS/certvalido.png)


#### Tarea 3: Firma electrónica

**1. Utilizando la página *VALIDe* y el programa *Autofirma*, firma un documento con tu certificado y envíalo por correo a un compañero.**



**2. Tu debes recibir otro documento firmado por un compañero y utilizando las herramientas anteriores debes visualizar la firma (Visualizar Firma) y (Verificar Firma). ¿Puedes verificar la firma aunque no tengas la clave pública de tu compañero?, ¿Es necesario estar conectado a internet para hacer la validación de la firma?. Razona tus respuestas.**



**3. Entre dos compañeros, firmar los dos un documento, verificar la firma para comprobar que está firmado por los dos.**




#### Tarea 4: Autentificación

**1. Utilizando tu certificado accede a alguna página de la administración pública )cita médica, becas, puntos del carnet,…). Entrega capturas de pantalla donde se demuestre el acceso a ellas.**




## HTTPS / SSL

**Antes de hacer esta práctica vamos a crear una página web (puedes usar una página estática o instalar una aplicación web) en un servidor web apache2 que se acceda con el nombre `tunombre.iesgn.org`.**

#### Tarea 1: Certificado autofirmado

**Esta práctica la vamos a realizar con un compañero. En un primer momento un alumno creará una Autoridad Certficadora y firmará un certificado para la página del otro alumno. Posteriormente se volverá a realizar la práctica con los roles cambiados.**

**Para hacer esta práctica puedes buscar información en internet, algunos enlaces interesantes:**

- [Phil’s X509/SSL Guide](https://www.phildev.net/ssl/)
- [How to setup your own CA with OpenSSL](https://gist.github.com/Soarez/9688998)
- [Crear autoridad certificadora (CA) y certificados autofirmados en Linux](https://blog.guillen.io/2018/09/29/crear-autoridad-certificadora-ca-y-certificados-autofirmados-en-linux/)

**El alumno que hace de Autoridad Certificadora deberá entregar una documentación donde explique los siguientes puntos:**

**1. Crear su autoridad certificadora (generar el certificado digital de la CA). Mostrar el fichero de configuración de la AC.**



**2. Debe recibir el fichero CSR (Solicitud de Firmar un Certificado) de su compañero, debe firmarlo y enviar el certificado generado a su compañero.**



**3. ¿Qué otra información debes aportar a tu compañero para que éste configure de forma adecuada su servidor web con el certificado generado?**




**El alumno que hace de administrador del servidor web, debe entregar una documentación que describa los siguientes puntos:**

**1. Crea una clave privada RSA de 4096 bits para identificar el servidor.**



**2. Utiliza la clave anterior para generar un CSR, considerando que deseas acceder al servidor tanto con el FQDN (`tunombre.iesgn.org`) como con el nombre de host (implica el uso de las extensiones `Alt Name`).**



**3. Envía la solicitud de firma a la entidad certificadora (su compañero).**



**4. Recibe como respuesta un certificado X.509 para el servidor firmado y el certificado de la autoridad certificadora.**



**5. Configura tu servidor web con https en el puerto 443, haciendo que las peticiones http se redireccionen a https (forzar https).**



**6. Instala ahora un servidor nginx, y realiza la misma configuración que anteriormente para que se sirva la página con HTTPS.**
