SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE VIEW [dbo].[ActivoFijoCont]

AS
SELECT
ID,
Empresa,
FechaEmision,
Mov,
MovID,
Poliza,
PolizaID,
ContID,
Sucursal,
"Estatus" = CASE WHEN Estatus = 'CANCELADO' THEN 'CANCELADO' WHEN GenerarPoliza = 1 THEN 'PENDIENTE' WHEN GenerarPoliza = 0 AND Poliza IS NOT NULL AND PolizaID IS NOT NULL THEN 'CONTABILIZADO' WHEN GenerarPoliza = 0 AND ContID IS NOT NULL THEN 'PROCESAR' ELSE 'N/A' END
FROM
ActivoFijo WITH(NOLOCK)
WHERE
Estatus NOT IN ('SINAFECTAR', 'BORRADOR', 'CONFIRMAR')



GO
