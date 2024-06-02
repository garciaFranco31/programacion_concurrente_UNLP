# PRÁCTICA 4 - PASAJE DE MENSAJES

## PMA (Pasaje de Mensjes Asincrónicos)

1. Suponga  que  N  clientes  llegan  a  la  cola  de  un  banco  y  que  serán  atendidos  por  sus  empleados.  Analice  el  problema  y  defina  qué  procesos,  recursos  y  comunicaciones  serán necesarios/convenientes  para  resolver  el  problema.  Luego,  resuelva  considerando  las siguientes situaciones: 
    a. Existe un único empleado, el cual atiende por orden de llegada. 
    b. Ídem a) pero considerando que hay 2 empleados para atender, ¿qué debe modificarse en la solución anterior? 
    c. Ídem  b)  pero  considerando  que,  si  no  hay  clientes  para  atender,  los  empleados  realizan  tareas  administrativas  durante  15  minutos.  ¿Se  puede  resolver  sin  usar procesos adicionales? ¿Qué consecuencias implicaría?

a)
```c
chan esperando(int);

Process Clientes[id:0..N-1]{
    while(true){
        send esperando(id);
    }
}

Process Empleado(){
    int idC;

    while (true){
        receive esperando(idC);
        atender(idC);
    }
}

```

b)
```c
chan esperando(int);

Process Clientes[id:0..N-1]{
    while(true){
        send esperando(id);
    }
}

Process Empleados[id:0..1]{
    int idC;

    while (true){
        receive esperando(idC);
        atender(idC);
    }
}

```
```c
chan esperando(int); //el cliente se encola y espera a ser atendido
chan siguiente(int); //el empleado pide el siguiente cliente
chan atendiendo[2](int); //se tiene un canal privado para cada empleado

Process Clientes[id:0..N-1]{
    while(true){
        send esperando(id);
    }
}

Process Coordinador(){
    int idE;
    while (true){
        receive siguiente(idE)
        if (empty (esperando)){
            idC = -1;
        }else{
            receive esperando(idC);
        }
        send atendiendo[idE](idC);
    }
}

Process Empleados[id:0..1]{
    int idC;
    while(true){
        send siguiente(id);
        receive atendiendo[id](idC);
        if(idC <> -1){
            anteder(idC);
        }else{
            delay (900) //hace tareas administrativas por 15 minutos
        }
    }
}

```


--- 
 
2.  Se  desea  modelar  el  funcionamiento  de  un  banco  en  el  cual  existen  5  cajas  para  realizar pagos.  Existen  P  clientes que  desean  hacer  un  pago.  Para  esto,  cada  uno  selecciona  la  caja donde hay menos personas esperando; una vez seleccionada, espera a ser atendido. En cada caja, los clientes son atendidos por orden de llegada por los cajeros. Luego del pago, se les entrega un comprobante. Nota: maximizando la concurrencia.

```c
chan pedido[5](text,int);
chan comprobante[P](texto);//cada persona tiene su prop comprobante
chan buscarCaja(int);//se obtiene la caja con menos fila
chan obtenerCaja[P](int);//envia al cliente a la caja obtenida
chan liberarCaja(int);//el cliente libera la caja
chan hayPedido(bool);//se fija si hay algún pedido p/atender


Process Caja[id:0..4]{
    int idAux;
    text pago;
    text comprobante;
    while(true){
        receive pedido[id](pago,idAux);
        generarComprobante(pago, comprobante);
        send comprobante[idAux](comprobante);
    }
}

Process Cliente[id: 0..P-1]{
    int idCaja;
    text pago;
    text comprobante;

    send buscarCaja(id);
    send hayPedido(true);
    receive obtenerCaja[id](idCaja);
    send pedido[idCaja](pago, id);
    receive comprobante[id](comprobante);
    send liberarCaja(idCaja);
    send hayPedido(false); //en el gh de Agus aparece true?
}

Process Admin(){
    int cantEspera[5] = ([5] 0);
    int min;
    int idCliente, idCaja;
    bool pedido;

    while (true){
        receive hayPedido(pedido);
        if (not empty(buscarCaja) && empty(liberarCaja)){
            receive buscarCaja(idCliente);
            min = menorFila(cantEspera);
            cantEspera[min]++;
            send obtenerCaja[idCliente](min);
        }else{
            if (not empty (liberarCaja)){
                receive liberarCaja(idCaja);
                cantEspera[idCaja]--;
            }
        }
    }
}


```

---

