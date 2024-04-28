# Práctica 3 - Monitores

1.  Se dispone de un puente por el cual puede pasar un solo auto a la vez. Un auto pide permiso para pasar por el puente, cruza por el mismo y luego sigue su camino.

```c
Monitor  Puente 
    cond cola;  
    int cant= 0; 
 
    Procedure entrarPuente() 
        while ( cant > 0){ 
            wait (cola); 
        }
         cant = cant + 1;    
    end; 
 
    Procedure salirPuente() 
        cant = cant – 1; 
        signal(cola); 
    end; 
End Monitor;  
 
Process Auto [a:1..M] 
   Puente.entrarPuente(a); 
   “el auto cruza el puente” 
   Puente.salirPuente(a); 
End Process; 

```
    a) ¿El código funciona correctamente? Justifique su respuesta. 
    b) ¿Se  podría  simplificar  el  programa?  ¿Sin  monitor? ¿Menos procedimientos? ¿Sin variable condition? En caso afirmativo, rescriba el código. 
    c) ¿La  solución  original  respeta  el  orden  de  llegada de los vehículos? Si rescribió el código en el punto b), ¿esa solución respeta el orden de llegada?

### Respuestas 1

a) Si, el código funciona correctamente. Cada vez que un auto quiere cruzar el puente llama al proceso entrarPuente() que se encuentra en el monitor y en caso de que no haya ningún otro auto, cruzará el puente, en caso de que llegue un auto mientra el primero está cruzando, este se pondrá en una cola,la cual quedará en espera hasta que se mande el signal de que el auto anterior ya terminó de cruzar el puente.

b) Si, se podría simplificar. (quizá se pueda hacer sin monitor, realmente no se me ocurre una solución sin el monitor).

```c
    Monitor puente{
        Process cruzarPuente(){
            //auto cruzando el puente
        }
    }

    Process auto[id:1..M]{
        Puente.cruzarPuente();
    }
```

c)No, en ninguna de las dos soluciones planteadas se respeta el orden, en la primer solución ya que cuando un auto es despertado, pasa a competir con el resto de los autos para poder cruzar el puente, y en el caso de la segunda, los autos van a competir para poder utilizar el monitor.

---
2.  Existen N procesos que deben leer información de una base de datos, la cual es administrada por un motor que admite una cantidad limitada de consultas simultáneas. 
    a) Analice el problema y defina qué procesos, recursos y monitores serán necesarios/convenientes,  además  de  las  posibles  sincronizaciones  requeridas  para resolver el problema. 
    b) Implemente el acceso a la base por parte de los procesos, sabiendo que el motor de base de datos puede atender a lo sumo 5 consultas de lectura simultáneas. 
 
### Respuestas 2

a) en este caso lo que se debe tener en cuenta es la entrada a la base de datos para leer información, así que alcanza con un monitor que represente la entrada la base de datos.

b)
```c
    Monitor BaseDatos{
        int consulta = 0;
        cond cv;

        Process pasar(){
            while(consulta == 5){
                wait(cv);
            }
            consulta++;
        }

        Process salir(){
            consulta--;
            signal(cv);
        }
    }

    Process proceso[p:1..N]{
        BaseDatos.pasar();
        //leer la base de datos
        BaseDatos.salir();
    }
```

---
3.  Existen N personas que deben fotocopiar un documento. La fotocopiadora sólo puede ser usada  por  una  persona  a  la  vez.  Analice  el  problema  y  defina  qué  procesos,  recursos  y monitores serán necesarios/convenientes, además de las posibles sincronizaciones requeridas para resolver el problema. Luego, resuelva considerando las siguientes situaciones: 
    a) Implemente  una  solución  suponiendo  no  importa el  orden  de  uso.  Existe  una  función Fotocopiar() que simula el uso de la fotocopiadora.  
    b) Modifique la solución de (a) para el caso en que se deba respetar el orden de llegada. 
    c) Modifique la solución de (b) para el caso en que se deba dar prioridad de acuerdo con la edad de cada persona (cuando la fotocopiadora está libre la debe usar la persona de mayor edad entre las que estén esperando para usarla). 
    d) Modifique la solución de (a) para el caso en que se deba respetar estrictamente el orden dado por el identificador del proceso (la persona X no puede usar la fotocopiadora hasta que no haya terminado de usarla la persona X-1). 
    e) Modifique la solución de (b) para el caso en que además haya un Empleado que le indica a cada persona cuando debe usar la fotocopiadora. 
    f) Modificar la solución (e) para el caso en que sean 10 fotocopiadoras. El empleado le indica a la persona cuál fotocopiadora usar y cuándo hacerlo.

