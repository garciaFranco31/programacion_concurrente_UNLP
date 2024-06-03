# PRÁCTICA 5 - RENDEZVOUS

1.  Se requiere modelar un puente de un único sentido que soporta hasta 5 unidades de peso. El peso de los vehículos depende del tipo: cada auto pesa 1 unidad, cada camioneta pesa 2 unidades  y  cada  camión  3  unidades.  Suponga  que  hay  una  cantidad  innumerable  de vehículos  (A  autos,  B  camionetas  y  C  camiones).  Analice  el  problema  y  defina  qué  tareas, recursos y sincronizaciones serán necesarios/convenientes para resolver el problema. 
    a. Realice la solución suponiendo que todos los vehículos tienen la misma prioridad. 
    b. Modifique la solución para que tengan mayor prioridad los camiones que el resto de los vehículos.

--- 
2.  Se quiere modelar el funcionamiento de un banco, al cual llegan clientes que deben realizar un pago y retirar un comprobante. Existe un único empleado en el banco, el cual atiende de acuerdo  con  el  orden  de  llegada.  Los  clientes  llegan  y  si  esperan  más  de  10  minutos  se retiran sin realizar el pago. 

```javascript
Procedure Banco is
    Task empleado is
        entry llegada(comprobante: OUT string);
    end empleado;

    Task type cliente;
    arrClientes: array(1..N) of cliente;

    Task body empleado is
    begin
        loop
            accept llegada(comprobante: OUT string);
                comprobante = generarComprobante();
            end llegada;
        end loop;
    end empleado;
    
    Task body cliente is
        miComprobante: string;
    begin
        select
            empleado.llegada(miComprobante);
        or delay 600
            null;
        end select;
    end cliente;
begin
    null;
end Banco;
```

---
3.  Se  dispone  de  un  sistema  compuesto  por  1  central  y  2  procesos  periféricos,  que  se comunican continuamente. Se requiere modelar su funcionamiento considerando las siguientes condiciones: 
    - La  central  siempre  comienza  su  ejecución  tomando  una  señal  del  proceso  1;  luego toma  aleatoriamente  señales  de  cualquiera  de  los  dos  indefinidamente.  Al  recibir  una señal de proceso 2, recibe señales del mismo proceso durante 3 minutos. 
    - Los  procesos  periféricos  envían  señales  continuamente  a  la  central.  La  señal  del proceso  1  será  considerada  vieja  (se  deshecha)  si  en  2  minutos  no  fue  recibida.  Si  la señal del proceso 2 no puede ser recibida inmediatamente, entonces espera 1 minuto y vuelve a mandarla (no se deshecha).

```javascript
Procedure sistema is

    Task central is
        entry proceso1();
        entry proceso2();
        entry finTiempo();
    end central;

    Task contador is
        entry empezar();
    end contador;

    Task periferico1();
    Task periferico2();


    Task body central() is
        recibir: boolean;
    begin
        accept proceso1();
        loop
            select
                accept proceso1();
            or
                accept proceso2() do
                    recibir := false;
                    contador.empezar();
                    while (recibir = false) loop
                        select
                            when (finTiempo'count = 0) =>
                                accept proceso2();
                            or
                            accept finTiempo() do
                                recibir = true;
                            end finTiempo;
                        end select;
                    end loop;
                end proceso2;
            end select;
        end loop;
    end central;

    Task body contador is
    begin
        loop
            accept empezar();
            delay(120);
            central.finTiempo();
        end loop;
    end contador;

    Task body periferico1() is
        senial: string;
    begin
        loop
            senial = generarSenial();
            select
                central.proceso1(senial);
            or delay 120
                null;
        end loop;
    end periferico1;

    Task body periferico2() is
        senial: string;
        generar: boolean;
    begin
        loop
            if (generar) 
                senial := generarSenial();
                generar:= false;
            end if;
            select
                central.proceso2(senial);
                generar:= true;
            else
                delay(60);
        end loop;
    end periferico2;
begin
    null;
end sistema;

```


