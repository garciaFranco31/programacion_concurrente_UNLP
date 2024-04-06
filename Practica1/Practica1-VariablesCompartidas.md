# Práctica 1 – Variables compartidas

1.  Para el siguiente programa concurrente suponga que todas las variables están inicializadas en 
    0 antes de empezar. Indique cual/es de las siguientes opciones son verdaderas: 
        a) En algún caso el valor de x al terminar el programa es 56. 
        b) En algún caso el valor de x al terminar el programa es 22. 
        c) En algún caso el valor de x al terminar el programa es 23.
    ### Proceso 1
    ```pascal
    if (x = 0) then
        y:= 4*2;
        x:= y + 2;
    ```
    ### Proceso 2
    ```pascal
        if (x > 0) then
        x:= x + 1;
    ```
    ### Proceso 3
    ```pascal
        x:= (x*3) + (x*2) + 1;
    ```
    ![alt text](image.png)
## RESPUESTA
    a) Verdadero.
       Se realiza primero toda la ejcución del proceso 1, luego todo el proceso 2 y por último todo el proceso 3. 
    b) Verdadero. 
       3.1 1.1 1.2 1.3 1.4 1.5 3.2 3.3 3.4 3.5 3.6 3.7 2.1 2.2 2.3
    c) Verdadero. 
       3.1 - 1.1 - 1.2 - 1.3 - 1.4 - 1.5 - 1.6 - 2.1 - 2.2 - 2.3 - 3.2 - 3.3 - 3.4 - 3.5 - 3.6 - 3.7

2. Realice una solución concurrente de grano grueso (utilizando <> y/o <await B; S>) para el 
    siguiente problema. Dado un numero N verifique cuantas veces aparece ese número en un 
    arreglo de longitud M.  

## RESPUESTA
```c
    int numero = N; int total = 0; int arreglo[M] = ... 
    process contador[id: 0..M-1]{
        if (v[id] == numero){
            <total := total + 1;>
        }
    }
```

3. Dada la siguiente solución de grano grueso:  
    a) Indicar si el siguiente código funciona para resolver el problema de 
    Productor/Consumidor  con  un  buffer  de  tamaño  N.  En  caso  de  no  funcionar,  debe 
    hacer las modificaciones necesarias.
    b) Modificar el código para que funcione para C consumidores y P productores.

```c
    int cant = 0;         int pri_ocupada = 0;       int pri_vacia = 0;        int buffer[N];
    Process Productor::  
    { while (true) 
      { produce elemento 
         <await (cant < N); cant++> 
         buffer[pri_vacia] = elemento; 
         pri_vacia = (pri_vacia + 1) mod N; 
       } 
    } 

    Process Consumidor::  
    { while (true) 
      { <await (cant > 0); cant-- > 
         elemento = buffer[pri_ocupada]; 
         pri_ocupada = (pri_ocupada + 1) mod N; 
         consume elemento 
       } 
    }
```

## RESPUESTA
a)
```c
    int cant = 0;   int pri = 0;    int pri_ocupada = 0;    int pri_vacia = 0;  int buffer[N];
    Process Productor::  
    { while (true) 
      { //produce elemento 
         <await (cant < N); cant++ 
         buffer[pri] = elemento; >
         pri = (pri + 1) mod N; 
       } 
    } 

    Process Consumidor::  
    { while (true) 
      { <await (cant > 0); cant--  
         elemento = buffer[pri]; >
         pri = (pri + 1) mod N; 
         //consume elemento 
       } 
    }
```
Se crea una nueva variable "pri", la cual es compartida por ambos procesos y representa la posición del elemnto que se guardará/consumirá. 
¿Se debería dejar las variables pri_ocupada y pri_vacia? ¿Dónde se actualiza la variable pri?

b)
```c
    int cant = 0;   int pri = 0;    int pri_ocupada = 0;    int pri_vacia = 0;  int buffer[N];
    Process Productor[id: 0..P-1]{ 
        while (true){ 
        //produce elemento 
         <await (cant < N); cant++ 
         buffer[pri] = elemento; 
         pri = (pri + 1) mod N; >
       } 
    } 

    Process Consumidor[id: 0..C-1]  { 
        while (true) { 
        <await (cant > 0); cant--  
        elemento = buffer[pri];
        pri = (pri + 1) mod N; >
        //consume elemento 
       } 
    }
```

