1. La oficina central de una empresa de venta de indumentaria debe calcular cuántas veces fue vendido cada uno de los artículos de su catálogo. La empresa se compone de 100 sucursales y cada una de ellas maneja su propia base de datos de ventas. La oficina central cuenta con una herramienta que funciona de la siguiente manera: ante la consulta realizada para un artículo determinado, la herramienta envía el identificador del artículo a cada una de las sucursales, para que cada uno de éstas calcule cuántas veces fue vendido en ella. Al final del procesamiento, la herramienta debe conocer cuántas veces fue vendido en total, considerando todas las sucursales. Cuando ha terminado de procesar un artículo comienza con el siguiente (suponga que la herramienta tiene una función generarArtículo que retorna el siguiente ID a consultar). 
*Nota: maximizar la concurrencia. Supongo que existe una función ObtenerVentas(ID) que retorna la cantidad de veces que fue vendido el artículo con identificador ID en la base de datos de la sucursal que la llama.*
```java
Procedure empresa is

    Task type sucursal;
    arrSucursales: array (1..100) of sucursal;

    Task body sucursal is
        idArticulo: string;
        cantidad: int;    
    begin
        loop
            Herramienta.siguienteArticulo(idArticulo);
            cantidad:= obtenerVentas(idArticulo);
            Herramienta.resultado(cantidad);
        end loop;
    end sucursal;

    Task herramienta is
        entry siguienteArticulo(idArticulo: OUT string);
        entry resultado(cantidad: IN int);
    end herramienta;

    Task body herramienta is
        total: int;
        idArt: string;
    body
        idArt:= generarArticulo();
        total := 0;

        for i:= 1 to 100 loop
            accept siguienteArticulo(idArticulo: OUT string) do
                idArt:=idArticulo;
            end siguienteArticulo;
        end loop;

        for i:= 1 to 100 loop
            accept resultado(cantidad: IN int) do
                total := total + cantidad;
            end resultado;
        end loop;
        print(total);
    end herramienta;

begin
    null;
end empresa;


```

---
2. En un negocio de cobros digitales hay P personas que deben pasar por la única caja de cobros para realizar el pago de sus boletas. Las personas son atendidas de acuerdo con el orden de llegada, teniendo prioridad aquellos que deben pagar menos de 5 boletas de los que pagan más. Adicionalmente, las personas embarazadas y los ancianos tienen prioridad sobre los dos casos anteriores. Las personas entregan sus boletas al cajero y el dinero de pago; el cajero les devuelve el vuelto y los recibos de pago.

---
3. La página web del Banco Central exhibe las diferentes cotizaciones del dólar oficial de 20 bancos del país, tanto para la compra como para la venta. Existe una tarea programada que se ocupa de actualizar la página en forma periódica y para ello consulta la cotización de cada uno de los 20 bancos. Cada banco dispone de una API, cuya única función es procesar las solicitudes de aplicaciones externas. La tarea programada consulta de a una API por vez, esperando a lo sumo 5 segundos por su respuesta. Si pasado ese tiempo no respondió, entonces se mostrará vacía la información de ese banco.

---
4. Simular la venta de entradas a un evento musical por medio de un portal web. Hay N clientes que intentan comprar una entrada para el evento; los clientes pueden ser regulares o especiales (clientes que están asociados al sponsor del evento). Cada cliente especial hace un pedido al portal y espera hasta ser atendido; cada cliente regular hace un pedido y si no es atendido antes de los 5 minutos, vuelve a hacer el pedido siguiendo el mismo patrón (espera a lo sumo 5 minutos y si no lo vuelve a intentar) hasta ser atendido. Después de ser atendido, si consiguió comprar la entrada, debe imprimir el comprobante de la compra. El portal tiene E entradas para vender y atiende los pedidos de acuerdo al orden de llegada pero dando prioridad a los Clientes Especiales. Cuando atiende un pedido, si aún quedan entradas disponibles le vende una al cliente que hizo el pedido y le entrega el comprobante. Nota: no debe modelarse la parte de la impresión del comprobante, sólo llamar a una función Imprimir (comprobante) en el cliente que simulará esa parte; la cantidad E de entradas es mucho menor que la cantidad de clientes (T << C); todas las tareas deben terminar.

---
5. Se quiere modelar el funcionamiento de un banco, al cual llegan clientes que deben realizar un pago y llevarse su comprobante. Los clientes se dividen entre los regulares y los premium, habiendo R clientes regulares y P clientes premium. Existe un único empleado en el banco, el cual atiende de acuerdo al orden de llegada, pero dando prioridad a los premium sobre los regulares. Si a los 30 minutos de llegar un cliente regular no fue atendido, entonces se retira sin realizar el pago. Los clientes premium siempre esperan hasta ser atendidos.

---
6. Una empresa de venta de calzado cuenta con S sedes. En la oficina central de la empresa se utiliza un sistema que permite controlar el stock de los diferentes modelos, ya que cada sede tiene una base de datos propia. El sistema de control de stock funciona de la siguiente manera: dado un modelo determinado, lo envía a las sedes para que cada una le devuelva la cantidad disponible en ellas; al final del procesamiento, el sistema informa el total de calzados disponibles de dicho modelo. Una vez que se completó el procesamiento de un modelo, se procede a realizar lo mismo con el siguiente modelo. Nota: suponga que existe una función DevolverStock(modelo,cantidad) que utiliza cada sede donde recibe como parámetro de entrada el modelo de calzado y retorna como parámetro de salida la cantidad de pares disponibles. Maximizar la concurrencia y no generar demora innecesaria.