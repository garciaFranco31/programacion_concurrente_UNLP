# Explicación TP1 - Variables Compartidas

Tenemos que ver que si hay una variable compartida entre dos o más procesos, hay que asegurarnos de que se modifique de forma atómica, para que así ningún otro proceso pueda interferir mientras esa variable está siendo modificada.
Cuando modificamos una variable de forma atómica, lo que estamos haciendo es que los otros procesos no puedan ver los estados intermedios de esa variable.

```c
    //ACCIONES ATÓMICAS --> son instrucciones de máquina.
    load inicio, fin 
    add inicio, fin
    store inicio, fin
```

* inicio es donde se encuentra el valor al inicio y fin, donde se almacenará.

* Historias -> forma en la que se van intercalando las acciones de los distintos procesos y que valores se van obteniendo. Las historias pueden ser valores válidos o no, hay que evitar estos últimos.

## Soluciones de grano grueso

Se debe demorar al proceo en una determinada condición "B", hasta que la misma sea verdadera y en ese momento ejecutar de forma atómica las sentencias.

```c
    <await (B); sentencias>
```

* La atomicidad comienza en el momento que la cheque la condición y la misma es verdadera, no se puede meter nadie a trabajar con las variables que se encuentran dentro de los símbolos mayor y menor.
* Brinda sincronización por exclusión mutua y/o por condición.

### Await para exclusión mutua

El proceso ejecuta sentencias de forma atómica, no se debe esperar ninguna condición "B". Solo un proceso a la vez puede estar ejecutando esa "Sección Crítica"

```c
    <sentencias> //dentro de los signos, es la SC.
```

* Otro proceso tiene que esperar al que está ejecutando la SC para poder ejecutarla.
* Los procesos que están esperando para ejecutar su SC no acceden en orden, puede entrar cualquiera a ejecutar el código de la SC.

### Await para Sincronizaión por condición

El proceso se demora únicamente hasta que la condición booleana "B" es verdadera.

```c
    <await B;> //dentro de los signos, es la SC.
```

* No se tiene un conjunto de sentencias que trabaje con exclusión mutua.

#### Ejemplo 2

Se tiene un salón con cuatro puertas por donde entran los alumnos a un exámen. Cada puerta lleva la cuenta de los que entraron por ella y a su vez se lleva la cuenta del total de personas en el salón.

```c
    int total = 0;
    Process puerta[id:1..4]{
        int cantPuerta = 0;
        while (true){
            //esperar llegada de alumno
            cantPuerta = cantPuerta + 1;
            <total = total + 1;>
        }
    }
```

* cantPuerta al ser una variable local a cada puerta, no es necesario que su incremento se haga atómicamente (de hecho, estaría mal).
* total debe ser incrementada atómicamente, porque es una variable compartida por todos los procesos. Se tiene que incrementar por exclusión mutua.
* se debe maximizar el uso de variables locales y disminuir el uso de variables compartidas.

#### Ejemplo 3

Hay un docente que les debe tomar examen oral a 30 alumnos (de a uno a la vez) de acuerdo al orden dado por el Identificador del proceso.
Cada alumno debe esperar a que el docente lo llame, luego debe esperar a que el docente le avise que el examen terminó y se va, mientras el docente llama al siguiente alumno.

```c
    int rindiendo = -1; //alumno que debe ser evaluado en "este momento", se inicializa en un valor no válido, porque el docente puede no haber llegado.
    bool listo = false;
    bool ok = false;

    Process Docente{
        for i = 1..30{
            rindiendo = i; //solo lo modifica el docente, no tiene que hacerse de forma atómica.
            <await ok>; //espera a que el alumno esté parado frente a él.
            ok = false;
            //toma el examen
            listo = true;//no hay interferencia con el alumno, por eso no debe hacerse de forma atómica.
            <await (not listo)>; //espera a que el alumno se de cuenta de que ya terminó de evaluarlo.
        }
    }

    Process Alumno[id:1..30]{
        <await (rindiendo == id)>//ingresar
        ok = true; //le avisa al docente que llegó y está listo para rendir.
        //Rinde el examen
        <await listo;>//retirarse del salon
        listo = false;//lo pasa a falso para la siguiente iteración, si el docente lo modificara, podría haber inconvenientes y que un alumno que todavía no rindió, se vaya antes de rendir.Nadie más lo modifica en ese momento, es por eso que la actualización no debe hacerse atómicamente.
    }

```

