Este pequeño proyecto intenta levantar un dos o mas servidores en los que tendremos instalados diferentes herramientas como 
    docker
    jenkins
    jfrog xray
    artifactory
esto con el fin de hacer algunas pruebas en las que deberia instalar certificados para permitir TLS minimo 1.2 en los servidores

primero se realizara la instalacion del aplication gateway asi como de los 2 servidores y en uno de ellos instalaremos una de las herramientas, posteriormente realizaremos la instalacion del segundo servidor con 3 herramientas.

una vez que la instalacion se haya realizado de manera correcta se procedera a validar que las herramientas hacia su uso externo usen https pero internamente entre los servidores y el application gateway usen http

posteriormente se realizara la instalacion de los certificados digitales para poder hacer el uso de HTTPS en el backend

