# Práctica 2 - Semáforos
1.  Existen N personas que deben ser chequeadas por un detector de metales antes de poder ingresar al avión.  
    a. Analice el problema y defina qué procesos, recursos y semáforos serán necesarios/convenientes, además  de  las  posibles  sincronizaciones  requeridas  para resolver el problema. 
    b. Implemente una solución que modele el acceso de las personas a un detector (es decir, si el detector está libre la persona lo puede utilizar; en caso contrario, debe esperar).  
    c. Modifique su solución para el caso que haya tres detectores. 

a) y b)
```c
    sem mutex = 1

    process Persona[i: 1..N]:{
        P(mutex)
        //usar detector
        V(mutex)
    }
```
c) Inicializamos el semáforo con el valor 3, debido a que tenemos 3 sensores. Como bien sabemos, la operación P(s) lo que hace es decrementar en 1 el valor de s, por lo tanto si una persona empieza a usar un sensor, s pasará a tomar el valor 2 (si se empieza a utilizar el otro sensor, s tendrá ahora el valor 1). Cuando el sensor que está siendo usado es liberado, se pasa a realizar  la operación V(s), la cual lo que hace es incrementar en 1 el vlaor de s.
```c
    sem mutex = 3

    process Persona[i: 1..N]{
        P(mutex)
        //usar detector
        V(mutex)
    }
```

--- 
2.  Un sistema de control cuenta con 4 procesos que realizan chequeos en forma colaborativa. Para ello, reciben el historial de fallos del día anterior (por simplicidad, de tamaño  N).  De  cada  fallo,  se  conoce  su  número  de  identificación  (ID)  y  su  nivel  de gravedad (0=bajo, 1=intermedio, 2=alto, 3=crítico). Resuelva considerando las siguientes situaciones: 
a) Se debe imprimir en pantalla los ID de todos los errores críticos (no importa el orden). 
b) Se debe calcular la cantidad de fallos por nivel de gravedad, debiendo quedar los resultados en un vector global. 
c) Ídem  b)  pero  cada  proceso  debe  ocuparse  de  contar  los  fallos  de  un  nivel  de  gravedad determinado. 

a)
```c
    sem mutex = 1; int cant = 0; Fallo fallo; queue q[N];

    procedure Proceso[i:1..4]{
        P(mutex)
        while (cant < N){
            fallo = q.pop()
            cant = cant + 1
            V(mutex)
            if (fallo.nivel == 3){
                print(fallo.id)
            }
            P(mutex)
        }
        V(mutex)
    }
```
```c
    sem mutex = 1; int cant = 0; Fallo fallo; queue q[N]; vContador[4] = ([4] 0); semNivel[4] = ([4] 1); int nivel;
    procedure Procesar[i:1..4]{
        P(mutex)
        while (cant < N){
            fallo = q.pop()
            cant = cant + 1
            V(mutex)
            nivel = fallo.nivel
            P(semNivel[nivel])
            vContador[nivel] = vContador[nivel] + 1
            V(semNivel[nivel])
            P(mutex) 
        }
        V(mutex)
    }

```

---
3.  Un  sistema  operativo  mantiene  5  instancias  de  un  recurso  almacenadas  en  una  cola. 
Además, existen P procesos que necesitan usar una instancia del recurso. Para eso, deben sacar la instancia de la cola antes de usarla. Una vez usada, la instancia debe ser encolada nuevamente. 
```c
colaRecurso q[5]; sem mutex = 1; sem mutexq = 5;

procedure Consumidores[i:1..P]{
    while (True){
        P(mutex)
        P(mutexq)
        recurso = q.pop()
        //usar recurso
        V(mutexq)
        P(mutexq)
        q.push(recurso)
        V(mutexq)
        V(mutex)
    }
}
```

--- 
4.  Suponga  que  existe  una  BD  que  puede  ser  accedida  por  6  usuarios  como  máximo  al 
mismo  tiempo.  Además,  los  usuarios  se  clasifican  como  usuarios  de  prioridad  alta  y 
usuarios de prioridad baja. Por último, la BD tiene la siguiente restricción: 
* no puede haber más de 4 usuarios con prioridad alta al mismo tiempo usando la BD. 
* no puede haber más de 5 usuarios con prioridad baja al mismo tiempo usando la BD. 
Indique si la solución presentada es la más adecuada. Justifique la respuesta.

