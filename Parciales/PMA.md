1. En un negocio de cobros digitales hay P personas que deben pasar por la única caja de cobros para realizar el pago de sus boletas. Las personas son atendidas de acuerdo con el orden de llegada, teniendo prioridad aquellos que deben pagar menos de 5 boletas de los que pagan más. Adicionalmente, las personas embarazadas tienen prioridad sobre los dos casos anteriores. Las personas entregan sus boletas al cajero y el dinero de pago; el cajero les devuelve el vuelto y los recibos de pago.

```c
    chan pagar(int,string,int);//id, boleta, dinero
    chan pagarEmbarazadas(int, string, int);
    chan paganMenosCinco(int, string, int);
    chan aviso();
    chan resultado[P](int, string);

    Process Persona[id:0..P-1]{
        int cantBoletas;
        bool embarazada;
        text boletas, recibo;
        int dinero, vuelto;


        if (embarazada) {
            send pagarEmbarazadas(id,boleta,dinero);
        }
        elif (cantBoletas < 5){
            send paganMenosCinco(id, boleta, dinero);
        }else{
            pagar(id, boleta, dinero);
        }
        send aviso();

        receive resultado[id](vuelto,recibo);

    }

    Process Caja{
        int idPersona, pago, vuelto;
        text boletas, recibo;

        do
            if (empty(pagarEmbarazadas) && empty(paganMenosCinco)){
                receive pagar(idPersona, boletas, pago);
            }elif (not empty(pagarEmbarazadas) && not empty(paganMenosCinco)){
                receive pagarEmbarazadas(idPersona, boletas, pago);
            }else{
                receive paganMenosCinco(idPersona, boletas, pago);
            }
            receive aviso();
            send resultado[idPersona](vuelto, recibo);
        od
    }

```

---
2. En una oficina existen 100 empleados que envían documentos para imprimir en 5 impresoras compartidas. Los pedidos de impresión son procesados por orden de llegada y se asignan a la primera impresora que se encuentre libre.

```c
chan imprimir(int,string);
chan documentoImpreso(string);

Process Empleado[id:1..100]{
    text documento, docImpreso;

    while(true){
        documento = generaDocumento();
        send imprimir(id, documento);
        receive documentoImpreso(docImpreso);
    }

}

Process Impresora[id:1..5]{
    text documento, impresion;
    int idEmpleado;

    while(true){
        receive impresoras(idEmpleado,documento);
        impresion = imprimir(documento);
        send documentoImpreso[idEmpleado](impresion);
    }
}
```

---
3. Se debe modelar el funcionamiento de una casa de venta de repuestos automotores, en la que trabajan V vendedores y que debe atender a C clientes. El modelado debe considerar que: 
    a. cada cliente realiza un pedido y luego espera a que se lo entreguen; y 
    b. los pedidos que hacen los clientes son tomados por cualquiera de los vendedores. Cuando no hay pedidos para atender, los vendedores aprovechan para controlar el stock de los repuestos (tardan entre 2 y 4 minutos para hacer esto). 
    *Nota: maximizar la concurrencia.*

```c
chan pedido(int);
chan pedidosClientes(int, string);
chan atenderPedido[V](int, string);
chan pedidoResuelto[C](string);

Process Vendedor[id:0..V-1]{
    //si hay pedido
        //tomar el pedido
    //sino
        //controlar stock
    text pedido;
    int idCliente;

    while(true){
        send pedido(id);
        receive atenderPedido[id](idCliente, pedido);
        if (pedido <> "vacio"){
            pedido = atenderCliente();
            send pedidoResuelto[idCliente](pedido);
        }else{
            delay(120 - 240);
        }

    }
}

Process Cliente[id:0..C-1]{
    //realizar pedido
    //esperar a que se lo entreguen
    text pedido, respuesta;

    pedido = generarPedido();
    send pedidosClientes(id,pedido);
    receive pedidoResuelto[id](respuesta);
}

Process Admin{
    int idVendedor, idCliente;
    text pedido;

    while(true){
        receive pedido(idVendedor);
        if (empty(pedidosClientes)){
            idCliente = -1;
            pedido = "vacio";
        }else{
            receive pedidosClientes(id, pedido);
        }
        send atenderPedido[idVendedor](idCliente, pedido);
    }
}

```

---
4. Se debe simular la atención en un banco con 3 cajas para atender a N clientes que pueden ser especiales (son las embarazadas y los ancianos) o regulares. Cuando el cliente llega al banco se dirige a la caja con menos personas esperando y se queda ahí hasta que lo terminan de atender y le dan el comprobante de pago. Las cajas atienden a las personas que van a ella de acuerdo al orden de llegada pero dando prioridad a los clientes especiales; cuando terminan de atender a un cliente le debe entregar un comprobante de pago. Nota: maximizar la concurrencia.