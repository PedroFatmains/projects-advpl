#INCLUDE 'PARMTYPE.CH' 
#INCLUDE 'TBICONN.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWMBROWSE.CH'

/*/{Protheus.doc} GPE10MENU

@history 31/01/2022, Pedro Silva // 		----   COMPLETAR E DOCUMENTAR FONTES

@type function

@version  P12

@author ECR

@param

@since 

@return 
/*/

#DEFINE STR0001 'Importar Funcionários - Gupy x Protheus'

User Function GPE10MENU()

Local aArea  :=     GetArea()

aAdd(aRotina, { "Importar Candidatos Gupy", "u_ntxmark", 0, 4, 0, Nil })

RestArea( aArea )

Return Nil