### Respuestas 3

a)
```c
    Monitor Fotocopiadora{
        Process fotocopiar(documento){
            //fotocopiar documento           
        }
    }

    Process persona[id:1..N]{
        Fotocopiadora.fotocopiar(documento);
    }
```

b)
```c
    Monitor Fotocopiadora{
        bool libre = true;
        cond cola;
        int esperando = 0;

        Process usar(){
            if (not libre){
                esperando++;
                wait(cola);
            }
            else{
                libre = false;
            }
        }

        Process dejar(){
            if (esperando > 0){
                esperando--;
                signal(cola);
            }
            else{
                libre = true;
            }
        }
    }

    Process persona[id:1..N]{
        Fotocopiadora.usar();
        //imprimiendo documento
        Fotocopiadora.dejar();
    }
```
c)
```c
    Monitor Fotocopiadora{
        bool libre = true; cond cola[N];
        int idAux, esperando = 0;
        orderQueue q;

        Process usar(idP,edad){
            if(not libre){
                insertarOrdenado(q, idP, edad);
                esperando++;
                wait(cola[idP]);
            }
            else{
                libre = false;
            }
        }
        Process dejar(){
            if(esperando > 0){
                esperando--;
                sacar(q,idAux);
                signal(cola[idP]);
            }
            else{
                libre=true;
            }
        }
    }

    Process persona[id:1..N]{
        int edad;
        Fotocopiadora.usar(id, edad);
        fotocopiar(documento);
        Fotocopiadora.dejar()
    }
```
d)
```c
    Monitor Fotocopiadora{
        int proxmo = 0;
        int cv[n];

        Process usar(idP: in int){
            if(idP != proximo){
                wait(cv[idP]);
            }
        }

        Process dejar(){
            proximo++;
            signal(cv[proximo]);
        }
    }

    Process persona[id:1..N]{
        Fotocopiadora.usar(id);
        fotocopiar(documento);
        Fotocopiadora.dejar();
    }
```

e)
```c
    Monitor Fotocopiadora{
        int esperando = 0;
        cond empleado;
        cond persona;
        cond fin;

        Process usar(){
            signl(empleado);
            esperando++;
            wait(persona);
        }

        Process dejar(){
            signal(fin);
        }

        Process asignar(){
            if(esperando == 0){
                wait(empleado);
            }
            esperando--;
            signal(persona);
            wait(fin);
        }
    }

    Process empleado{
        int i;
        for i = 1..N{
            Fotocopiadora.asignar();
        }
    }

    Process persona[id:1..N]{
        Fotocopiadora.usar();
        fotocopiar(documento);
        Fotocopiadora.dejar();
    }
    
```
f) Mismo que e) pero ahora hay 10 fotocopiadoras, el empleado indica cual usar.
```c
    Monitor Fotocopiadora{
        queue cola;
        queue fotocopiadoras = {1..10};
        cond empleado;
        cond persona[n] = ([n] 0);
        cond fotocopiadora;
        int asignada[n] = ([n] 0);

        Process usar(fotocopAsign: out int, idP: in int){
            signal(empleado);
            cola.push(idP);
            wait(persona[idP]);
            fotocopAsign = asignada[idP];
        }

        Process dejar(fotocopAsign: in int){
            fotocopiadoras.push(fotocopAsign)
            signal(fotocopiadora);
        }

        Process asignar(){
            if(cola.isEmpty()){
                wait(empleado);
            }
            idAux = cola.pop();
            if(fotocopiadoras.isEmpty()){
                wait(fotocopiadora);
            }
            asignada[idAux]  = fotocopiadoras.pop();
            signal(persona[idAux]);
        }
    }

    Process empleado(){
        int i;
        for i = 1..N{
            Fotocopiadora.asignar();
        }
    }

    Process persona[id:1..N]{
        Fotocopiadora.usar(fotocopAsign,id);
        fotocopiar(documento);
        Fotocopiadora.dejar();
    }
```