* Ambos procesos deben sincronizarse al inicio como al finalizar el exámen (en este caso), para que el docente no antienda a una persona que ya se fue.

### Ejemplo 4

Un cajero automático debe ser usado por N personas de a uno a la vez y según el orden de llegada al mismo. En caso de que llegue una persona anciana, la deben dejar ubicarse al principio de la cola.

```c
    //MI SOLUCIÓN
    queue fila;
    bool salio = false;
    bool libre = true;

    Process Cajero{
        if (libre & !fila.isEmpty()){
            idAux = fila.pop();
            libre = false;
        }
        libre = true;
        <await salio>
    }

    Process Persona[id:1..N]{
        //llega a la fila
        <fila.insertarOrdenado(id)>;
        <await libre>;
        //usa el cajero
        //se va
        salio = true;
    }
```

```c
//SOLUCIÓN DOCENTE
queue fila;
int siguiente = -1;
Process Persona[id:1..N]{
    int edad = id.getEdad(); //se inicializa con la edad de la persona.

    //si el cajero está ocupado, encolarse
    <if (siguiente = -1) siguiente = id
    else fila.agregar(id,edad)> //esto se hace por ser una variable compartida por todos los procesos persona y hay que evitar interferencia(sobreescritura).

    //Esperar el turno
    <await (siguiente == id)>;
    
    //usar el cajero, uso del recurso compartido
    //liberar el cajero
    <if (fila.isEmpty()) siguiente = -1
    else siguiente = fila.sacar()>;//si la cola está vacía, no hay que despertar a nadie, ni tampoco tiene que esperar a que llegue a alguien a usar el recurso.En este caso, se pone un valor inválido.

}
```

* Hay que ver si el cajero está ocupado y si hay gente en la cola.
* El cajero no es un proceso, es solamente un recurso que comparten las personas. Solamente tendremos el proceso persona. El cajero y su estado se representará por medio de variables.
* Las personas se administran el acceso al recurso entre ellas mismas.

# Explicación TP2 - Semáforos

## Declarción y operaciones con semáforos

Un semáforo internamente tiene un valor mayor o igual que 0. (0< Semaforo < 1)

```c
    sem mutex = 1; //tenemos que inicializarlo si o si en la decllaración
    sem espera[5] = ([5] 1 ) //se declara un array de 5 semaforos, todos inicializados en 1.
```

* A partir de que el semaforo es declarado, solamente podemos llamar una operación P o V sobre ese semáforo, nada más que eso.

**P:** Demora el proceso hasta que el valor del semáforo es mayor que 0, luego decrementa el valor del mismo en 1. 

```c
    <await (S > 0) s = s - 1;> //se puede ver que la operación se realiza de forma atómica.
```

**V:** En forma atómica incrementa el valor interno del semáforo.

```c
    <s = s+1;>
```

* Permiten manejar sincronización por condición, por exclusión mutua y para una mezcla de ambas cosas.
* Si hay varios procesos que quieren hacer un P sobre un determinado semáforo, no hay ningún orden, es decir, no se van encolando esos pedidos, están todos esperando hasta que uno haga el V y luego estos procesos que quieren hacer el P, se pelean entre ellos para ver quien accede a realizar la operación P (esto puede no asegurar la eventual entrada). Si queremos que se hagan en orden, tenemos que implementar la solución utilizando otras técnicas.