```c
    Var 
    sem: semaphoro := 6; 
    alta: semaphoro := 4; 
    baja: semaphoro := 5; 
```
```c
    Process Usuario-Alta [I:1..L]:: {    
        P (sem); 
        P (alta); 
        //usa la BD 
        V(sem); 
        V(alta); 
    }
```
```c
    Process Usuario-Baja [I:1..K]:: { 
        P (sem); 
        P (baja); 
        //usa la BD 
        V(sem); 
        V(baja); 
    } 
```
* Lo que podemos observar es que los semáforos están mal declarados, ya que la declaración correcta sería:
```c
    sem semaphoro = 1
    sem alta = 1
    sem baja = 1
```
* Otra cosa que debería modificarse, es que se debería bloquear primero el paso por prioridad, es decir, se debe hacer primero el P(alta) o P(baja), debido a que si no se hace esto, y ya hay 4 usuarios de prioridad alta, un 5to usuario va a poder entrar, y eso hace que la solución sea incorrecta.

---
5.  En  una  empresa  de  logística  de  paquetes  existe  una  sala  de  contenedores  donde  se 
preparan las entregas. Cada contenedor puede almacenar un paquete y la sala cuenta con capacidad para N contenedores. Resuelva considerando las siguientes situaciones: 
a) La empresa cuenta con 2 empleados:  un empleado Preparador que se ocupa de preparar  los  paquetes  y  dejarlos  en  los  contenedores;  un  empelado  Entregador que  se  ocupa  de  tomar  los  paquetes  de  los  contenedores  y  realizar  la  entregas. Tanto el Preparador como el Entregador trabajan de a un paquete por vez. 
b) Modifique la solución a) para el caso en que haya P empleados Preparadores. 
c) Modifique la solución a) para el caso en que haya E empleados Entregadores. 
d) Modifique la solución a) para el caso en que haya P empleados Preparadores y E empleados Entregadores. 

```c
    //SOLUCIÓN A
    ColaPaquete q[N]
    sem vacio = 1;
    sem lleno = 0;

    Procedure preparador {
        while (true){
            //prepara el paquete
            P(vacio)
            q.push(paquete)
            V(lleno)
        }
    }

    Procedure entregador {
        while(true){
            P(lleno)
            paquete = q.pop
            V(vacio)
            //entregar paquete
        }
    }
```

```c
    //SOLUCIÓN B
    ColaPaquete q[N]
    sem vacio = 1;
    sem lleno = 0;
    sem mutexP = 1;

    Procedure preparador[i: 1..P] {
        while (true){
            //prepara el paquete
            P(vacio)
            P(mutexP)
            q.push(paquete)
            V(mutexP)
            V(lleno)
        }
    }

    Procedure entregador {
        while(true){
            P(lleno)
            paquete = q.pop
            V(vacio)
            //entregar paquete
        }
    }
```

```c
    //SOLUCIÓN B
    ColaPaquete q[N]
    sem vacio = 1;
    sem lleno = 0;
    sem mutexE = 1;

    Procedure preparador {
        while (true){
            //prepara el paquete
            P(vacio)
            q.push(paquete)
            V(lleno)
        }
    }

    Procedure entregador[i: 1..E] {
        while(true){
            P(lleno)
            P(mutexE)
            paquete = q.pop
            V(mutexE)
            V(vacio)
            //entregar paquete
        }
    }
```

```c
    //SOLUCIÓN D
    ColaPaquete q[N]
    sem vacio = 1;
    sem lleno = 0;
    sem mutexP = 1;
    sem mutexE = 1;

    Procedure preparador[i: 1..P] {
        while (true){
            //prepara el paquete
            P(vacio)
            P(mutexP)
            q.push(paquete)
            V(mutexP)
            V(lleno)
        }
    }

    Procedure entregador[i: 1..E] {
        while(true){
            P(lleno)
            P(mutexE)
            paquete = q.pop
            V(mutexE)
            V(vacio)
            //entregar paquete
        }
    }
```


--- 
6.  Existen N personas que deben imprimir un trabajo cada una. Resolver cada ítem usando  semáforos: 
a) Implemente una solución suponiendo que existe una única impresora compartida por todas las personas, y las mismas la deben usar de a una persona a la vez, sin importar el orden. Existe una función Imprimir(documento) llamada por la persona que simula el uso de la impresora. Sólo se deben usar los procesos que representan a las Personas.