---
4.  En  una  clínica  existe  un  médico  de  guardia  que  recibe  continuamente  peticiones  de atención de las E  enfermeras que trabajan en su piso y de las  P  personas que llegan a la clínica para ser atendidos.  Cuando una persona necesita que la atiendan espera a lo sumo 5 minutos a que el médico lo haga, si pasado ese tiempo no lo hace, espera 10 minutos y vuelve a requerir la atención del médico. Si no es atendida tres veces, se enoja y se retira de la clínica. Cuando una enfermera requiere la atención del médico, si este no lo atiende inmediatamente le  hace  una  nota  y  se  la  deja  en  el  consultorio  para  que  esta  resuelva  su  pedido  en  el momento  que  pueda  (el  pedido  puede  ser  que  el  médico  le  firme  algún  papel).  Cuando  la petición  ha  sido  recibida  por  el  médico  o  la  nota  ha  sido  dejada  en  el  escritorio,  continúa trabajando y haciendo más peticiones. El médico atiende los pedidos dándole prioridad a los enfermos que llegan para ser atendidos. Cuando atiende un pedido, recibe la solicitud y la procesa durante un cierto tiempo. Cuando está libre aprovecha a procesar las notas dejadas por las enfermeras. 

```javascript
Procedure clinica

    Task medico is
        entry persona(solicitud: IN string, resultado: OUT string);
        entry enfermera(solicitud: IN string);
        entry consultorio(nota: IN string);
    end medico;

    Task escritorio is
        entry nota(n: IN string);
        entry mandarNota(nota: OUT string);
    end escritorio;

    Task administrador;

    Task type persona;
    arrPersona: array (1..P) of persona;
    Task type enfermera;
    arrEnfermera: array (1..E) of enfermera;

    Task body persona is
        terminar: boolean;
        contador: integer;
        solicitud, resultado: string;
    begin
        contador:= 0;//cuenta la cantidad de veces que reclamo ser atendida
        terminar:= false;//indica el fin, haya sido o no atendida
        while (terminar == false) loop
            select //se realiza la atención del médico
                medico.persona(solicitud, resultado);
                terminar:= true;
            or delay 300 //no se realiza la atención del médico, reclamar
                contador:= contador + 1;
                if (contador = 3) then
                    terminar:= true;
                else 
                    delay (600);
                end if;
            end select;
        end loop;
    end persona;

    Task body enfermera is
        solicitud, nota: string;
    begin
        loop
            trabajar();
            select
                medico.enfermera(solicitud);//el médico puede antenderla
            else
                escritorio.nota(nota);//el médico no puede atenderla
        end loop;
    end enfermera;

    Task body medico is
    begin
        loop
            select
                accept persona(solicitud: IN string, resultado: OUT string) do
                    resultado = antederEnfermo();
                end persona;
                or
                when (persona'count == 0) =>
                    accept enfermera(solicitud: IN string) do
                        procesarSolicitud(solicitud);
                    end enfermera;
                or
                when (persona'count == 0) and (enfermera'count == 0) =>
                    accept consultorio(nota: IN string) do
                        proceasarNota(nota);
                    end consultorio;
            end select;
        end loop;
    end medico;

    Task body administrador is
        ultimaNota: string
    begin
        loop
            escritorio.mandarNota(ultimaNota);
            medico.consultorio(ultimaNota);
        end loop;
    end administrador;

    Task body escritorio is
        notas: cola; //las notas que se van dejando en el escritorio
    begin
        loop
            select
                accept nota(n: IN string) do
                    notas.push(n);//encola la nota dejada por la enfermera
                end nota;
                or
                when (not notas.isEmpty()) =>
                    accept mandarNota(ultimaNota: OUT string) do
                        ultimaNota = notas.pop();//desencola la nota que se debe procesar
                    end mandarNota;
            end select;
        end loop;
    end escritorio;

begin
    null;
end clinica;

``` 

---
5.  En  un  sistema  para  acreditar  carreras  universitarias,  hay  UN  Servidor  que  atiende  pedidos de U Usuarios de a uno a la vez y de acuerdo con el orden en que se hacen los pedidos. Cada  usuario  trabaja  en  el  documento  a  presentar,  y  luego  lo  envía  al  servidor;  espera  la respuesta de este que le indica si está todo bien o hay algún error. Mientras haya algún error, vuelve a trabajar con el documento y a enviarlo al servidor. Cuando el servidor le responde que está todo bien, el usuario se retira. Cuando un usuario envía un pedido espera a lo sumo 2 minutos a que sea recibido por el servidor, pasado ese tiempo espera un minuto y vuelve a intentarlo (usando el mismo documento). 
 
