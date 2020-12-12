Title: Modificación del escenario de trabajo en OpenStack
Date: 2020/12/12
Category: Cloud Computing
Header_Cover: theme/images/banner-hlc.jpg
Tags: OpenStack

**Vamos a modificar el escenario que tenemos actualmente en OpenStack para que se adecúe a la realización de todas las prácticas en todos los módulos de 2º, en particular para que tenga una estructura más real a la de varios equipos detrás de un cortafuegos, separando los servidores en dos redes: red interna y DMZ. Para ello vamos a reutilizar todo lo hecho hasta ahora y añadiremos una máquina más: Frestón**

![.](images/hlc_modificacion_del_escenario_de_trabajo_en_OpenStack/escenario2.png)

#### 1. Creación de la red DMZ:

- **Nombre: DMZ de (nombre de usuario)**

- **10.0.2.0/24**

Vamos a crear una nueva red, en esta caso, una red DMZ, que se situará entre la red interna y la externa.

Para crearla, nos dirigimos hacia nuestro panel de administración de *OpenStack* y nos situamos en el apartado **Redes**. Una vez aquí, *clickamos* en el botón llamado **+ Crear red**, y se nos abrirá un menú como el siguiente, donde debemos indicar las características de la red que queremos crear:

![.](images/hlc_modificacion_del_escenario_de_trabajo_en_OpenStack/crearDMZ1.png)



![.](images/hlc_modificacion_del_escenario_de_trabajo_en_OpenStack/crearDMZ2.png)



![.](images/hlc_modificacion_del_escenario_de_trabajo_en_OpenStack/crearDMZ3.png)




#### 2. Creación de las instancias:

Antes de crear la propia instancia en sí, vamos a crear el volumen sobre el que posteriormente generaremos la instancia **freston**. Para ello he creado un volumen con estas preferencias:

![.](images/hlc_modificacion_del_escenario_de_trabajo_en_OpenStack/crearvolumenfreston.png)

- **freston:**

    - **Debian Buster sobre volumen de 10GB con sabor m1.mini**
    - **Conectada a la red interna**
    - **Accesible indirectamente a través de dulcinea**
    - **IP estática**


#### 3. Modificación de la ubicación de quijote

- **Pasa de la red interna a la DMZ y su direccionamiento tiene que modificarse apropiadamente**
