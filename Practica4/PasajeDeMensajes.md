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

--- 
 
2.  Se  desea  modelar  el  funcionamiento  de  un  banco  en  el  cual  existen  5  cajas  para  realizar pagos.  Existen  P  clientes que  desean  hacer  un  pago.  Para  esto,  cada  una  selecciona  la  caja donde hay menos personas esperando; una vez seleccionada, espera a ser atendido. En cada caja, los clientes son atendidos por orden de llegada por los cajeros. Luego del pago, se les entrega un comprobante. Nota: maximizando la concurrencia.

3.  Se  debe  modelar  el  funcionamiento  de  una  casa  de  comida  rápida,  en  la  cual  trabajan  2 cocineros  y  3  vendedores,  y  que  debe  atender  a  C  clientes.  El  modelado  debe  considerar que: 
- Cada cliente realiza un pedido y luego espera a que se lo entreguen. 
- Los pedidos que hacen los clientes son tomados por cualquiera de los vendedores y se lo pasan a los cocineros para que realicen el plato. Cuando no hay pedidos para atender, los vendedores aprovechan para reponer un pack de bebidas de la heladera (tardan entre 1 y 3 minutos para hacer esto). 
- Repetidamente cada cocinero toma un pedido pendiente dejado por los vendedores, lo cocina y se lo entrega directamente al cliente correspondiente. 
*Nota: maximizar la concurrencia.* 
 
4.  Simular  la  atención  en  un  locutorio  con  10  cabinas  telefónicas,  el  cual  tiene  un  empleado que se encarga de atender a N clientes. Al llegar, cada cliente espera hasta que el empleado le  indique  a  qué  cabina  ir,  la  usa  y  luego  se  dirige  al  empleado  para  pagarle.  El  empleado atiende a los clientes en el orden en que hacen los pedidos, pero siempre dando prioridad a los  que  terminaron  de  usar  la  cabina.  A  cada  cliente  se  le  entrega  un  ticket  factura.  Nota: maximizar la concurrencia; suponga que hay una función  Cobrar() llamada por el empleado que simula que el empleado le cobra al cliente. 
 
5.  Resolver la administración de las impresoras de una oficina. Hay 3 impresoras, N usuarios y 1  director.  Los  usuarios  y  el  director  están  continuamente  trabajando  y  cada  tanto  envían documentos  a  imprimir.  Cada  impresora,  cuando  está  libre,  toma  un  documento  y  lo imprime,  de  acuerdo  con  el  orden  de  llegada,  pero  siempre  dando  prioridad  a  los  pedidos del  director.  Nota:  los  usuarios  y  el  director  no  deben  esperar  a  que  se  imprima  el documento.

## PMS (Pasaje de Mensjes Sincrónicos)

1.  Suponga  que  existe  un  antivirus  distribuido que  se  compone  de  R  procesos  robots Examinadores y 1 proceso Analizador. Los procesos Examinadores están buscando continuamente  posibles  sitios  web  infectados;  cada  vez  que  encuentran  uno  avisan  la dirección y luego continúan buscando. El proceso Analizador se encarga de hacer todas las pruebas necesarias con cada uno de los sitios encontrados por los robots para determinar si están o no infectados.  
    a) Analice  el  problema  y  defina  qué  procesos,  recursos  y  comunicaciones  serán necesarios/convenientes para resolver el problema. 
    b) Implemente una solución con PMS.
2.  En un laboratorio de genética veterinaria hay 3 empleados. El primero de ellos continuamente prepara las muestras de ADN; cada vez que termina, se la envía al segundo empleado  y  vuelve  a  su  trabajo.  El  segundo  empleado  toma  cada  muestra  de  ADN preparada,  arma  el  set  de  análisis  que  se  deben  realizar  con  ella  y  espera  el  resultado  para archivarlo.  Por  último,  el  tercer  empleado  se  encarga  de  realizar  el  análisis  y  devolverle  el resultado al segundo empleado.  
 
3.  En  un  examen  final  hay  N  alumnos  y  P  profesores.  Cada  alumno  resuelve  su  examen,  lo entrega  y  espera  a  que  alguno  de  los  profesores  lo  corrija  y  le  indique  la  nota.  Los profesores corrigen los exámenes respetando el orden en que los alumnos van entregando.  
    a) Considerando que P=1. 
    b) Considerando que P>1. 
    c) Ídem  b)  pero  considerando  que  los  alumnos  no  comienzan  a  realizar  su  examen  hasta que todos hayan llegado al aula. 
*Nota: maximizar la concurrencia y no generar demora innecesaria.*
 
4.  En  una  exposición  aeronáutica  hay  un  simulador  de  vuelo  (que  debe  ser  usado  con exclusión  mutua)  y  un  empleado  encargado  de  administrar  su  uso.  Hay  P  personas  que esperan  a  que  el  empleado  lo  deje  acceder  al  simulador,  lo  usa  por  un  rato  y  se  retira.  El empleado  deja  usar  el simulador  a  las  personas  respetando  el  orden  de  llegada.  Nota: cada persona usa sólo una vez el simulador.   
 
5.  En un estadio de fútbol hay una máquina expendedora de gaseosas que debe ser usada por E Espectadores de acuerdo al orden de llegada. Cuando el espectador accede a la máquina en su turno usa la máquina y luego se retira para dejar al siguiente.  Nota: cada Espectador una sólo una vez la máquina.