```javascript
Procedure sistema is

    Task servidor is
        entry documento(doc: IN string, valido:OUT boolean);//trabaja y analiza únicamente el documento, no al usuario
    end servidor;

    Task type usuario;
    arrUsuarios: array (1..U) of usuario;

    Task body usuarios is
        documento: string;
        valido, trabajar, diferente: boolean;
    begin
        trabajar:= true;
        diferente:= true;
        while(trabajar) loop
            if (diferente) then
                trabajarDocumento(documento);
                diferente:= false;
            end if;
            select
                servidor.documento(documento,valido);
                if (valido) then
                    trabajar := false;
                else
                    diferente := true;
                end if;
            or delay 120 //espera a que sea recibido por el server
                delay (60);//si no lo recibió el server, espera y lo reenvía (el mismo archivo)
            end select;
        end loop;
    end usuarios;   

    Task body servidor is
        valido: boolean;
        documento: string;
    begin
        loop
            accept documento(documento: IN string, valido: OUT boolean) do
                valido = controlarDocumento(documento);
            end accept;
        end loop;
    end servidor;

begin
    null;
end sistema;

```
---
6.  En una playa hay 5 equipos de 4 personas cada uno (en total son 20 personas donde cada una  conoce  previamente  a  que  equipo  pertenece).  Cuando  las  personas  van  llegando esperan  con  los  de  su  equipo  hasta  que  el  mismo  esté  completo  (hayan  llegado  los  4 integrantes), a partir de ese momento el equipo comienza a jugar. El juego consiste en que cada integrante del grupo junta 15 monedas de a una en una playa (las monedas pueden ser de  1,  2  o  5  pesos)  y  se  suman  los  montos  de  las  60  monedas  conseguidas  en  el  grupo.  Al finalizar  cada  persona  debe  conocer  el  grupo  que  más  dinero  junto.  
*Nota:  maximizar  la concurrencia.  Suponga  que  para  simular  la  búsqueda  de  una  moneda  por  parte  de  una persona existe una función Moneda() que retorna el valor de la moneda encontrada.* 

```javascript
Procedure juego
    Task type persona;
    arrPersonas: array (1..20) of persona;

    Task type administrador is
        entry equipo(numero: IN integer);
        entry llegada();
        entry espera();
        entry total(total: IN integer);
    end administrador;
    arrAdmins: array(1..5) of administrador;

    Task type coordinador is
        entry totalEquipo(totalE: IN integer, nroE: IN integer);
        entry ganador(equipoGanador: OUT integer);
    end coordinador;

    Task body persona is
        miEquipo, mono, ganador: integer;
    begin
        monto := 0;
        adminstrador(miEquipo).llegada();
        administrador(miEquipo).espera();
        for i:= 1 to 15 loop
            monto:= monto + moneda();
        end loop;
        administrador(miEquipo).total(monto);
        coordinador.ganador(ganador);
    end persona;

    Task body administrador is
        contador, equipo: integer;
    begin
        contador:= 0;
        accept equipo(numero: IN integer) do
            equipo := numero;
        end equipo;

        for i:= 1 to 4 loop
            accept llegada();
        end loop;

        for i:= 1 to 4 loop
            accept espera();
        end loop;   

        for i:=1 to 4 loop
            accept total(total:IN integer) do
                contador:= contador + total;
            end accept;
        end loop;

        coordinador.totalEqipo(contador,equipo);
    end administrador;

    Task body coordinador is
        totalEquipo, nroEquipo, max, ganador: integer;
    begin
        max := -1;
        ganador := -1;
        for i:= 1 to 5 loop
            accept totalEquipo(totalEquipo: IN integer, nroEquipo: IN integer) do
                if (totalEquipo > max) then
                    max := totalEquipo;
                    ganador:= nroEquipo;
                end if;
            end accept;
        end loop;

        for i:= 1 to 20 loop
            accept ganador(equipoGanador: OUT integer) do
                equipoGanador := ganador
            end ganador;
        end loop;

    end coordinador;

begin
    for i:= 1 to 5 loop
        arrayAdmin(i).equipo(i);
    end loop;
end juego;

```

