[Forma]
Clave=AgenteRutaMavi
Nombre=Rutas Cobranza
Icono=0
CarpetaPrincipal=AgenteRutaMavi
Modulos=(Todos)
ListaCarpetas=AgenteRutaMavi
VentanaTipoMarco=Sencillo
VentanaPosicionInicial=Centrado
VentanaExclusiva=S
VentanaEscCerrar=S
VentanaEstadoInicial=Normal
PosicionInicialIzquierda=521
PosicionInicialArriba=250
PosicionInicialAlturaCliente=273
PosicionInicialAncho=237
BarraHerramientas=S
AccionesTamanoBoton=15x5
AccionesDerecha=S
ListaAcciones=Aceptar
[AgenteRutaMavi]
Estilo=Hoja
Clave=AgenteRutaMavi
PermiteEditar=S
AlineacionAutomatica=S
AcomodarTexto=S
FichaColorFondo=Negro
MostrarConteoRegistros=S
Zona=A1
Vista=AgenteRutaMavi
Fuente={Tahoma, 8, Negro, []}
HojaTitulos=S
HojaMostrarColumnas=S
HojaMostrarRenglones=S
HojaColoresPorEstatus=S
HojaPermiteInsertar=S
HojaPermiteEliminar=S
HojaVistaOmision=Automática
CampoColorLetras=Negro
CampoColorFondo=Blanco
ListaEnCaptura=AgenteRutaMavi.Ruta
CarpetaVisible=S
Filtros=S
FiltroPredefinido=S
FiltroNullNombre=(sin clasificar)
FiltroEnOrden=S
FiltroTodoNombre=(Todo)
FiltroAncho=20
FiltroGeneral=AgenteRutaMavi.Agente=<T>{Info.Agente}<T>
FiltroRespetar=S
FiltroTipo=General
[AgenteRutaMavi.AgenteRutaMavi.Ruta]
Carpeta=AgenteRutaMavi
Clave=AgenteRutaMavi.Ruta
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
Tamano=50
ColorFondo=Blanco
ColorFuente=Negro
[AgenteRutaMavi.Columnas]
Ruta=207
[Acciones.Aceptar.Guardar]
Nombre=Guardar
Boton=0
TipoAccion=Controles Captura
ClaveAccion=Guardar Cambios
Activo=S
Visible=S
ConCondicion=S
EjecucionConError=S
EjecucionCondicion=Asigna(Temp.Texto, ListaBuscarDuplicados(CampoEnLista(AgenteRutaMavi:AgenteRutaMavi.Ruta)))<BR>Vacio(Temp.Texto)
EjecucionMensaje=Comillas(Temp.Texto)+<T> Duplicado<T>
[Acciones.Aceptar.Cerrar]
Nombre=Cerrar
Boton=0
TipoAccion=Ventana
ClaveAccion=Cerrar
Activo=S
Visible=S
[Acciones.Aceptar]
Nombre=Aceptar
Boton=3
NombreEnBoton=S
NombreDesplegar=&Guardar y Cerrar
Multiple=S
EnBarraHerramientas=S
TipoAccion=Controles Captura
ListaAccionesMultiples=Guardar<BR>Cerrar
Activo=S
Visible=S
ConCondicion=S
EjecucionConError=S
GuardarAntes=S
EjecucionCondicion=Asigna(Temp.Texto, ListaBuscarDuplicados(CampoEnLista(AgenteRutaMavi.Ruta)))<BR>Vacio(Temp.Texto)
EjecucionMensaje=Comillas(Temp.Texto)+<T> Duplicado<T>

[