3.  Se  debe  modelar  el  funcionamiento  de  una  casa  de  comida  rápida,  en  la  cual  trabajan  2 cocineros  y  3  vendedores,  y  que  debe  atender  a  C  clientes.  El  modelado  debe  considerar que: 
- Cada cliente realiza un pedido y luego espera a que se lo entreguen. 
- Los pedidos que hacen los clientes son tomados por cualquiera de los vendedores y se lo pasan a los cocineros para que realicen el plato. Cuando no hay pedidos para atender, los vendedores aprovechan para reponer un pack de bebidas de la heladera (tardan entre 1 y 3 minutos para hacer esto). 
- Repetidamente cada cocinero toma un pedido pendiente dejado por los vendedores, lo cocina y se lo entrega directamente al cliente correspondiente. 
*Nota: maximizar la concurrencia.* 

```c
    chan realizarPedido(text,int);
    chan obtenerPedido(int);
    chan obtenerPlato[C](int);
    chan retornarPedido[3](text,int);
    chan pedidoPendiente(text, int);

    Process Coordinador(){
        text pedido;
        int idVendedor;
        int idCliente;

        while(true){
            receive obtenerPedido(idVendedor);
            if (empty(realizarPedido)){
                idCliente = -1;
                pedido = "Vacio";
            }else{
                receive realizarPedido(pedido, idCliente);
            }
            send retornarPedido[idVendedor](pedido, idCliente);

        }

    }

    Process Cocinero[id:0..1]{
        text pedido;
        text plato;
        int idCliente;

        while(true){
            receive pedidoPendiente(pedido, idCliente);
            plato = cocinarPlato(pedido);
            send obtenerPlato[idCliente](plato);
        }
    }

    Process Vendedores[id:0..2]{
        texto pedido;
        int idCliente;

        while(true){
            send obtenerPedido(id);
            receive retornarPedido[id](pedido,idCliente);
            if (pedido != "Vacio"){
                send pedidoPendiente(pedido, idCliente);
            }else{
                delay(60,180);//reponer gaseosa 1-3 min
            }
        }

    }

    Process Clientes[id:0..C-1]{
        text pedido;
        text plato;

        send realizarPedido(pedido, id);
        receive obtenerPlato[id](plato);
    }

```

---
 
4.  Simular  la  atención  en  un  locutorio  con  10  cabinas  telefónicas,  el  cual  tiene  un  empleado que se encarga de atender a N clientes. Al llegar, cada cliente espera hasta que el empleado le  indique  a  qué  cabina  ir,  la  usa  y  luego  se  dirige  al  empleado  para  pagarle.  El  empleado atiende a los clientes en el orden en que hacen los pedidos, pero siempre dando prioridad a los  que  terminaron  de  usar  la  cabina.  A  cada  cliente  se  le  entrega  un  ticket  factura.  Nota: maximizar la concurrencia; suponga que hay una función  Cobrar() llamada por el empleado que simula que el empleado le cobra al cliente. 

```c

chan solicitarCabina(int);
chan obtenerCabina[N](int);
chan pagarEmpleado(int, int);
chan obtenerTicket[N](text);

Process Empleado(){
    bool cabinaOcupa[10] = ([10] false);
    int idCliente;
    int idCabina;
    text ticket;

    while (true){
        if (not empty (pagarEmpleado)){
            receive pagarEmpleado(idCliente,idCabina);
            cabinaOcupa[idCabina] = false;
            ticket = cobrar(idCliente);
            send obtenetTicket[idCliente](ticket);
        }else{
            if (not empty(solicitarCabina) && hayCabinaLibre(cabinaOcupa)){
                receive solicitarCabina(idCliente);
                idCabina = obtenerCabinaLibre(cabinaOcupa);
                cabinaOcupa[idCabina] = true;
                send obtenerCabina[idCliente](idCabina);
            }
        }
    }


}

Process Cliente[id:0..N-1]{
    int cabina;
    text ticket;

    send solicitarCabina(id);
    receive obtenerCabina[id](cabina);
    usarCabina(cabina);
    send pagarEmpleado(id, cabina);
    receive obtenerTicket[id](ticket);
}

```

--- 
5.  Resolver la administración de las impresoras de una oficina. Hay 3 impresoras, N usuarios y 1  director.  Los  usuarios  y  el  director  están  continuamente  trabajando  y  cada  tanto  envían documentos  a  imprimir.  Cada  impresora,  cuando  está  libre,  toma  un  documento  y  lo imprime,  de  acuerdo  con  el  orden  de  llegada,  pero  siempre  dando  prioridad  a  los  pedidos del  director.  Nota:  los  usuarios  y  el  director  no  deben  esperar  a  que  se  imprima  el documento.

```c

chan pedidoDirectori(textDir);
chan pedidoUsuario(textUsr);
chan hayPedido(bool);

Process Usuario[id:0..N-1]{
    text documento;

    while(true){
        documento = generarDocumento(documento);
        sen pedidoUsuario(documento);
        send hayPedido(true);
    }
}

Process Director{
    text documento;

    while(true){
        documento = generarDocumento(documento);
        send pedidoDirector(documento);
        sen hayPedido(true);
    }
}

Process Impresora[id:0..3]{
    text documento;
    bool hay;

    while(true){
        receive hayPedido(hay);

        if(not empty(pedidoDirector)){
            receive pedidoDirector(documento);
        }else{
            receive pedidoUsuario(documento);
        }
        imprimir(documento);
    }
}

```

