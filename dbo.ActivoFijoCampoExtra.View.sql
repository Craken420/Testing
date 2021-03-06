SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE VIEW [dbo].[ActivoFijoCampoExtra]  AS SELECT m.*, "MG_CONSUMO_TALLER"=(SELECT Valor FROM MovCampoExtra ce WITH(NOLOCK) WHERE ce.Modulo="AF" AND ce.Mov=m.Mov AND ce.ID=m.ID AND ce.CampoExtra="MG_CONSUMO_TALLER"), "ML_CONSUMO_TALLER"=(SELECT Valor FROM MovCampoExtra ce WITH(NOLOCK) WHERE ce.Modulo="AF" AND ce.Mov=m.Mov AND ce.ID=m.ID AND ce.CampoExtra="ML_CONSUMO_TALLER"), "MS_CONSUMO_TALLER"=(SELECT Valor FROM MovCampoExtra ce WITH(NOLOCK) WHERE ce.Modulo="AF" AND ce.Mov=m.Mov AND ce.ID=m.ID AND ce.CampoExtra="MS_CONSUMO_TALLER"), "RE_CONSUMO_TALLER"=(SELECT Valor FROM MovCampoExtra ce WITH(NOLOCK) WHERE ce.Modulo="AF" AND ce.Mov=m.Mov AND ce.ID=m.ID AND ce.CampoExtra="RE_CONSUMO_TALLER") FROM ActivoFijo m WITH(NOLOCK)
GO