---
4.  Existen  N  vehículos  que  deben  pasar  por  un  puente  de  acuerdo  con  el  orden  de  llegada.  Considere que el puente no soporta más de 50000kg y que cada vehículo cuenta con su propio peso (ningún vehículo supera el peso soportado por el puente).  

```c
    Monitor Puente{
        int acumuladorPeso = 0;
        cond vehiculo;
        bool libre = true;
        cond pesoAdecuado;
        int pesoMaximo = 50000;

        Process pasar(peso){
            if (not libre){
                esperando++;
                wait(vehiculo);
            }
            else{
                libre = false;
            }
            while(acumulador + peso > pesoMaximo){
                wait(pesoAdecuado);
            }
            acumulador = acumulador + peso;
            if(esperando > 0){
                esperando--;
                signal(vehiculo);
            }
            else{
                libre = true;
            }
        }

        Process salir(peso){
            acumulador = acumulador - peso;
            signal(pesoAdecuado);
        }
    }

    Process vehiculo[id:1..N]{
        Puente.pasar(peso);
        //pasando el puente
        Puente.salir(peso);
    }
```

---
5.  En un corralón de materiales se deben atender a N clientes de acuerdo con el orden de llegada. Cuando  un  cliente  es  llamado  para  ser  atendido,  entrega  una  lista  con  los  productos  que comprará, y espera a que alguno de los empleados le entregue el comprobante de la compra realizada. 
    a) Resuelva considerando que el corralón tiene un único empleado. 
    b) Resuelva considerando que el corralón tiene E empleados (E > 1). 

a)
```c
    Monitor Corralon{

        int esperando = 0;
        cond recibioComprobante;
        cond empleado;
        cond cliente;
        cond datos;
        cond atencion;
        text listaCliente;
        texxt comprobanteEmpleado;

        Process llegada(lista: in text, comprobante: out text){
            signal(empleado);
            esperando++;
            wait(cliente);
            listaCliente = lista;
            signal(datos);
            wait(atencion);
            comprobante = comprobanteEmpleado;
            esperando--;
            signal(recibioComprobante);

        }

        Process obtenerLista(lista: out text){
            if (esperando == 0){
                wait(empleado);
            }
            signal(cliente);
            wait(datos);
            lista = listaCliente;
        }

        Process dejarComprobante(comprobante: in text){
            comprobanteEmpleado = comprobante;
            signal(atencion);
            wait(recibioComprobante);
        }
    }

    Process empleado{
        int j;

        for j = 1..C{
            Corralon.obtenerLista(lista);
            generarComprobante();
            Corralon.dejarComprobante(comprobante);
        }
    }

    Process cliente[id:1..C]{
        Corralon.llegada(lista,comprobante);
    }
```

b)
```c
    Monitor Corralon{
        queue empleadoLibre;
        cond cliente;
        int clienteEsperando = 0;
        int cantEmpleLibres = 0;

        Process llegada(idE: out int){
            if(cantEmpleLibres == 0){
                clienteEsperando++;
                wait(cliente);
            }
            else{
                cantEmpleLibres--;
                idE = empleadoLibre.pop();
            }
        }
        
        Process proximo(idE: in int){
            empleadoLibre.push(idE);
            if(clienteEsperando > 0){
                clienteEsperando--;
                signal(cliente);
            }
            else{
                cantEmpleLibres++;
            }
        }   
    }

    Monitor Escritorio[id:1..E]{
        text listaCliente;
        text comprobanteEmpleado;
        bool hayDatos = false;
        cond datos;
        cond atencionEmpleado;

        Process obtenerLista(lista: out text){
            if(not hayDatos){
                wait(datos);
            }
            lista = listaCliente;
        }

        Process dejarComprobante(comrpobante: in text){
            comprobanteEmpleado = comprobante;
            signal(atencionEmpleado);
            wait(datos);
            hayDatos = false;
        }

        Process atencion(lista: in text, comp: out text){
            listaCliente = lista;
            hayDatos = true;
            signal(datos);
            wait(atencionEmpleado);
            comp = comprobanteEmpleado;
            signal(datos);
        }
    }

    Process empleado[idE:1..E]{
        int j;

        for j = 1..C{
            Corralon.proximo(idE);
            Escritorio[idE].obtenerLista(lista);
            generarComprobante(lista);
            Escritorio[idE].dejarComprobante(comprobante);
        }
    }

    Process cliente[id:1..C]{
        Corralon.llegada(idE);
        Escritorio[idE].atencion(lista, comprobante);
    }
```