---
7.  Hay un sistema de reconocimiento de huellas dactilares de la policía que tiene 8 Servidores para realizar el reconocimiento, cada uno de ellos trabajando con una Base de Datos propia; a su vez hay un Especialista que utiliza indefinidamente. El sistema funciona de la siguiente manera: el Especialista toma una imagen de una huella (TEST) y se la envía a los servidores para que cada uno de ellos le devuelva el código y el valor de similitud de la huella que más se  asemeja  a  TEST  en  su  BD;  al  final  del  procesamiento,  el  especialista  debe  conocer  el código  de  la  huella  con  mayor  valor  de  similitud  entre  las  devueltas  por  los  8  servidores. Cuando  ha  terminado  de  procesar  una  huella  comienza  nuevamente  todo  el  ciclo.  
*Nota: suponga  que  existe  una  función  Buscar(test,  código,  valor)  que  utiliza  cada  Servidor  donde recibe  como  parámetro  de  entrada  la  huella  test,  y  devuelve  como  parámetros  de  salida  el código  y  el  valor  de  similitud  de  la  huella  más  parecida  a  test  en  la  BD  correspondiente. Maximizar la concurrencia y no generar demora innecesaria.* 

```javascript
Procedure reconocimiento

    Task type servidor;
    arrServidores: array (1..8) of servidor;

    Task especialista is
        entry tomarHuella(test OUT string);
        entry resultado(codigo: IN integer, valor: IN integer);
    end especialista;

    Task body especialista is
        huellaTest: string;
        codigo,max,valor,codigoMax: integer;
    begin
        loop
            max:= -1;
            codigoMax:= -1;
            huellaTest = obtenerHuella();

            for i:= 1 to 8 loop
                accept tomarHuella(test:OUT string) do
                    test := huellaTest;
                end tomarHuella;
            end loop;

            for i:= 1 to 8 loop
                accept resultado(codigo: IN integer, valor: IN integer);
                    if(valor > max) then
                        max:= valor;
                        codigoMax:= codigo;
                    end if;
                end resultado;
            end loop;
        end loop;
    end especialista;

    Task body servidor is
        test: string;
        codigo, valor: integer;
    begin
        loop
            especialista.tomarHuella(test);
            buscar(test, codigo, valor);//busca la huella en la BD
            especialista.resultado(codigo, valor)
        end loop;
    end servidor;

begin
    null;
end reconocimiento;

```

---
8.  Una  empresa  de  limpieza  se  encarga  de  recolectar  residuos  en  una  ciudad  por  medio  de  3 camiones.  Hay  P  personas  que  hacen  continuos  reclamos  hasta  que  uno  de  los  camiones pase por su casa. Cada persona hace un reclamo, espera a lo sumo 15 minutos a que llegue un camión y si no vuelve a hacer el reclamo y a esperar a lo sumo 15 minutos a que llegue un  camión  y  así  sucesivamente  hasta  que  el  camión  llegue  y  recolecte  los  residuos;  en  ese momento deja de hacer reclamos y se va. Cuando un camión está libre la empresa lo envía a la  casa  de  la  persona  que  más  reclamos  ha  hecho  sin  ser  atendido.
*Nota:  maximizar  la concurrencia.*

```javascript
Procedure recolectores
    Task type camion;
    arrCamiones: array (1..3) of camion;

    Task type persona is
        entry identificacion(num: IN integer);
        entry atender();
    end persona;
    arrPersonas: array (1..P) of persona;

    Task empresa is
        entry reclamo(idPersona: IN integer);
        entry enviarCamion(nroCamion: OUT integer);
    end empresa;

    Task body camion
        proxima: integer;
    begin
        loop
            empresa.enviarCamion(proxima);
            persona(proxima).atender();
        end loop;
    end camion;

    Task body empresa is
        arrayContador: array;
        espera:= boolean;
    begin
        espera:= false;
        loop
            select 
                accept reclamo(idPersona: IN integer) do
                    arrayContador(idPersona):= arrayContador(idPersona)+1;
                    espera:= true;
                end reclamo;
                or
                    when (espera) =>
                        accept enviarCamion(persona:OUT integer) do
                            persona:= max(arrayContador);
                            arrayContador(persona):=0;
                            espera:= false;
                        end camionLibre;
            end select;
        end loop;   
    end empresa;

    Task body persona is
        id: integer;
        atendido: boolean;
    begin
        atendido:= false;
        accept identificacion(num: IN integer) do
            id:= num;
        end identificacion;
        while (not atendido) loop
            empresa.reclamo(id);
            select
                accept atender();
                atendido:= true;
            or delay 900
                null;
            end select;
        end loop;
    end persona;
begin
    for i:=1..P loop
        persona(i).identificacion(i);
    end loop;
end recolectores;

```