```c
sem mutex = 1;

Procedure personas[i:1..N]{
    P(mutex)
    Imprimir(documento)
    V(mutex)
}
```

b) Modifique la solución de (a) para el caso en que se deba respetar el orden de llegada. 

```c
sem mutex = 1;
queueOrden q;
sem espera[P] = ([P] 0);
int aux;
bool libre = true;

Procedure personas[i:1..N]{
    P(mutex)
    if(libre){
        libre = false
        V(mutex)
    }
    else{
        q.push(i)
        V(mutex)
        P(espera[i])
    }
    Imprimir(documento)
    P(mutex)
    if(q.isEmpty()){
        libre = true
    }
    else{
        aux = q.pop()
        V(espera[i])
    }
    V(mutex)
}
```

c) Modifique  la  solución  de  (a)  para  el  caso  en  que  se  deba  respetar  estrictamente el orden dado por el identificador del proceso (la persona X no puede usar la impresora hasta que no haya terminado de usarla la persona X-1). 

```c
int proximo = 0
sem espera[P] = ([P] 0)

Procedure personas[i:1..N]{
   if (proximo != i){
        P(espera[i])
   }
   imprimir(documento)
   proximo = proximo + 1
   V(espera[proximo])
}
```

d) Modifique la solución de (b) para el caso en que además hay un proceso Coordinador que le indica a cada persona que es su turno de usar la impresora.

```c
sem mutex = 1
sem espera[P] = ([P] 0)
sem listo = 0
sem llena = 0
qLlegada = q

Procedure persona[i:1..N]{
    P(mutex)
    q.push(i)
    V(mutex)
    V(llena)
    P(espera[i])
    imprimir(documento)
    V(listo)
}

Procedure coordinador{
    int aux;
    for i = 1..P{
        P(llena)
        P(mutex)
        aux = q.pop()
        V(mutex)
        V(espera[aux])
        P(listo)
    }
}
```

e) Modificar la solución (d) para el caso en que sean 5 impresoras. El coordinador le indica a la persona cuando puede usar una impresora, y cual debe usar.  

```c
sem espera[P] = ([P] 0);
sem mutex = 1
sem llena = 0
qLlegada q
int impresoras[5] = {1,2,3,4,5}
sem cantImpresoras = 5
int personaImpresora[P] = ([P] -1)
sem mutexImp = 1

Procedure personas[i:1..N]{
    P(mutex)
    c.push(i)
    V(mutex)
    V(llena)
    P(espera[i])
    Imprimir(documento, personaImpresora[i])
    P(mutexImp)
    impresoras.push(personaImpresora[i])
    V(mutexImp)
    V(impresoras)
}

Procedure coordinador{
    int aux,
    int imaux;
    for i = 1..P{
        P(llena)
        P(mutex)
        aux = q.pop()
        V(mutex)
        P(impresoras)
        P(mutexImp)
        imaux = impresoras.pop()
        V(mutexImp)
        personaImpresora[aux] = imaux
        V(espera[aux])
    }
}

```

--- 
7. Suponga que se tiene un curso con 50 alumnos. Cada alumno debe realizar una tarea y existen  10  enunciados  posibles.  Una  vez  que  todos  los  alumnos  eligieron  su  tarea, comienzan a realizarla. Cada vez que un alumno termina su tarea, le avisa al profesor y se queda esperando el puntaje del grupo, el cual está dado por todos aquellos que comparten el  mismo  enunciado.  Cuando  un  grupo  terminó,  el  profesor  les  otorga  un  puntaje  que representa el orden en que se terminó esa tarea de las 10 posibles. 

*Nota: Para elegir la tarea suponga que existe una función elegir que le asigna una tarea a un alumno (esta función asignará 10 tareas diferentes entre 50 alumnos, es decir, que 5 alumnos tendrán la tarea 1, otros 5 la tarea 2 y así sucesivamente para las 10 tareas)*

