#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TOPCONN.CH"

#DEFINE STR0001 "Tabela de integração - Gupy x Protheus"


User Function IntegTable()

Local	oBrw		:=	FWmBrowse():New() 

oBrw:SetDescription( STR0001 )
oBrw:SetAlias( 'ZNT' )
oBrw:SetMenuDef( 'IntegTable' )
oBrw:AddLegend( "ZNT_STATUS=='1'", "GREEN", "Em Aberto"  ) 
oBrw:AddLegend( "ZNT_STATUS=='2'", "RED"  , "Processado com Sucesso"  )

ZNT->(DbSetOrder(1))
oBrw:Refresh()

oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Rafael S. Iaquinto
@since 30/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"           OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.IntegTable" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.IntegTable" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.IntegTable" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.IntegTable" OPERATION 5 ACCESS 0
//ADD OPTION aRotina TITLE "Copiar"     ACTION "VIEWDEF.MPESCAD001" OPERATION 7 ACCESS 0

Return aRotina
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Rafael S. Iaquinto
@since 30/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruCab  :=  FWFormStruct( 1, 'ZNT' )
Local oModel    := 	MPFormModel():New( 'U_IntegTable',,)

oModel:AddFields('MODEL_CAB', /*cOwner*/, oStruCab)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Rafael S. Iaquinto
@since 25/05/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local 	oModel 		:= 	FWLoadModel( 'IntegTable' )
Local 	oView 		:= 	FWFormView():New()
Local   oStruCab    :=  FWFormStruct( 2, "ZNT" )

oView:SetModel( oModel )

oView:AddField( 'VIEW_CAB', oStruCab, 'MODEL_CAB' )
oView:EnableTitleView( 'VIEW_CAB', STR0001)
//oView:AddGrid( "VIEW_ITE" , oStruIte , 'MODEL_ITE')

oView:CreateHorizontalBox("CABEC",30)
oView:CreateHorizontalBox("GRID",70)
oView:SetOwnerView( 'VIEW_CAB', 'CABEC' )
oView:SetOwnerView( "VIEW_ITE","GRID")
//oView:AddUserButton(  )  

Return oView