--- 
6.  Existe  una  comisión  de  50  alumnos  que  deben  realizar  tareas  de  a  pares,  las  cuales  son corregidas por un JTP. Cuando los alumnos llegan, forman una fila. Una vez que están todos en fila, el JTP les asigna un número de grupo a cada uno. Para ello, suponga que existe una función Asignarnrogrupo() que retorna un número “aleatorio” del 1 al 25. Cuando un alumno ha recibido su número de grupo, comienza a realizar su tarea. Al terminarla, el alumno le avisa al JTP y espera por su nota. Cuando los dos alumnos del grupo completaron la tarea, el JTP les asigna un puntaje (el primer grupo en terminar tendrá como nota 25, el segundo 24, y así sucesivamente hasta el último que tendrá nota 1). 
*Nota: el JTP no guarda el número de grupo que le asigna a cada alumno.*

```c
    Monitor Tarea{
        int esperaNro[50] = ([50] 0);
        int cantidadAlumnos = 0;
        cond profesor;

        Process hacerFila(idA: in int){
            cantidadAlumnos++;
            fila.push(idA);
            if(cantidadAlumno == 50){
                signal(profesor);
            }
        }

        Process esperarAlumno(){
            if(cantidadAlumnos < 50){
                wait(profesor);
            }
        }

        Process recibirNumero(id: in int, nro: out int){
            wait(esperaNro[id]);
            nro = nroAsignado[id];
        }

        Process asignarTarea(nroGrupo){
            idAux = fila.pop();
            nroAsignado[idAux] = nro;
            signal(esperaNro[idAux]);
        }

        Process recibirTarea(nroGrupo: out int){
            if(finalizadas.isEmpty()){
                wait(profesor);
            }else{
                nroGrupo = finalizadas.pop();
            }
        }

        Process corregirTarea(nroGrupo: in int, nota: in int){
            notaTarea[nroGrupo] = nota;
            signal_all(notaLista[nroGrupo]);
        }

        Process recibirNota(nGrupo: in int,nota: out int){
            finalizadas.push(nGrupo);
            wait(notaLista[nGrupo]);
            nota = notaTarea[nGrupo];
        }
    }

    Process JTP{
        int nota = 25;
        int nroGrupo;
        int contadorTareas[25] = ([25] 0);
        Tarea.esperarAlumno();
        for i = 1..50{
            nroGrupo = asignarnrogrupo();
            Tarea.asignarTarea(nroGrupo);
        }

        for i = 1..50{
            Tarea.recibirTarea(nroGrupo);
            contadorTareas[nroGrupo]++;
            if (contadoTareas[nroGrupo] == 2){
                Tarea.corregirTarea(nroGrupo,nota);
                nota--;
            }

        }
    }

    Process alumno[id:1..50]{
        Tarea.hacerFila(id);
        Tarea.recibirNro(id,tarea);
        //resolver la tarea
        Tarea.recibirNota(nGrupo, nota);
    }

```

---
7.  En un entrenamiento de fútbol hay 20 jugadores que forman 4 equipos (cada jugador conoce el equipo al cual pertenece llamando a la función DarEquipo()). Cuando un equipo está listo (han llegado los 5 jugadores que lo componen), debe enfrentarse a otro equipo que también esté listo (los dos primeros equipos en juntarse juegan en la cancha 1, y los otros dos equipos juegan en la cancha 2). Una vez que el equipo conoce la cancha en la que juega, sus jugadores se dirigen a ella. Cuando los 10 jugadores del partido llegaron a la cancha comienza el partido, juegan  durante  50  minutos,  y  al  terminar  todos  los  jugadores  del  partido  se  retiran  (no  es necesario que se esperen para salir). 

