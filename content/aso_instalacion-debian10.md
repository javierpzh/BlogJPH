Title: Instalación Debian 10
Date: 2020/10/05
Category: Administración de Sistemas Operativos
Header_Cover: theme/images/banner-sistemas.jpg
Tags: debian, install, lvm

## Introducción

Antes de empezar a explicar el proceso que he seguido yo para la instalación del sistema operativo, voy a dar unos detalles para hacernos a la idea y colocarnos en la situación en la que se produce la instalación.
Yo poseo un portátil MSI que apenas se lanzó hace un año, esto lo comento ya que estos portátiles no son los que están más pensados para instalar estos sistemas y para realizar los tipos de tareas que requiere el grado, sino que están más pensados para un uso de gaming. Con esto lo que quiero decir, es que suelen presentar más problemas o más impedimentos a la hora de la instalación.
Ahora que ya estamos puestos en situación, solo queda decir que Debian va a convivir con Windows 10 en el disco sólido, algo que no va a influir en nada, pero lo comento también.

## Proceso de instalación

Lo primero obviamente sería descargarnos la iso de Debian que queremos instalar, en mi caso utilicé la última versión estable. Con esta iso y el programa Rufus, que es un programa para programar arranques, es decir, para preparar medios para la instalación de sistemas operativos, ya terminé todo lo que necesitaba y comencé el proceso. En mi caso dispongo de 160GB más o menos libre en el disco, que es lo que vamos a utilizar para Debian, aunque no todo en una solo partición simple, lo veremos más adelante.
Iniciamos el asistente del proceso y vamos introduciendo el nuevo usuario, contraseñas, ...
Hasta que llegamos a la parte que nos interesa, a la hora de indicar dónde, en que lugar del disco queremos instalar el sistema.
Indicamos que lo queremos particionar manualmente, y aquí veremos todas las particiones ya creadas y que utiliza Windows, y vemos que hay una con 160GB de espacio libre que es la que seleccionamos, y le creamos una tabla de particiones nueva. Ahora en el menú debe aparecernos una opción que dice `Configurar el Gestor de Volúmenes Lógicos (LVM)` , esto es lo que nos interesa.
Vamos a proceder a configurar nuestro LVM, aceptamos que queremos escribir los cambios en el disco y configurar LVM, ahora nos indica los volúmenes físicos libres, los volúmenes físicos en uso, los grupos de volúmenes y los volúmenes lógicos. Aún no tenemos nada, ya que lo acabamos de crear, así que vamos a empezar a darle forma creando el grupo de volúmenes que es la primera capa, le asignamos el nombre que nosotros queramos, y en el siguiente paso nos pide que incluyamos los dispositivos físicos que queramos que formen parte del grupo que estamos creando, yo añado el único dispositivo del que dispongo, aceptamos los cambios, y ahora en el menú de LVM nos aparece que ya disponemos de un volumen físico en uso, que es el que acabamos de añadir y también nos aparece que hay un grupo de volúmenes.
Ahora vamos a crear el volumen lógico que deseo, seleccionamos el grupo de volúmenes donde queremos crearlo, y le asignamos un nombre y el espacio correspondiente a nuestras necesidades, yo le voy a poner 100GB ya que voy a tener que utilizar bastantes máquinas virtuales y no quiero estar cada poco tiempo añadiendo espacio al volumen, de forma que me quedarían sin asignar unos 60GB que podría añadirle en cualquier momento si me fuese necesario. Aceptamos todos los cambios y salimos del menú de LVM, y podemos ver reflejado en el menú de particiones el LVM que acabamos de crear, ya solo nos quedaría seleccionar el volumen lógico de 100GB que es el que vamos a utilizar para instalar el sistema y proporcionarle un sistema de ficheros, en mi caso voy a indicarle uno de tipo XFS, ya que tiene la ventaja que permite las redimensiones en caliente garantizando la integridad de los datos. En el apartado del punto de montaje indicamos el sistema raíz y terminamos de definir la partición.
Ya lo tendríamos todo listo, así que finalizamos el particionado. En mi caso no me es necesario un área de intercambio (SWAP) ya que dispongo de 16GB de RAM, pero eso ya depende del equipo de cada uno.
Ya solo queda seleccionar el gestor de ventanas que deseemos (si deseamos alguno), yo uso GNOME por tanto lo selecciono y espero que termine de instalarse. El grub lo instalamos junto al sistema y habríamos terminado la instalación de Debian10.

