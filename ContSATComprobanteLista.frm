
[Forma]
Clave=ContSATComprobanteLista
Icono=0
CarpetaPrincipal=ContSATComprobanteListas
Modulos=(Todos)
VentanaTipoMarco=Sencillo
VentanaPosicionInicial=Centrado
VentanaEstadoInicial=Normal
BarraHerramientas=S
AccionesTamanoBoton=15x5
AccionesDerecha=S

PosicionInicialIzquierda=182
PosicionInicialArriba=111
PosicionInicialAlturaCliente=506
PosicionInicialAncho=1001
PosicionSec1=328
Nombre=Información Polizas
ListaCarpetas=ContSATComprobanteListas<BR>Detalles
ListaAcciones=Aceptare<BR>EnviarExcel<BR>Comprobante<BR>CFDCBB<BR>Extranjero<BR>Cheque<BR>Transferencia<BR>OtrosMetodos<BR>Validare<BR>MovPosicion<BR>ExploradorPolizas
PosicionSeccion1=50
Menus=S
MenuPrincipal=&Archivo<BR>&Transacción
[ContSATComprobanteLista]
Estilo=Iconos
PestanaOtroNombre=S
PestanaNombre=Polizas
Clave=ContSATComprobanteLista
Filtros=S
BusquedaRapidaControles=S
AlineacionAutomatica=S
AcomodarTexto=S
MostrarConteoRegistros=S
Zona=A1
Vista=ContSATComprobanteLista
Fuente={Tahoma, 8, Negro, []}
CampoColorLetras=Negro
CampoColorFondo=Blanco
;ListaEnCaptura=(Lista)
ListaEnCaptura=ContSATComprobanteLista.TipoPoliza<BR>ContSATComprobanteLista.Referencia<BR>ContSATComprobanteLista.Concepto<BR>ContSATComprobanteLista.Proyecto

FiltroPredefinido=S
FiltroNullNombre=(sin clasificar)
FiltroEnOrden=S
FiltroTodoNombre=(Todo)
FiltroAncho=20
FiltroRespetar=S
FiltroTipo=Múltiple (por Grupos)
FiltroPeriodos=S
FiltroEjercicios=S
FiltroModificarEstatus=S
FiltroCambiarPeriodo=S
FiltroBuscarEn=S
FiltroFechasCambiar=S
FiltroMonedas=S
FiltroFechasCampo=ContSATComprobanteLista.FechaEmision
FiltroFechasNormal=S
FiltroMonedasCampo=ContSATComprobanteLista.Moneda
FiltroFechasNombre=&Fecha
CarpetaVisible=S

IconosCampo=(sin Icono)
IconosEstilo=Detalles
IconosAlineacion=de Arriba hacia Abajo
IconosConSenales=S
ElementosPorPaginaEsp=200
IconosSubTitulo=<T>Consecutivo<T>
FiltroTodo=S
FiltroGrupo1=ContSATComprobanteLista.TipoPoliza
FiltroValida1=ContSATComprobanteLista.TipoPoliza
BusquedaRapida=S
BusquedaEnLinea=S
IconosNombre=ContSATComprobanteLista:ContSATComprobanteLista.Mov+<T> <T>+ContSATComprobanteLista:ContSATComprobanteLista.MovID
[ContSATComprobanteLista.ContSATComprobanteLista.Referencia]
Carpeta=ContSATComprobanteLista
Clave=ContSATComprobanteLista.Referencia
Editar=S
LineaNueva=S
ValidaNombre=S
3D=S
Tamano=50
ColorFondo=Blanco