```c
sem mutex = 1;
sem alumnBarrera = 0;
sem maestroAwk = 0;
sem seDioPuntaje[10] = ([10] 0);
int puntajeTarea[10] = ([10] 0);
int contador = 0;
queue fin;

process alumno[i:1..50]{
    Tarea archTarea; int tarea; int puntaje; int j;
    P(mutex);
    tarea = elegir();
    contador++;
    if (contador == 50){
        for j = 1 ..50{
            V(alumnBarrera);
        }
    }
    V(mutex);
    P(alumnBarrera);
    archTarea.realizarTarea();
    P(mutex)
    fin.push(tarea);
    V(mutex);
    V(maestroAwk);
    P(seDioPuntaje[tarea]);
    puntaje = puntajeTarea[tarea];

}


process profesor{
    int puntaje = 10; int contTareas[10] = ([10] 0);
    for j = 1..50{
        P(maestroAwk);
        P(mutex);
        tarea = fin.pop();
        V(mutex);
        contTareas[tarea]++;
        if (contTareas[tarea] == 5){
            puntajeTarea[tarea] = puntaje;
            for i = 1..5{
                V(seDioPuntaje[tarea]);
            }
            puntaje--;
        }
    }
}

```

---
8.  Una fábrica de piezas metálicas debe producir T piezas por día. Para eso, cuenta con E empleados que se ocupan de producir las piezas de a una por vez (se asume  T>E). La fábrica  empieza  a  producir  una  vez  que  todos  los  empleados  llegaron.  Mientras  haya piezas  por  fabricar,  los  empleados  tomarán  una  y  la  realizarán.  Cada  empleado  puede tardar distinto  tiempo  en  fabricar  una  pieza.  Al  finalizar  el  día,  se  le  da  un  premio  al empleado que más piezas fabricó. 

```c
sem mutex = 1;
sem barrera = 0;
sem mutexFinalizoEmpleado = 1;
sem verPremio = 0;
int cantidad = 0;
int piezas = 0;
int contadorEmpleado[E] = ([E] 0);
int finalizoEmpleado = 0;
int premio = 0;
sem empresaAwk = 0;


process empleado[i:1..E]{
    bool tienePremio = false;
    P(mutex);
    cantidadEmpleado++;
    if(cantidadEmpleado == E){
        for j = 1.. E{
            V(barrera);
        }
    }
    V(mutex);
    P(barrera);
    P(mutex);
    while(piezas < T){
        //tomar pieza
        cantidadPiezas++;
        V(mutex);
        //fabricar piezas
        contadorEmpleado[i]++;
        P(mutex);
    }
    V(mutex);
    P(mutexFinalizoEmpleado);
    finalizoEmpleado++;
    if (finalizoEmpleado == E){
        V(empresaAwk);
    }
    V(mutexFinalizoEmpleado);
    P(verPremio);
    if (premio == i){
        tienePremio = true;
    }
}

process empresa{
    int j;
    P(empresaAwk);
    premio - contadoEmpleado.indexOf(contadorEmpleado.max());
    for j = 1..E{
        V(verPremio);
    }
}

```

--- 
9.  Resolver el funcionamiento en una fábrica de ventanas con 7 empleados (4 carpinteros, 1 vidriero y 2 armadores) que trabajan de la siguiente manera: 
* Los carpinteros continuamente hacen marcos (cada marco es armando por un único carpintero) y los deja en un depósito con capacidad de almacenar 30 marcos. 
* El vidriero continuamente hace vidrios y los deja en otro depósito con capacidad para 50 vidrios. 
* Los  armadores  continuamente  toman  un  marco  y  un  vidrio  (en  ese  orden)  de  los  depósitos correspondientes y arman la ventana (cada ventana es armada por un único armador). 

```c
    sem capacidadMarcos = 30;
    sem capacidadVidrios = 50;
    sem mutexMarco = 1;
    sem mutexVidrio = 1;
    sem hayMarco = 0;
    sem hayVidrio = 0;
    sem mutexVentana = 1;
    queueMarcos qm;
    queueVidrios qv;
    queueVentana qventana;

    process carpintero[i:1..4]{
        Marco marco;
        while (true){
            P(capacidadMarcos);
            marco = hacerMarco();
            P(mutexMarco);
            qm.push(marco);
            V(hayMarco);
        }
    }

    process vidriero{
        Vidrio vidrio;
        while (true){
            P(capacidadVidrio);
            vidrio = hacerVidrio();
            P(mutexVidrio);
            qv.push(vidrio);
            V(hayVidrio);
        }
    }

    process armador[i:1..2]{
        Marco marco;
        Vidrio vidrio;
        Ventana ventana;
        while(true){
            P(hayMarco);
            P(mutexMarco);
            marco = qm.pop();
            V(mutexMarco);
            V(capacidadMarco);
            P(hayVidrio);
            P(mutexVidrio);
            vidrio = qv.pop();
            V(mutexVidrio);
            V(capacidadVidrio);
            ventana = armarVentana(marco, vidrio);
            P(mutexVentana);
            qVentana.push(ventana);
            V(mutexVentana);
        }
    }
```
 
