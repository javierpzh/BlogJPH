Title: Modificación del escenario de trabajo en OpenStack
Date: 2020/12/12
Category: Cloud Computing
Header_Cover: theme/images/banner-hlc.jpg
Tags: OpenStack

**En este *post* voy a realizar modificaciones sobre un escenario de *OpenStack* que fue creado anteriormente y cuya explicación se encuentra en [este post](https://javierpzh.github.io/creacion-del-escenario-de-trabajo-en-openstack.html), por si quieres saber más al respecto.**

**Vamos a modificar el escenario que tenemos actualmente en OpenStack para que se adecúe a la realización de todas las prácticas en todos los módulos de 2º, en particular para que tenga una estructura más real a la de varios equipos detrás de un cortafuegos, separando los servidores en dos redes: red interna y DMZ. Para ello vamos a reutilizar todo lo hecho hasta ahora y añadiremos una máquina más: Frestón**

![.](images/hlc_modificacion_del_escenario_de_trabajo_en_OpenStack/escenario2.png)

#### 1. Creación de la red DMZ:

- **Nombre: DMZ de (nombre de usuario)**
- **10.0.2.0/24**

Vamos a crear una nueva red, en esta caso, una **red DMZ**, que se situará entre la red interna y la externa.

Para crearla, nos dirigimos hacia nuestro panel de administración de *OpenStack* y nos situamos en la sección de **Redes**. Una vez aquí, *clickamos* en el botón llamado **+ Crear red**, y se nos abrirá un menú, donde debemos indicar las características de la red que queremos crear:

En el primer apartado de este asistente, indicamos el nombre que poseerá nuestra nueva red:

![.](images/hlc_modificacion_del_escenario_de_trabajo_en_OpenStack/crearDMZ1.png)

En segundo lugar, indicamos las direcciones de red que abarcará, y deshabilitaremos la puerta de enlace ya que no nos va hacer falta debido a que vamos a poner a *Dulcinea* como *gateway*:

![.](images/hlc_modificacion_del_escenario_de_trabajo_en_OpenStack/crearDMZ2.png)

Por último, vamos a dejar marcada la opción de **Habilitar DHCP** que viene de manera predeterminada, para que de esta forma, nos dé una dirección IP de manera automática cuando conectemos una instancia.

![.](images/hlc_modificacion_del_escenario_de_trabajo_en_OpenStack/crearDMZ3.png)

Hecho esto, ya tendríamos nuestra red DMZ creada, como podemos observar:

![.](images/hlc_modificacion_del_escenario_de_trabajo_en_OpenStack/crearDMZ4.png)

Hemos finalizado este primer ejercicio.

#### 2. Creación de las instancias:

- **freston:**

    - **Debian Buster sobre volumen de 10GB con sabor m1.mini**
    - **Conectada a la red interna**
    - **Accesible indirectamente a través de dulcinea**
    - **IP estática**

Antes de crear la propia instancia en sí, vamos a crear el volumen sobre el que posteriormente generaremos la instancia **freston**. Para ello he creado un volumen con estas preferencias:

![.](images/hlc_modificacion_del_escenario_de_trabajo_en_OpenStack/crearvolumenfreston.png)

Una vez ha terminado el proceso de creación del nuevo volumen, obtenemos como resultado:

![.](images/hlc_modificacion_del_escenario_de_trabajo_en_OpenStack/crearvolumenfrestonfin.png)

Ahora sí, es momento de crear la nueva instancia.

Para crearla, nos dirigimos hacia nuestro panel de administración de *OpenStack* y nos situamos en la sección de **Instancias**. Una vez aquí, *clickamos* en el botón llamado **+ Lanzar instancia**, y se nos abrirá un menú, donde debemos indicar las características de la instancia que queremos crear:

En el primer apartado de este asistente, indicamos el nombre que poseerá nuestra nueva instancia:

![.](images/hlc_modificacion_del_escenario_de_trabajo_en_OpenStack/crearfreston1.png)



![.](images/hlc_modificacion_del_escenario_de_trabajo_en_OpenStack/crearfreston2.png)



![.](images/hlc_modificacion_del_escenario_de_trabajo_en_OpenStack/crearfreston3.png)



![.](images/hlc_modificacion_del_escenario_de_trabajo_en_OpenStack/crearfreston4.png)

Aquí podemos ver como hemos creado esta instancia correctamente y que pertenece a la red interna, ya que posee una dirección **10.0.1.7**

![.](images/hlc_modificacion_del_escenario_de_trabajo_en_OpenStack/crearfrestonfin.png)




















#### 3. Modificación de la ubicación de quijote

- **Pasa de la red interna a la DMZ y su direccionamiento tiene que modificarse apropiadamente**
