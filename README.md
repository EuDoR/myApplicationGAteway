Este pequeño proyecto intenta levantar un dos o mas servidores en los que tendremos instalados diferentes herramientas como 
    docker
    jenkins
    jfrog xray
    artifactory
esto con el fin de hacer algunas pruebas en las que deberia instalar certificados para permitir TLS minimo 1.2 en los servidores

primero se realizara la instalacion del aplication gateway asi como de los 2 servidores y en uno de ellos instalaremos una de las herramientas, posteriormente realizaremos la instalacion del segundo servidor con 3 herramientas.

una vez que la instalacion se haya realizado de manera correcta se procedera a validar que las herramientas hacia su uso externo usen https pero internamente entre los servidores y el application gateway usen http

posteriormente se realizara la instalacion de los certificados digitales para poder hacer el uso de HTTPS en el backend

instrucciones para crear //////////////

1. Planeación de la arquitectura
    {Define la red virtual (VNet) y subredes necesarias.
    Decide en qué subred estará el Application Gateway y en cuáles los servidores.
    Determina los grupos de seguridad (NSG) y reglas de acceso.}
        1.1 Determina el rango de direcciones IP para la VNet
            Decide el rango privado que usará tu red virtual, por ejemplo: 10.0.0.0/16.
            Este rango debe ser suficientemente amplio para tus subredes y crecimiento futuro.
        1.2 Decide cuántas subredes necesitas
            Subred para Application Gateway:
            Ejemplo: 10.0.1.0/24
            Debe ser exclusiva para el Application Gateway.
            Subred para las máquinas virtuales:
            Ejemplo: 10.0.2.0/24
            Puedes usar una sola subred para ambas VMs o crear una subred para cada VM si quieres mayor aislamiento.
        1.3 Asigna nombres descriptivos
            Ejemplo de nombres:
            VNet: MyAppVNet
            Subred Application Gateway: AppGatewaySubnet
            Subred VMs: VMSubnet1, VMSubnet2
        1.4 Reúne la información necesaria
            Rango de IP para la VNet.
            Rango de IP para cada subred.
            Nombres para la VNet y subredes.
            Región de Azure donde desplegarás los recursos.
        1.5 Considera requisitos adicionales
            El Application Gateway debe estar en una subred dedicada.
            Verifica que los rangos de IP no se solapen.
            Piensa si necesitarás conectividad con otras redes (VPN, ExpressRoute).
            Decide si las VMs estarán en la misma subred o en subredes separadas.
        1.6 Documenta tu diseño
            Haz un diagrama simple o una tabla con los rangos y nombres de cada subred.
            Ejemplo:
            Recurso	            Nombre	            Rango IP
            VNet	            MyAppVNet	        10.0.0.0/16
            Subred App Gateway	AppGatewaySubnet	10.0.1.0/24
            Subred VM 1         VMSubnet1	        10.0.2.0/24
            Subred VM 2         VMSubnet2	        10.0.3.0/24

2. Provisionamiento de recursos en Azure
    {Crea la VNet y subredes.
    Crea dos máquinas virtuales (VMs) en las subredes correspondientes.
    Crea el Application Gateway en su propia subred.}
    2.1 Define los recursos para las VMs:
        Cada VM debe estar asociada a una subred diferente (por ejemplo, VM1 en VMSubnet1, VM2 en VMSubnet2).
        Necesitarás recursos adicionales: IP pública (si la necesitas), interfaz de red (NIC), y posiblemente un NSG (grupo de seguridad de red) para cada VM.
    2.2 Define el recurso para el Application Gateway:
        Debe estar en la subred exclusiva para el gateway.
        Requiere su propia IP pública, configuración de frontend/backend, y asociación a la subred.
3. Configuración de los servidores
    Accede a cada VM.
    En la primera VM, instala Docker.
    En la segunda VM, instala Jenkins, JFrog Xray y Artifactory.
    Configura los servicios para que escuchen en los puertos adecuados.
4. Configuración del Application Gateway
    Define los listeners (HTTP/HTTPS) en el Application Gateway.
    Crea los backend pools apuntando a las IPs privadas de las VMs.
    Configura las reglas de enrutamiento para dirigir el tráfico a cada servidor según el dominio o ruta.
    (Opcional) Configura certificados SSL para el frontend (HTTPS).
5. Pruebas iniciales
    Accede a los servicios desde el exterior a través del Application Gateway.
    Verifica que el tráfico externo use HTTPS y que el Application Gateway enrute correctamente a cada backend.
6. Configuración de HTTPS interno (opcional)
    Si quieres que el tráfico entre el Application Gateway y los servidores también sea HTTPS, instala certificados en los servidores y configura el Application Gateway para validar esos certificados.
7. Automatización y gestión
    Automatiza el despliegue usando Terraform (o ARM/Bicep si prefieres).
    Usa scripts de provisionamiento para instalar y configurar las herramientas en las VMs.
8. Validación y pruebas finales
    Verifica que todos los servicios sean accesibles y seguros.
    Asegúrate de que las reglas de firewall y NSG permitan solo el tráfico necesario.