#### Ejercicio 1

Hay C chicos y hay una bolsa con caramelos que nunca se vacía. Los chicos de a UNO van sacando de a UN caramelo y lo comen. Los chicos deben llevar la cuenta de cuantos caramelos han tomado de la bolsa.

```c
    sem mutex = 1;
    int cantidadTotal = 0;
    Process Chicos[1..N]{
        while (true){
            P(mutex);
            //tomar un caramelo
            <cantidadTotal = cantidadTotal + 1>;
            V(mutex);
            //comer caramelo
        }
    }
```

* El semaforo mutex se inicializa en 1, porque si yo lo inicializo en 0, todos los procesos quedarán bloqueados en la operación P. Este bloqueo sería permanente.
* Ningun proceso puede hacer un V si no está dentro de la SC. El V solo se puede hacer luego de terminar de utiliza la SC.

#### Ejercicio 2

Hay C chicos y ahora hay una bolsa con N caramelos. Los chicos de a UNO van sacando de a UN caramelo y lo comen. Los chicos deben llevar la cuenta de cuandos caramelos se han tomado de la bolsa.

```c
int cant = 0;
sem mutex = 1;

Process Chicos[1..C]{
    P(mutex);
    while (cant < N){
        //tomar caramelo 
        <cant = cant + 1>;
        V(mutex);
        //comer caramelo
        P(mutex);
    }
    V(mutex);
}

```

* si la condición de corte se está chequeando sin estar dentro de una SC, puede pasar que se estén sacando caramelos "invisibles/inexistentes".

#### Ejercicio 3

Hay C chicos y hay una bolsa con N caramelos administrada por UNA abuela. Cuando todos los chicos han llegado llaman a la abuela, y a partir de ese momento ella N veces selecciona un chico aleatoriamente y lo deja pasar a tomar un caramelo.

```c
sem mutex = 1;
int chicos = 0;
sem abuela = 0;
sem barrera = 0;
sem espera_chico[C] = ([C] 0);
bool seguir = true;
sem listo = 0;

Process Chicos[1..C]{
    int i;
    P(mutex);
    chicos = chicos + 1;
    <if (chicos == C){ 
        for i = 1..C{
            V(barrera);
            V(abuela);
        }
    }>;
    V(mutex);
    P(barrera);
    P(espera_chico[id]);
    while (seguir){
        //tomar caramelo
        V(listo);
        //comer caramelo
        P(espera_chico[id]);
    }
}

Process Abuela{
    int i;
    P(abuela);
    for i= 1..N{
        aux = (rand mod C); //seleccionar chico
        V(espera_chico[aux]); //despertar chico
        P(listo);
    }
    seguir = false;//avisa que no hay mas caramelos
    for aux = 1..C{
        V(espera_chico[aux]);
    }
}

```

* Los semáforos que están inicializados en 0, son aquellos que están siendo esperados a ser despertadoos, es algo asi como el <await (condicion)>.

#### Ejercicio 4

En una empresa de genética hay N clientes que envían secuencias de ADN para que sean analizadas y esperan los resultados para poder continuar. Para resolver estos análisis la empresa cuenta con 1 servidor que resuelve los pedidos de acuerdo al orden de llegada de los mismos.

```c
sem mutex = 1;
queue c;
sem pedidos = 0;
int resultados[N];
espera[N] = ([N] 0);

Process Cliente[id:1..N]{
    Secuencia s;
    while(true){
        P(mutex);
        push(C,(id,S));
        V(mutex);
        V(pedidos); //debe realizarse si o si después de hacer el push, no previo a él.
        P(espera[id]);
        resultados[id].verResultado();
        //cada posicion del vector resultado, es de un cliente particular, es independiente. Lo único que puede genrar interferencia, es si está gestionando una secuencia del mismo cliente.
    }
}

Process Servidor{
    Secuencia sec; int aux;
    while(true){
        P(pedidos); //una vez que haya al menos un elemento en la cola, accederá a ella para analizarlo.
        P(mutex);
        pop(C,(aux,sec));
        V(mutex);
        resultados[aux] = resolver(sec);
        V(espera[aux]);
    }
}

```