4. Realice una solución concurrente de grano grueso (utilizando <> y/o <await B; S>) para el 
    siguiente problema. Un sistema operativo mantiene 5 instancias de un recurso almacenadas 
    en una cola, cuando un proceso necesita usar una instancia del recurso la saca de la cola, la 
    usa y cuando termina de usarla la vuelve a depositar.  

process recurso id 0..4 => es una queue

process consumidor{
    //sacar de la cola la instancia i
    //usar instancia
    //depositar en cola
}
```c
    ColaRecurso queue [5];

    process consumidor[id: 0..4]{
        Recurso recurso
        while(true){
            <await (cant < 5);
            cant++;
            recurso = queue.pop();>
            //usa el recurso
            <queue.push();
            cant--;>
        }
    }
```
5.  En  cada  ítem  debe  realizar  una  solución  concurrente  de  grano  grueso  (utilizando  <>  y/o <await B; S>) para el siguiente problema,teniendo en cuenta las condiciones indicadas en el item. Existen N personas que deben imprimir un trabajo cada una.  
    
    <span style="color:purple">¿esta bien el id inicializado en 0?</span>

    a) Implemente  una  solución  suponiendo  que  existe  una  única  impresora  compartida  por todas las personas, y las mismas la deben usar de a una persona a la vez, sin importar el orden. Existe una función Imprimir(documento) llamada por la persona que simula el uso de la impresora. Sólo se deben usar los procesos que representan a las Personas. 

    //proceso impresora
    //bool imprimiendo
    //proceso personas [id: 1..N]
    //si (impresora no se esta usando)
        //tomar la impresora
        //imprimir
        //liberar la impresora
    
    ```c
        bool impresora_libre = true
        process persona[id:0..N-1]{
            <await impresora_libre; impresora_libre = false>
            Imprimir(documento)
            impresora_libre = true
        }
    ```


    ---
    b) Modifique la solución de (a) para el caso en que se deba respetar el orden de llegada. 

    ```c
        int indice = -1
        ColaEspecial q
        process persona[id:0..N-1]{
            <if (indice == -1) indice = id;
            else agregar(q, id)>;
            <await indice == id>;
            Imprimir(documento)
            <if (empty(q)) indice = -1;
            else indice = sacar(q)>;
        }
    ```
    
    ---
    c) Modifique la solución de (a) para el caso en que se deba respetar el orden dado por el identificador  del  proceso  (cuando  está  libre  la  impresora,  de  los  procesos  que  han solicitado su uso la debe usar el que tenga menor identificador).
     ```c
        int indice = -1
        COlaOrdenada qo

        process persona[id:0..N-1]{
            <if (indice == -1) indice = id;
            else agregarOrdenado(qo, id)>;
            <await indice == id>;
            Imprimir(documento)
            <if (empty(qo)) indice = -1;
            else indice = sacar(qo)>;
        }
    ```

    --- 
    d) Modifique la solución de (a) para el caso en que se deba respetar estrictamente el orden dado por el identificador del proceso (la persona X no puede usar la impresora hasta que no haya terminado de usarla la persona X-1). 
     ```c
        

        process persona[id:0..N-1]{
            
        }
    ```


    ---
    e) Modifique la solución de (c) para el caso en que además hay un proceso Coordinador que le indica a cada persona cuando puede usar la impresora. 
    ```c
            int pos = 0, act = -1, turno[0:n-1] = ([n] = 0); bool listo = false;

            process persona[id:0..N-1]{
               <turno[i] = pos; pos = pos + 1;>
               <await act == turno[i];>
               Imprimir(documento);
               listo = true;
            }

            process coordinador{
                j = 0..n-1{
                    act = j;
                    <await listo;>
                    listo= false;
                }
            }
        ```