---

## PMS (Pasaje de Mensjes Sincrónicos)

1.  Suponga  que  existe  un  antivirus  distribuido que  se  compone  de  R  procesos  robots Examinadores y 1 proceso Analizador. Los procesos Examinadores están buscando continuamente  posibles  sitios  web  infectados;  cada  vez  que  encuentran  uno  avisan  la dirección y luego continúan buscando. El proceso Analizador se encarga de hacer todas las pruebas necesarias con cada uno de los sitios encontrados por los robots para determinar si están o no infectados.  
    a) Analice  el  problema  y  defina  qué  procesos,  recursos  y  comunicaciones  serán necesarios/convenientes para resolver el problema. 
    b) Implemente una solución con PMS.

```c

Process Analizador{
    texto sitioWeb;

    while(true){
        Admin!pedido();
        Admin?aviso(sitioWeb);
        analizar(sitioWeb);
    }
}

Process Examinador[id:0..R-1]{
    text sitioWeb;

    while(true){
        sitioWeb = sitioInfectado();
        Admin!aviso(sitioWeb);
    }
}

Process Admin{
    cola avisos;
    text sitioWeb;
    text aviso;

    do Examinador[*]?aviso(sitioWeb) -> avisos.push(sitioWeb);
    [] not empty(avisos); Analizador?pedido() ->
                aviso = avisos.pop()
                Analizor!aviso(aviso);

    od
}

```


---
2.  En un laboratorio de genética veterinaria hay 3 empleados. El primero de ellos continuamente prepara las muestras de ADN; cada vez que termina, se la envía al segundo empleado  y  vuelve  a  su  trabajo.  El  segundo  empleado  toma  cada  muestra  de  ADN preparada,  arma  el  set  de  análisis  que  se  deben  realizar  con  ella  y  espera  el  resultado  para archivarlo.  Por  último,  el  tercer  empleado  se  encarga  de  realizar  el  análisis  y  devolverle  el resultado al segundo empleado.

```c
    Process Empleado1{
        text muestra;

        while(true){
            muestra = prepararMuestra(muestra);
            Admin!preparado(muestra);
        }
    }

    Process Empleado2{
        text muestra;
        text set;
        text analisis;

        while(true){
            Admin!pedido();
            Admin?obtenerMuestra();
            Empleado1?preparado(muestra);
            set = prepararSet(set);
            Empleado3!enviarSet(set);
            Empleado3?obtenerAnalisis(analisis);
            archivar(analisis);
        }
    }

    Process Empleado3{
        text set;
        text analisis;
        
        while(true){
            Empleado2?enviarSet(set);
            analisis = realizarAnalisis(analisis);
            Empleado2!obtenerAnalisis(analisis);
        }
    }

    Process Admin{
        cola muestras;
        text muestra;

        do Empleado1?obtenerMuestra(muestra) -> muestras.push(muestra);
        [] not empty(muestras); Empleado2?pedido() ->
                Empleado2!obtenerMuestra(muestas.pop());
    }
```

---
 
3.  En  un  examen  final  hay  N  alumnos  y  P  profesores.  Cada  alumno  resuelve  su  examen,  lo entrega  y  espera  a  que  alguno  de  los  profesores  lo  corrija  y  le  indique  la  nota.  Los profesores corrigen los exámenes respetando el orden en que los alumnos van entregando.  
    a) Considerando que P=1. 
    b) Considerando que P>1. 
    c) Ídem  b)  pero  considerando  que  los  alumnos  no  comienzan  a  realizar  su  examen  hasta que todos hayan llegado al aula. 
*Nota: maximizar la concurrencia y no generar demora innecesaria.*
 
4.  En  una  exposición  aeronáutica  hay  un  simulador  de  vuelo  (que  debe  ser  usado  con exclusión  mutua)  y  un  empleado  encargado  de  administrar  su  uso.  Hay  P  personas  que esperan  a  que  el  empleado  lo  deje  acceder  al  simulador,  lo  usa  por  un  rato  y  se  retira.  El empleado  deja  usar  el simulador  a  las  personas  respetando  el  orden  de  llegada.  Nota: cada persona usa sólo una vez el simulador.   
 
5.  En un estadio de fútbol hay una máquina expendedora de gaseosas que debe ser usada por E Espectadores de acuerdo al orden de llegada. Cuando el espectador accede a la máquina en su turno usa la máquina y luego se retira para dejar al siguiente.  Nota: cada Espectador una sólo una vez la máquina.