#### Ejercicio 5

En una empresa de genética hay N clientes que envían secuandias de ADN para que sean analizadas y esperan los resultados para poder continuar. Para resolver estos análisis la empresa cuenta con 2 serviores que van alternando su uso para no exigirlos de más (en todo momento uno está trabajando y el otro descansando); cada 5 horas cambia el servidor con el que se trabaja. El servidor que está trabajjando, toma un pedido (de a uno de acuerdo al orden de llegada de los mismos), lo resuelve y devuelve el resultado al cliente correspondiente.
Cuando terminan las 5 horas el servidor que se encuentra atendiendo un pedido, lo termina y luego intercambia los servidores.

```c

cola C;
sem mutex = 1;
sem clientes[N] = ([N] 0);
sem pedidos = 0;
int resultados[N];
sem turno[2] = (1,0):
bool finTiempo = false;
sem inicio = 0;


Process Cliente[id:1..N]{
    Secuencia s;
    P(mutex);
    enviar(C,(s,id)); //enviar muestra
    //espera resultado del análisis
    V(mutex);
    V(pedidos);
    P(clientes[id]);
    resultados[id].verResultado();//ve el resultado del análisis
}

Process Servidor[id:0..1]{
    int auxId; Secuencia sec; bool ok;
    while(true){
        P(turno[id]); //espera su turno
        finTiempo = false; //inicia el reloj
        V(inicio);
        ok = true;
        while(ok){
            P(pedidos);
            if(finTiempo){
                ok = false
                V(turno[1-id]);
            }
            else{
                P(mutex);
                analizar(C,(sec, auxId));
                V(mutex);
                resultado[auxId] = resultado(sec);
                V(clientes[auxId]);
            }
        }    
    }
}

Process Reloj{
    while(true){
        P(inicio);//espera inicio
        delay(5hs);
        finTiempo = true;
        V(pedidos); //avisa al final del tiempo
    }
}

```

* el servidor debe  esperar en un semáforo hasta que haya un pedido pendiente. No puede estar esperando en un semáforo o en otro, lo tiene que hacer en un único semáforo.
* Cada servidor tendrá un semáforo turno, donde se va a demorar hasta que deba trabajar.

#### Ejercicio 6

En una montaña hay 30 escaladores que en una parte de la subida deben utilizar un único paso de a uno a la vez y de acuerdo al orden de llegada al mismo.

```c
cola C;
sem espera[30] = ([30] 0);
bool libre = true;

Process Escalador[id:0..29]{
    //llega al paso
    P(mutex);
    if(libre){
        libre = false; //lo pongo en falso para que nadie más pueda pasar mientras yo lo estoy usando.
        V(mutex);
    }else{//en caso de que el paso no esté libre, tenngo que esperar, para lo cual me pongo en la cola y me demoro en el semáforo.
        push(C,id);
        V(mutex);
        P(espera[id]); //esta demora deja la SC ocupada
    }
    //usa el paso con exclusión mutua
    P(mutex);
    if(isEmpty (C)){
        libre = true;
    }else{
        pop(C,auxId);
        V(espera[auxId]); //no se demora al proceso, distinto al caso que nos pasó arriba.
    }
    V(mutex);
}
```

* Entre ellos respetan el orden al acceso del recurso usando una variante de passing the batton (passing the condition)

# Explicación TP3 - Monitores

## Sintaxis

```c
Monitor nombre{
    //variables permanentes del monitor
    Procedure nombre_proceso(){
        //variables locales al procedure
    }

    //codigo de inicialización
}

Process process[id:0..N-1]{

}

```