---
10. A una cerealera van T camiones a descargarse trigo y M camiones a descargar maíz. Sólo hay lugar para que 7 camiones a la vez descarguen, pero no pueden ser más de 5 del mismo tipo de cereal. Nota: no usar un proceso extra que actué como coordinador, resolverlo entre los camiones. 

```c
sem camiones = 7;
sem trigo = 5;
sem maiz = 5;

process camionTrigo[i:1..T]{
    P(trigo);
    P(camiones);
    //descargar trigo
    V(camiones);
    V(trigo);
}

Process camionMaiz[i:1..M]{
    P(maiz);
    P(camiones);
    //descargar maiz
    V(camiones);
    V(maiz);
}

```
 
---
11. En un vacunatorio hay un empleado de salud para vacunar a 50 personas. El empleado de salud atiende a las personas de acuerdo con el orden de llegada y de a 5 personas a la vez.  Es  decir,  que  cuando  está  libre  debe  esperar  a  que  haya  al  menos  5  personas esperando, luego vacuna a las 5 primeras personas, y al terminar las deja ir para esperar por otras 5. Cuando ha atendido a las 50 personas el empleado de salud se retira. 
*Nota: todos  los  procesos  deben  terminar  su  ejecución;  asegurarse  de  no  realizar  Busy  Waiting; suponga que el empleado tienen una función VacunarPersona() que simula que el empleado está vacunando a UNA persona.*

```c
sem mutex = 1;
sem despertar = 0;
sem esperarVacuna[50] = ([50] 0);
queue q;
int cant = 0;

Process persona[i: 1..50]{
    P(mutex);
    cant++;
    q.push(i);
    if(cant == 50){
        V(despertar);
        cant = 0;
    }
    V(mutex);
    P(esperarVacuna[i]);
}

Process empleado{
    int i,j,aux;
    queue vacunados;

    for i = 1..10{
        P(despertar);
        for j = 1..5{
            P(mutex);
            aux = q.pop();
            V(mutex);
            VacunarPersona(aux);
            vacunados.push(aux);
        }
        for j = 1..5{
            aux = vacunados.pop();
            V(esperarVacuna[aux]);
        }
    }

}

```

---
12. Simular la atención en una Terminal de Micros que posee 3 puestos para hisopar a  150  pasajeros. En cada puesto hay una Enfermera que atiende a los pasajeros de acuerdo con el orden de llegada al mismo. Cuando llega un pasajero se dirige al puesto que tenga menos  gente  esperando.  Espera  a  que  la  enfermera  correspondiente  lo  llame  para hisoparlo,  y  luego  se  retira.  *Nota:  sólo  deben  usar  procesos  Pasajero  y  Enfermera. Además, suponer que existe una función Hisopar() que simula la atención del pasajero por parte de la enfermera correspondiente.*

```c
sem mutex = 1;
sem mutexQ[3] = ([3] 1);
sem esperaPersona[150] = ([150] 0);
sem llena[3] = ([3] 0);
queue espera[3];
int hisopados = 0;
sem mutexHisopado = 1;

Process pasajero[id:1..150]{
    int queue;
    P(mutex);
    queue = obtenerColaMasVacia(espera);
    V(mutex);
    P(mutexQ[queue]);
    espera[queue].push(id);
    V(mutexQ[queue]);
    V(llena[queue]);
    P(esperaPersona[id]);
    //persona siendo hisopada
    P(esperaPersona[id]);
}

Process enfermera[id:1..3]{
    int pasajero; int j;
    while(hisopados < 150){
        P(llena[i]);
        if(!espera[id].isEmpty()){
            P(mutexQ[id]);
            pasajero = espera[id].pop();
            V(mutexQ[id]);
            V(esperaPersona[pasajero]);
            hisopar(pasajero);
            V(esperaPersona[pasajero]);
            P(mutexHisopado);
            hisopados++;
            if(hisopados == 150){
                for j = 1..3{
                    V(llena[j]);
                }
            }
            V(mutexHisopado);
        }
    }
}


```