## Primer inicio e instalación de drivers

Como dije antes los MSI suelen dar bastantes problemas o suelen ser más difíciles a la hora de funcionar con estos sistemas, pero en mi caso, el sistema desde el principio y simplemente con la instalación básica me funciona perfectamente, a diferencia de mis compañeros que también disponen de equipos de esta marca.
Lo único que no me funciona es el Wi-Fi, pero simplemente he buscado el driver de mi tarjeta de red, la cuál es 'Intel Corporation Wireless-AC 9560', desde la propia web de Intel nos proporcionan el driver necesario, lo instalamos y ya funciona. Me pasa algo que todavía no he encontrado la explicación ni he solucionado, y es que, como decía tengo tanto Windows como Debian instalados, y si entro en Windows, la siguiente vez que entre a Debian no me funciona el Wi-Fi, pero simplemente reiniciando el ordenador, y volviendo a entrar en Debian ya me funciona. O sea, depende del último sistema que haya utilizado, si solo utilizo Debian me lo reconoce siempre y perfecto, pero si entro en Windows sé que la próxima vez que entre en Debian tendré que reiniciar para que me funciona la red inalámbrica.
Por todo lo demás el sistema corre perfectamente.

## Instalación drivers GPU

Dispongo de una GPU Nvidia GTX1650 Max-Q, la cual la reconoce el sistema pero no la utiliza por defecto ya que obviamente no tiene instalados los drivers.
Antes de explicar el proceso que he seguido, voy a decir que todavía no he conseguido instalarla y sigo utilizando los gráficos integrados de mi CPU.
En primer lugar me descargue una utilidad que proporciona Nvidia para detectar el paquete que necesitamos dependiendo de nuestra tarjeta gráfica, ya que hay varios paquetes para los diferentes modelos.
La utilidad es muy simple de descargar y lo único que hace es decirte el nombre del paquete recomendado para el modelo de tu tarjeta. Se llama `nvidia-detect`, y simplemente la instalamos y la ejecutamos.
En mi caso me recomendaba instalar el paquete llamado `nvidia-driver`. Ya sabía que paquete tenía que instalar y configurar pero antes de proceder a instalarlo, para evitar conflictos con los controladores libres nouveau, procedí a crear una lista negra:

<pre>
sudo nano /etc/modprobe.d/blacklist-nouveau.conf
</pre>

En este fichero escribí lo siguiente:

<pre>
blacklist nouveau

blacklist lbm-nouveau

options nouveau modeset=0

alias nouveau off

alias lbm-nouveau off
</pre>

Si no realizas este paso, al instalar los drivers de Nvidia y al reiniciar el equipo, no llega a iniciar el sistema y se queda la pantalla en negra sin poder abrir ni siquiera una tty.
Reinicié y el sistema arrancó perfecto, pero aún no estaba utilizando la GPU dedicada, ya que aún no la había configurado. Aquí llegó mi problema, ya que me aparecía el propio programa de configuración de Nvidia incluso como aplicación gráfica pero no sé porque no iniciaba. Intenté configurarlo desde la terminal:

<pre>
nvidia-settings
</pre>

Pero no me dejaba tampoco y me reportaba que no encontraba ningún dispositivo, sinceramente ahí ya estaba un poco perdido. Investigué un poco por ahí y leí que necesitaba instalar los siguientes paquetes para poder configurar la tarjeta gráfica:

<pre>
apt install nvidia-xconfig
apt install nvidia-glx
</pre>

Después de instalar estos paquetes reinicié pero esta vez el sistema no arrancó, se quedó la pantalla en negro, sin poder abrir una tty, pero al menos pude recurrir al 'reisub' y no tuve que tirar de botonazo.
En este punto no podía hacer otra cosa, así que decidí entrar en modo recovery y desinstalar los paquetes relacionados con Nvidia con el siguiente comando:

<pre>
apt-get purge nvidia.
</pre>

Y volví a la configuración predeterminada, volví a reiniciar y el sistema arrancó.
A día de hoy trabajo con los gráficos integrados y sigo investigando pero de momento no encuentro nada, pero al menos quería comentar mi experiencia con este tema.