---
6.  Resolver con SENTENCIAS AWAIT (<> y/o <await B; S>) el siguiente problema. En un examen final hay P alumnos y 3 profesores. Cuando todos los alumnos han llegado comienza el  examen.  Cada  alumno  resuelve  su  examen,  lo  entrega  y  espera  a  que  alguno  de  los profesores lo corrija y le indique la nota. Los profesores corrigen los exámenes respectando el orden en que los alumnos van entregando.  

    ```c

        process profesor[id: 1..3]{
            //recibe examen del alumno i
            //corrige el examen
            //devuelve el examen con su nota
            <await llegaron_todos>
            repartirExamen(alumno, examen)
            tiene_examen = true
            <await recibio_examen>
            corrigiendoExamen(examen)
            corregido = true
        }

        process alumno[id: 1..P]{
            //llega alumno, se incrementa la cantidad hasta P
            //llegan todos
            //comienza el examen
            //termina el examen y lo entrega al profesor i 
            //recibe el examen y se va
            <if (cant < P) cant + 1; 
            else llegaron_todos = true>
            <await tiene_examen>
            resolverExamen(id)
            entregarExamen(examen, id_profesor) //los alumnos deberían encolarse? cada profesor tendría una cola particular?
            <await corregido>
            irseDelSalon(id)
        }
    ```


---
7.  Dada  la  siguiente  solución  para  el  Problema  de  la  Sección  Crítica  entre  dos  procesos (suponiendo que tanto SC como SNC son segmentos de código finitos, es decir que terminan en algún momento), indicar si cumple con las 4 condiciones requeridas: 

### Variable Compartida
```c
    int turno = 1
```

### Proceso 1
```c
    Process SC1::  
    { while (true) 
      {   while (turno == 2) skip;  
           SC; 
           turno = 2; 
           SNC; 
       } 
    } 
```

### Proceso 2
```c
    Process SC2::  
    { while (true) 
        {   while (turno == 1) skip;  
            SC; 
            turno = 1; 
            SNC; 
        } 
    } 
```
En este caso, la solución planteada cumple con las 4 condiciones.

**Las 4 condiciones son:**
**1) Exclusión mutua:** A lo sumo un proceso está en su sección crítica. Suponiendo que *proceso 1* se encuentra en la SC, entonces, por lo menos para este caso *proceso 2* no va a poder entrar, pero siempre va a haber algún proceso en la SC.
**2) Ausencia de deadlock:** Si 2 o más procesos intentan entrar a su SC, al menos 1 de ellos tendrá éxito. Esta condición se garantiza, debido a que ninguno de los procesos quedará bloqueado indefinidamente, ya que cuando un proceso que está en la SC, sale, le pasa la posta al otro proceso para que pueda ingresar a la SC.
**3) Ausencia de demora innecesaria:** Si un proceso trata de entrar a su SC y los otros están en su SNC o terminaron, el primero no está impedido de entrar a la SC. Se cumple debido a que una vez que un proceso deja la SC y le pasa la posta al otro proceso, este segundo proceso puede entrar directamente a la SC sin necesidad de seguir esperando innecesariamente.
**4) Eventual entrada:** Un proceso que intenta entrar en su SC tiene posibilidades de hacerlo (eventualmente lo hará). Esto se cumple debido a que el turno se va alternando entre los dos procesos, esto implica que ambos eventualmente podrán entrar a la SC.


---
8.  Desarrolle una solución de grano fino usando sólo variables compartidas (no se puede usar las sentencias await ni funciones especiales como TS o FA). En base a lo visto en la clase 3 de teoría, resuelva el problema de acceso a sección crítica usando un proceso coordinador. En este caso, cuando un proceso SC[i] quiere entrar a su sección crítica le avisa al coordinador, y espera a que éste le dé permiso. Al terminar de ejecutar su sección crítica, el proceso SC[i] le  avisa  al  coordinador.  Nota:  puede  basarse  en  la  solución  para  implementar  barreras  con Flags y Coordinador vista en la teoría 3. 

```c
    bool listo = false; int act = -1;

    process accesoSC[id:1..N]{
        while(true){
            while (act <> i){
                skip;
            }
            SC();
            listo = true;
            SNC();
        }
    }

    process coordinador{
        while(true){
            for j= 1..N{
                act = j;
                while (listo == false){
                    skip;
                }
                listo == false;
            }
        }
    }
```

---