* Monitor es pasivo, está esperando pasivamente, hasta que se le haga algún pedido. Puede haber uno o más de uno.
* Dejan de existir las variables compartidas, o existen dentro de un proceso en particular o están dentro de un monitor, se acceden a ellas por medio del monitor.
* **Código de inicialización:** es lo primero que ejecuta el monitor cuando inicia el programa (si es que lo tiene), ahí es donde se inicializan las variables, hasta que no termine de ejecutarse, el monitor no acepta llamadas de ningún proceso. (no se usa en la práctica)
* Cuando un monitor está ejecutando algún proceso, el monitor está demorado, no puede ejecutar ningún otro proceso, hasta que termine el que está en ejecución.
* Los llamados a los procedimientos de un monitor NO se hacen de forma ordenada, si no que compiten para ver que proceso va a poder utilizar el monitor. Para que se hagan en orden de llegada, tenemos que implementar la solución a manopla, no se hace con respecto al acceso al monitor.
* Sincronización:
    - Por exclusión mutua: es implícita dentro del monitor.No se puede ejecutar más de un llamado a un procedimiento a la vez.
    
    - Por condición: se debe hacer de forma explícita por medio de las variables condición (variables permanenetes del monitor, no de los procesos ni compartidas). Un monitor no puede acceder a las variables condición de otro monitor. Para dormir se utiliza la sentencia *wait(cond)* y para despertar, la sentencia *signal(cond)*. Una vez que el proceso se despierta con signal, continua con la ejecución de la siguiente instrucción siguiente al wait.
    Para despertar a todos los procesos (por ejemplo cuando llegan todos a una barrera), se utiliza la sentencia *signal_all(cond)*.


#### Ejercicio 1

Existen N persona que desean utilizar un cajero automático. En este primer caso no se debe tener en cuenta el orden de llegada de las personas (cuando esta libre cualquier lo puede usar). SUpoga que hay una función UsarCajero() que simula el uso del cajero.

```c
//en este caso solamente debemos utilizar al cajero con exclusión mutua.

Monitor PasarAlCajero(){

}

Process Persona[id:0..N-1]{
    Cajero.PasarAlCajero();
}
```

#### Ejercicio 2

Mismo que el anterior, pero debemos respetar el orden de llegada.

```c
Monitor PasarAlCajero(){
    bool libre = true;
    cond cola;
    int esperando = 0;

    Procedure Pasar(){
        if(not libre){
            esperando++;
            wait(cola);
        }else{
            libre = false;
        }
    }

    Procedure Salir(){
        if(esperando > 0){
            esperando--;
            sinal(cola);
        }else{
            libre = true;
        }
    }
}

Process Persona[id:0..N-1]{
    Cajero.Pasar();
    UsarCajero();
    Cajero.Salir();
}

```

* No se puede utilizar *empty()* en una variable condición.

#### Ejercicio 3

Partiendo de la solución anterior, hacemos un cambio en el enunciado, agregando que si llega una persona anciana tiene prioridad.

```c
Monitor PasarAlCajero(){
    bool libre = true;
    cond espera[N];
    int idAux, esperando = 0;
    colaEspecial C;

    Procedure Pasar(id: in int, edad: in int){
        if(not libre){
            push(C, id, edad);
            esperando++;
            wait(espera[id]);
        }else{
            libre = false;
        }
    }

    Procedure Salir(id: out int){
        if(esperando > 0){
            esperando--;
            pop(C,idAux);
            signal(espera[idAux]);
        }else{
            libre = true;
        }
    }
}

Process Persona[id:0..N-1]{
    int edad = id.edad();
    Cajero.Pasar(id,edad);
    UsarCajero();
    Cajero.Salir(id);
}

```

#### Ejercicio 4

En un banco hay 3 empleados, y hay N clientes que deben ser atendidos por uno de ellos (cualquiera) de acuerdo al orden de llegada. Cuando uno de los empleados lo atiende el cliente le entrega los papeles y espera el resultado.

