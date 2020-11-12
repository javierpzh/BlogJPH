Title: Creación del escenario de trabajo en OpenStack
Date: 2020/11/12
Category: Cloud Computing
Header_Cover: theme/images/banner-hlc.jpg
Tags: OpenStack



**1. Creación de la red interna:**

- **Nombre red interna de <nombre de usuario>**
- **10.0.1.0/24**



**2. Creación de las instancias:**

- **Dulcinea:**

    - **Debian Buster sobre volumen de 10GB con sabor m1.mini**
    - **Accesible directamente a través de la red externa y con una IP flotante**
    - **Conectada a la red interna, de la que será la puerta de enlace**

- **Sancho:**

    - **Ubuntu 20.04 sobre volumen de 10GB con sabor m1.mini**
    - **Conectada a la red interna**
    - **Accesible indirectamente a través de dulcinea**

- **Quijote:**

    - **CentOS 7 sobre volumen de 10GB con sabor m1.mini**
    - **Conectada a la red interna**
    - **Accesible indirectamente a través de dulcinea**



**3. Configuración de NAT en Dulcinea (Es necesario deshabilitar la seguridad en todos los puertos de dulcinea) [[https://youtu.be/jqfILWzHrS0]]**



**4.Definición de contraseña en todas las instancias (para poder modificarla desde consola en caso necesario)**



**5. Modificación de las instancias sancho y quijote para que usen direccionamiento estático y dulcinea como puerta de enlace**



**6. Modificación de la subred de la red interna, deshabilitando el servidor DHCP**



**7. Utilización de ssh-agent para acceder a las instancias**



**8. Creación del usuario profesor en todas las instancias. Usuario que puede utilizar sudo sin contraseña**



**9. Copia de las claves públicas de todos los profesores en las instancias para que puedan acceder con el usuario profesor**



**10. Realiza una actualización completa de todos los servidores**



**11. Configura el servidor con el nombre de dominio <nombre-usuario>.gonzalonazareno.org**



**12. Hasta que no esté configurado el servidor DNS, incluye resolución estática en las tres instancias tanto usando nombre completo como hostname**



**13. Asegúrate que el servidor tiene sincronizado su reloj utilizando un servidor NTP externo**
