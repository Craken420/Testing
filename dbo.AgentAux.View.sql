SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE VIEW [dbo].[AgentAux]

AS
SELECT c.Agente,
a.*
FROM Agente c WITH(NOLOCK)
LEFT OUTER JOIN Auxiliar a WITH(NOLOCK) ON c.Agente = a.Cuenta AND a.Rama = 'AGENT'



GO