```c
Monitor Banco{
    cola eLibres;
    cond esperaC;
    int esperando = 0, cantLibre = 0;

    Procedure Llegada(idE: out int){
        if(cantLibres == 0){
            esperando++;
            wait(esperaC);
        }else{
            cantLibres--;
        }
        pop(eLibres,idE);
    }

    Procedure Proximo(idE: in int){
        push(eLibres, idE);
        if(esperando > 0){
            esperando--;
            signal(esperaC);
        }else{
            cantLibres++;
        }
    }
}

Monitor Escritorio[id:0..2]{
    cond vcCliente, vcEmpleado;
    text datos, resultados;
    bool listo = false;

    Procedure Atencion(D: in text; R: out text){
        datos = D;
        listo = true;
        signal(vcEmpleado);
        wait(vcCliente);
        R = resultados;
        signal(vcEmpleado);
    }

    Procedure EsperarDatos(D: out text){
        if (not listo){
            wait(vcEmpleado);
        }
        D = datos;
    }

    Procedure EnviarResultados(R: in text){
        resultados = R;
        signal(vcCliente);
        wait(vcEmpleado);
        listo = false;
    }
}

Process Cliente[id:0..N-1]{
    int idE;
    text papel, res;
    Banco.Llegada(idE);
    Escritorio[idE].atencion(papel,res);
}

Process Empleado[id:0..2]{
    text datos;
    while(true){
        Banco.Proximo(id);
        Escritorio[id].esperarDatos(datos);
        res = resolverSolicitud();
        Escritorio[id].enviarResultados(res);
    }
}

```

* Hay un monitor para cada uno de los 3 empleados.

# Explicación TP4 - PMA

* Los programas están compuestos SOLO de procesos y canales (conocidos/compartidos por todos los procesos, son de tipo mailbox) NO HAY VARIABLES COMPARTIDAS.
* Los canales son como colas de mensajes enviados y no recibidos, respetan el orden FIFO.
* Los procesos UNICAMENTE interactuan entre ellos por medio del envío de mensajes.
* No se requiere usar más exclusión mutua, ya que no hay más recursos compartidos.

## Sintaxis
Declaración de canales
```c
    chan nombreCanal (tipoDato) //declaración de un único canal
    chan nombreArreglo [1..m](tipoDato) //declaración de un arreglo de canales.
```

* Sentencias de comunicación *send/recive*
  * el uso de cada canal es atómico, esto quiere decir que los mensjes se envían/reciben de a uno y que no se harán al mismo tiempo 2 operaciones sobre el mismo canal.

* Send es una operació no bloqueante, el proceso que envía mensaje, deposita dicho mensaje al final del canal y continúa con su ejecución. Esta operación se realiza si o si sobre un canal, el canal no debe ser generado aleatoriamente.
```c
    send nombreCanal (mensaje)
    send nombreArreglo [i](mensaje)
```

* Recive: es una operación bloqueante, si el canal está vacío se demora hasta que haya al menos un mensaje en él, luego saca el primer mensaje del canal.
```c
    recive nombreCanal (variables_para_el_mensaje)
    recive nombreArreglo [i](variables_para_el_mensaje)
```

* Empty: permite consultar si un canal está o no vacío. Retorna un valor booleano.
```c
    empty(nombreCanal)
    empty(nombreArreglo[i])
```
hay que tener cuidado, porque puede generar Busy Waiting que en PMA está permitido, pero igual hay que tratar de evitarlo.


#### Ejercicio 1
En una empresa de software hay N personas que pruebam un nuevo producto para encontrar errores, cuando encuentran uno generan un reporte para que un empleado corrija el error (las personas no deben recibir ninguna respuesta). El empleado toma los reportes de acuerdo al orden de llegada, los evalúa y hace las correcciones necesarias.

