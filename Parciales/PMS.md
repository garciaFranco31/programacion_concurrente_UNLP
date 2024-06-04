1. En la estación de trenes hay una terminal de SUBE que debe ser usada por P personas de acuerdo con el orden de llegada. Cuando la persona accede a la terminal, la usa y luego se retira para dejar al siguiente. 
*Nota: cada Persona una sólo una vez la terminal.*

```c
    Process Persona[id:0..P-1]{
        Admin!pedido(id);
        Admin?usarTerminal();
        cargandoSube();
        Admin!liberar(id);
    }

    Process Admin{
        bool libre = true;
        int idPersona;
        cola fila;
        
        while(true){
            if
                [] libre; Persona[*]?pedido(idPersona) ->{
                    libre = false;
                    Persona[idPersona]!usarTerminal();
                }
                [] not libre; Persona[*]?pedido(idPersona) ->{
                    fila.push(idPersona);
                }
                [] ;Persona?liberar(idPersona) -> {
                    if (empty(fila)){
                        libre = true;
                    }else{
                        idPersona = fila.pop();
                        Persona[idPersona]!usarTerminal();
                    }
                }
            fi
        }
    }

```

---
2. En una oficina existen 100 empleados que envían documentos para imprimir en 5 impresoras compartidas. Los pedidos de impresión son procesados por orden de llegada y se asignan a la primera impresora que se encuentre libre.

```c
Process Empleado[id:0..99]{
    text documento, impresion;
    //genera documento
    //envia el documento a imprimir
    //recibe el documento impreso
    documento = generarDocumento();
    Admin!imprimirDocumento(id,documento);
    Impresora?enviarImpresion(impresion);
}

Process Impresora[id:0..4]{
    int idEmpleado;
    text documento, impresion;
    //pedir trabajo (envia id)
    //recibe el documento a imprimir
    //imprime el documento
    //se lo envía al empleado (idEmpleado)
    Admin!pedido(id);
    Admin?resolverPedido(idEmpleado, documento);
    Empleado[idEmpleado]!enviarImpresion(impresion);
}

Process Admin{
    cola pedidos;
    text documento;
    int idEmpleado, idImpresora;

    do Empleado[*]?imprimirDocumento(idEmpleado,documento) -> pedidos.push(idEmpleado,documento);
       [] not empty(documento); Impresora[*]?pedido(idImpresora) ->
                        Impresora[idImpresora]!resolverPedido(pedidos.pop());
    od

}

```

---
3. En un torneo de programación hay 1 organizador, N competidores y S supervisores. El organizador comunica el desafío a resolver a cada competidor. Cuando un competidor cuenta con el desafío a resolver, lo hace y lo entrega para ser evaluado. A continuación, espera a que alguno de los supervisores lo corrija y le indique si está bien. En caso de tener errores, el competidor debe corregirlo y volver a entregar, repitiendo la misma metodología hasta que llegue a la solución esperada. Los supervisores corrigen las entregas respetando el orden en que los competidores van entregando. 
*Nota: maximizar la concurrencia y no generar demora innecesaria.*

```c
Process Competidor[id:0..N-1]{
    text desafio;
    bool estaBien = false;

    Organizdor?entregarDesafio(desafio);
    while (not estaBien){
        desafio = resolverDesafio();
        Admin!desafioFinalizado(id,desafio);
        Supervisor[*]?desafioCorregido(estaBien);
    }

}

Process Supervisor[id:0..S-1]{
    text desafio;
    bool estaBien;
    int idCompetidor;

    while(true){
        Admin!pedido(id);
        Admin?corregirDesafio(idCompetidor,desafio);
        nota = corregir(desafio);
        Competidor[idCompetidor]!desafioCorregido(estaBien);
    }

}

Process Organizador{
    text desafio;
    int i;

    for i = 0 to S-1{
        Competidor[i]!entregarDesafio(desafio);
    }
}

Process Admin{
    text desafio;
    int idSupervisor, idCompetidor;
    cola desafiosResueltos(int, string);

    do Competidor[*]?desafioFinalizado(idCompetidor,desafio) -> desafiosResueltos.push(idCompetidor,desafio);
       [] not empty(desafiosResueltos); Supervisor[*]?pedido(idSupervisor) ->  
                    Supervisor[idSupervisor]!corregirDesafio(desafiosResueltos.pop());
    od
}


```

---
4. En un comedor estudiantil hay un horno microondas que debe ser usado por E estudiantes de acuerdo con el orden de llegada. Cuando el estudiante accede al horno, lo usa y luego se retira para dejar al siguiente. 
*Nota: cada Estudiante usa sólo una vez el horno.*

```c
Process Estudiante[id:0..E-1]{
    Admin!pasar(id);
    Admin?usarHorno();
    usandoHorno();
    Admin!dejar();
}

Process Admin{
    cola fila;
    bool libre = true;

    do ; Estudiante[*]?pasar(idEstudiante) -> {
        []   if (libre){
                libre = false;
                Estudiante[idEstudiante]!usarHorno();
            }else{
                fila.push(idEstudiante);
            }
        }
        
        [] ; Estudiante[*]?dejar() -> {
            if(empty(fila)){
                libre = true;
            }else{
                idEstudiante = fila.pop();
                Estudiante[idEstudiante]!usarHorno();
            }
        }
       
    od
}

```