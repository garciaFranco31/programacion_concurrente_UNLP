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
1. En una oficina existen 100 empleados que envían documentos para imprimir en 5 impresoras compartidas. Los pedidos de impresión son procesados por orden de llegada y se asignan a la primera impresora que se encuentre libre.

---
3. Se debe modelar el funcionamiento de una casa de venta de repuestos automotores, en la que trabajan V vendedores y que debe atender a C clientes. El modelado debe considerar que: (a) cada cliente realiza un pedido y luego espera a que se lo entreguen; y (b) los pedidos que hacen los clientes son tomados por cualquiera de los vendedores. Cuando no hay pedidos para atender, los vendedores aprovechan para controlar el stock de los repuestos (tardan entre 2 y 4 minutos para hacer esto). Nota: maximizar la concurrencia

---
4. Se debe simular la atención en un banco con 3 cajas para atender a N clientes que pueden ser especiales (son las embarazadas y los ancianos) o regulares. Cuando el cliente llega al banco se dirige a la caja con menos personas esperando y se queda ahí hasta que lo terminan de atender y le dan el comprobante de pago. Las cajas atienden a las personas que van a ella de acuerdo al orden de llegada pero dando prioridad a los clientes especiales; cuando terminan de atender a un cliente le debe entregar un comprobante de pago. Nota: maximizar la concurrencia.