```c
    chan Reportes(texto);
    
    Process Persona[id:0..N-1]{
        texto R;
        while (true){
            R = "generarReporteConProblemas";
            send Reportes (R);
        }
    }
    
    Process Empleado{
        texto rep;
        while(true){
            receive Reportes(rep);
            resolver(rep);
        }
    }

```
* vamos a tener N procesos persona y 1 proceso empleado que resuelve los reportes.
* vamos a usar u canal como buffer "ordenado" de personas, donde las personas van a ir dejando los reportes y el empleado los va a sacar de ahí para resolverlos.

### Ejercicio 2
*pequeña modificación del ejercicio 1*
En una empresa de software hay N personas que pruebam un nuevo producto para encontrar errores, cuando encuentran uno generan un reporte para que un empleado corrija el error y esperan la respuesta del mismo. El empleado toma los reportes de acuerdo al orden de llegada, los evalúa y le responde a la persona que hizo el reporte.
```c
chan Reportes (int, texto); //personas envía el reporte a empleado, tiene también un campo int, por medio del cual la persona le envía al empleado su id para así recibir la respuesta correctamente.

//chan Respuestas (texto); //empleado envia respuesta a personas
chan Respuestas[N](texto);


Process Persona[id:0..N-1]{
    texto R, Res;
    while(true){
        R = generarReporte
        send Reportes (id, R);
        //receive Respuestas(Res); --> tiene que saber cuando es su respuesta y cuando es de otro, por lo tanto no nos sirve tener un único canal para recibir las respuestas.
        receive Respuestas[id] (Res);
    }
}

Process Empleado(){
    texto Rep, Res;
    int idP;
    while(true){
        receive Reportes(idP, Rep);
        Res = generarRespuesta;
        send Respuestas[idP](Res);// --> el empleado debe saber a quién enviarle la respuesta.
    }
}

```
* Hay que sincornizar a la persona que hizo el reporte, con el empleado que va a resolverlo.
* No podemos utilizar un único canal, debido a que podrían mezclarse tanto los reportes como las respuestas dentro del mismo (el empleado podría recibir una respuesta y la persona un reporte).

### Ejercicio 3
*pequeña modificación del ejercicio 2, ahora son 3 empleados para atender los reportes*
En una empresa de software hay N personas que pruebam un nuevo producto para encontrar errores, cuando encuentran uno generan un reporte para que alguno de los 3 empleados corrija el error y esperan la respuesta del mismo. Los empleados toman los reportes de acuerdo al orden de llegada, los evalúan, hacen las correcciones necesarias y le responden a la persona que hizo el reporte.

```c
chan Respuestas[N](texto);
chan Reportes(int,texto);

Process Personas[id:0..N-1]{
    texto R, Res;
    while(true){
        R = generarReporte();
        send Reportes (id, R);
        receive Respuestas[id] (Res);
    }
}

Process Empleados[id:0..2]{
    texto Rep, Res;
    int idP;
    while(true){
        receive Reportes(idP, Rep);
        Res = resolver(Res);
        send Respuestas[idP](Res);
    }
}

```
* El canal de **reportes** sigue siendo uno solo, debido a que a las personas no les importa que empleado resuelva el pedido, no es algo particular, si no que el empleado que esté libre es el que va a agarrar el reporte para resolverlo.
  
### Ejercicio 4
*Hacemos una modificación al ejercicio 1*
En una empresa de software hay N personas que prueban un nuevo producto para encontrar errores, cuando encuentran uno generan un reporte para que un empleado corrija el error (las personas no deben recibir ninguna respuesta). El empleado toma los reportes de acuerdo al orden de llegada, los evalúa y hace las correcciones necesarias; cuando no hay reportes para atender el empleado se dedica a leer durante 10 minutos. 

```c
chan Reportes(texto);

Process Personas[id:0..N-1]{
    texto R;
    while(true){
        R = generarReporte();
        send Reportes(R);
    }
}

Process Empleado(){
    texto Rep;
    while(true){
        if (not empty(Reportes)){
            receive Reportes(Rep);
            resolver(Rep);
        }else{
            delay (600) //lee 10 minutos
        }
    }
}

```

