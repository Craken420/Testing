[Forma]
Clave=ClienteExpressMaviSelectorFecha
Nombre=Selector de fecha
Icono=65
Modulos=(Todos)
ListaCarpetas=variables
CarpetaPrincipal=variables
PosicionInicialAlturaCliente=93
PosicionInicialAncho=298
PosicionSec1=556
PosicionInicialIzquierda=491
PosicionInicialArriba=448
VentanaSiempreAlFrente=S
VentanaTipoMarco=Normal
VentanaPosicionInicial=Centrado
VentanaBloquearAjuste=S
VentanaEstadoInicial=Normal
BarraAcciones=S
AccionesTamanoBoton=15x5
ListaAcciones=aceptar
VentanaEscCerrar=S
AccionesCentro=S
AutoGuardar=S
[variables]
Estilo=Ficha
Clave=variables
PermiteEditar=S
AlineacionAutomatica=S
AcomodarTexto=S
MostrarConteoRegistros=S
Zona=A1
Vista=(Variables)
Fuente={Tahoma, 8, Negro, []}
FichaEspacioEntreLineas=6
FichaEspacioNombres=100
FichaEspacioNombresAuto=S
FichaNombres=Izquierda
FichaAlineacion=Izquierda
FichaColorFondo=Plata
FichaAlineacionDerecha=S
CampoColorLetras=Negro
CampoColorFondo=Blanco
ListaEnCaptura=Mavi.ClienteExpressMaviDia<BR>Mavi.ClienteExpressMaviMes<BR>Mavi.ClienteExpressMaviAno
CarpetaVisible=S
[variables.Mavi.ClienteExpressMaviDia]
Carpeta=variables
Clave=Mavi.ClienteExpressMaviDia
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
Tamano=5
ColorFondo=Blanco
ColorFuente=Negro
[variables.Mavi.ClienteExpressMaviMes]
Carpeta=variables
Clave=Mavi.ClienteExpressMaviMes
Editar=S
LineaNueva=N
ValidaNombre=S
3D=S
Tamano=12
ColorFondo=Blanco
ColorFuente=Negro
[variables.Mavi.ClienteExpressMaviAno]
Carpeta=variables
Clave=Mavi.ClienteExpressMaviAno
Editar=S
LineaNueva=N
ValidaNombre=S
3D=S
Tamano=7
ColorFondo=Blanco
ColorFuente=Negro
[ClienteExpressMaviSelectorFecha.mes]
Carpeta=ClienteExpressMaviSelectorFecha
Clave=mes
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
Tamano=5
ColorFondo=Blanco
ColorFuente=Negro
[ClienteExpressMaviSelectorFecha.ano]
Carpeta=ClienteExpressMaviSelectorFecha
Clave=ano
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
ColorFondo=Blanco
ColorFuente=Negro
[ClienteExpressMaviSelectorFecha.fecha]
Carpeta=ClienteExpressMaviSelectorFecha
Clave=fecha
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
ColorFondo=Blanco
ColorFuente=Negro
[ClienteExpressMaviSelectorFecha.day]
Carpeta=ClienteExpressMaviSelectorFecha
Clave=day
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
ColorFondo=Blanco
ColorFuente=Negro
[ClienteExpressMaviSelectorFecha.Columnas]
mes=34
ano=64
fecha=94
day=64
[Acciones.aceptar]
Nombre=aceptar
Boton=0
NombreDesplegar=&Aceptar
EnBarraAcciones=S
TipoAccion=Ventana
ClaveAccion=Aceptar
Activo=S
Visible=S
Multiple=S
ListaAccionesMultiples=expre<BR>Aceptar<BR>guardar
GuardarAntes=S
[Acciones.aceptar.expre]
Nombre=expre
Boton=0
TipoAccion=Expresion
Activo=S
Visible=S
Expresion=asigna(info.numero,0)<BR>caso Mavi.ClienteExpressMaviMes<BR>    es <T>Enero<T> entonces asigna(info.numero,1)<BR>    es <T>Febrero<T> entonces asigna(info.numero,2)<BR>    es <T>Marzo<T> entonces asigna(info.numero,3)<BR>    es <T>Abril<T> entonces asigna(info.numero,4)<BR>    es <T>Mayo<T> entonces asigna(info.numero,5)<BR>    es <T>Junio<T> entonces asigna(info.numero,6)<BR>    es <T>Julio<T> entonces asigna(info.numero,7)<BR>    es <T>Agosto<T> entonces asigna(info.numero,8)<BR>    es <T>Septiembre<T> entonces asigna(info.numero,9)<BR>    es <T>Octubre<T> entonces asigna(info.numero,10)<BR>    es <T>Noviembre<T> entonces asigna(info.numero,11)<BR>    es <T>Diciembre<T> entonces asigna(info.numero,12)<BR>    sino entonces asigna(info.numero,1)<BR>Fin<BR>SQL(<T>Exec sp_MAVIDM0138ClienteExpressMaviF<CONTINUA>
Expresion002=<CONTINUA>echa :ndia,:nmes,:nano<T>,Mavi.ClienteExpressMaviDia,info.numero,Mavi.ClienteExpressMaviAno)<BR>asigna(info.mensaje,<T><T>)<BR>Asigna(info.mensaje,SQL(<T>Select top 1 res from ##clienteexpressmavifecha<T>))<BR>si vacio(info.mensaje) entonces error(<T>La fecha que ingresaste es: Erronea<T>) sino<BR>asigna(Mavi.ClienteExpressFecha,TextoEnFecha(info.mensaje))<BR>fin
[Acciones.aceptar.Aceptar]
Nombre=Aceptar
Boton=0
TipoAccion=Ventana
ClaveAccion=Aceptar
Activo=S
Visible=S
[Acciones.aceptar.guardar]
Nombre=guardar
Boton=0
TipoAccion=Ventana
ClaveAccion=Aceptar
Activo=S
Visible=S