```c
    Process jugador[id:1..20]{
        int nroEquipo; int nroCancha;

        Jugar.elegirEquipo(nroEquipo);
        Equipo[nroEquipo].listo(nroCancha);
        Cancha[nroCancha].llegada();
    }

    Process Partido[id:1..2]{
        Cancha[id].iniciarPartido();
        //se juegan los 50 minutos de partido
        Cancha[id].terminarPartido();
    }

    Monitor Jugar{
        Process elegirEquipo(nroEquipo: out int){
            nroEquipo = DarEquipo();
        }
    }

    Monitor Equipo[id:1..4]{
        int cantidadJugadores = 0;
        cond esperandoJugadores;
        int canchaAsignada;

        Process listo(idCancha: out int){
            cantidadJugadores++;
            if(cantidadJugadores < 5){
                wait(esperandoJugadores);
            }else{
                Administrador.asignarCancha(canchaAsignada);
                signal_all(esperandoJugadores);
            }
            idCancha = canchaAsignada;
        }
    }

    Monitor Administrador{
        int equiposArmados = 0;

        Process asignarCancha(nroCancha: out int){
            equiposArmados++;
            if (equiposArmados < 2){
                nroCancha = 1;
            }else{
                nroCancha = 2;
            }
        }
    }

    Monitor Cancha[id:1..2]{
        int cantidad = 0;
        cond espera;
        cond inicio;

        Process llegada(){
            cantidad++;
            if (cantidad == 10){
                signal(inicio);
            }else{
                wait(espera);
            }
        }

        Process iniciar(){
            if(cantidad < 10){
                wait(inicio);
            }
        }

        Process terminar(){
            signal_all(espera);
        }
    }

```

---
8.  Se  debe  simular  una  maratón  con  C corredores  donde  en  la  llegada  hay  UNA  máquina expendedoras de agua con capacidad para 20 botellas. Además, existe un repositor encargado de reponer las botellas de la máquina. Cuando los C corredores han llegado al inicio comienza la carrera. Cuando un corredor termina la carrera se dirigen a la máquina expendedora, espera su turno (respetando el orden de llegada), saca una botella y se retira. Si encuentra la máquina sin  botellas,  le  avisa  al  repositor  para  que  cargue  nuevamente  la  máquina  con  20  botellas; espera a que se haga la recarga; saca una botella y se retira.  Nota: mientras se reponen las botellas se debe permitir que otros corredores se encolen.

```c
    Process corredor[id:1..C]{
        Carrera.listo();
        Carrera.largada();
        //corre la carrera
        Carrera.llegadaAMaquina();
        Maquina.usar();
        Carrera.dejarMaquina();
    }

    Process repositor{
        while(true){
            Maquina.reponerBotellas();
        }
    }

    Monitor Carrera{
        cond largaCorredor;
        int cantCorredores = 0;
        bool libre = true;

        Process listo(){
            cantCorredores++;
            if(cantCorredores == C){
                signal_all(largaCorredor);
            }
        }

        Process largada(){
            if(canntCorredores < C){
                wait(largaCorredor);
            }
        }

        Process llegadaAMaquina(){
            if(not libre){
                esperando++;
                wait(fila);
            }else{
                libre = false;
            }
        }

        Process dejarMaquina(){
            if (esperando > 0){
                espera--;
                signal(fila);
            }else{
                libre = true;
            }
        }
    }

    Monitor Maquina{    
        cond reponedor;
        cond corredor;
        cond esperandoBotella

        Process usar(){
            if (cantBotellas == 0){
                signal(reponedor);
                wait(esperandoBotella);
            }else{ //creo que el else no va, después lo chequeo.
                cantBotellas--;
            }
        }

        Process reponerBotellas(){
            if (cantBotellas > 0){
                wait(reponedor);
            }else{
                cantBotellas = 20;
                signal(esperandoBotella);
            }
        }
    }
```