* el empleado no puede quedarse bloqueado haciendo un *receive*, ya que sino no podrá leer los 10 minutos.
* El empleado debe chequear antes de hacer el *receive* si hay algo en el canal.
* *Empty* lo usamos únicamente cuando debemos hacer algo más si no hay nada en el canal, ya que si solamente utilizamos *receive*, se quedaría en loop consultando si hay algo o no en el canal sin poder hacer nada más.
  
### Ejercicio 5
*Hacemos una modificación al ejercicio 4*
En una empresa de software hay N personas que prueban un nuevo producto para encontrar errores, cuando encuentran uno generan un reporte para que uno de los 3 empleados corrija el error (las personas no deben recibir ninguna respuesta). Los empleados toman los reportes de acuerdo al orden de llegada, los evalúa y hacen las correcciones necesarias; cuando no hay reportes para atender los empleados se dedican a leer durante 10 minutos. 

```c
chan Reportes(texto);
chan Pedido(id);
//chan Siguiente(texto);
chan Siguiente[3](texto);

Process Personas[id:0..N-1]{
    texto R;
    while(true){
        R = generarReporte();
        send Reportes(R);
    }
}

// Process Empleado[id:0..2]{ *viejo*
//     texto Rep;
//     while(true){
//         if (not empty(Reportes)){
//             //receive Reportes(Rep); --> esto puede producir demora innecesaria, ya que si hay un único mensaje en el canal, solamente uno de los empleados va a poder recibir el mensaje, el resto se quedarían demorados en esta operación en vez de leer.
//             resolver(Rep);
//         }else{
//             delay (600) //lee 10 minutos
//         }
//     }
// }

Process Empleados[id:0..2]{ //*nuevo*
    texto Rep;
    while(true){
        send Pedido(id);
        // if (not empty (Siguiente[id])){
        //     receive Siguiente[id](Rep); -->sigue habiendo demora innecesaria, luego de agregar el id al Siguiente, deja de haber demora innecesaria.
        //     resolver(Rep);
        // }else{
        //     delay (600) //lee 10 minutos
        // }
        receive Siguiente[id](Rep); //se resuelve el problema de que el canal "estaba vacío" porque el coordinador no llegó a atender el pedido y se fue a leer aunque había trabajo.
        if (Rep <> "Vacio"){
            resolver(Rep);
        }else{
            delay (600);
        }
    }
}

Process Coordinador(){
    texto Rep;
    int idE;
    while(true){
        receive Pedido(idE);
        if (not empty (Reportes)){
            Rep = "Vacio";
        }else{
            receive Reportes (Rep);
        }
        send Siguiente[idE](Rep);
    }
}

```
* En esta solución no podemos prescindir del Empty, ya que sin él, se quedaría dormido en el receive y no haría la otra actividad (leer en este caso).
* Se puede tener un canal para cada empleado, esto obligaría a que la persona le entregue su reporte a UN empeado en particular (no es lo que se pide).
* Vamos a necesitar de un proceso **coordinador** que esté entre las personas y los empleados, el cual recibirá los reportes de las personas y los empleados le pedirán a él los reportes que deben resolver.
  * Un empleado le "pide" el siguiente reporte al coordinador por medio de un canal *Pedido*, el cual devolverá el reporte a atender por un canal *Siguiente*.
* Se debe usar un canal privado para que cada empleado reciba la respuesta que es sólo para él. El coordinador agarra al que está libre para que resuelva el pedido.
* Puede pasar que el coordinador no haya atendido su pedido, por lo tanto y que el empleado siempre esté un pedido "atrasado".
  * Ahora el empleado debe esperar si o si una respuesta del coordinador (si hay o no hay reportes pendientes).