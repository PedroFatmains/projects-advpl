#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
#Include 'parmtype.ch' 
#INCLUDE "RWMAKE.CH" 
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH" 

/*/{Protheus.doc} NortoxWS

@history 31/01/2022, Pedro Silva 

- WebService responsável por receber os candidatos da Gupy

@type function
@version  P12
@author ECR

@return 
/*/

User Function NortoxWS()

Return

WSRESTFUL WEBHOOKS DESCRIPTION "Tabela de Pré-Integração Gupy x Protheus."


WSMETHOD POST DESCRIPTION "Método para receber e alimentar cadastro de funcionário" WSSYNTAX "/webhooks" 


END WSRESTFUL

WSMETHOD POST WSSERVICE WEBHOOKS


	Local  cJSON 	   		   :=  Self:GetContent()     as character
	Local  oParseJSON  		   :=  NIl					 as object

	::SetContentType( "application/json" )
	CONOUT( "CONOUT"+ " ENTROU NA APLICAÇÃO" )
	CONOUT( "Tempo Inicial "+ Time() )

	If Empty( cJSON ) 							
		SetRestFault( 500, "Verifique as informacoes enviadas" ) 
		Return .F.
	EndIf


	If !FWJsonDeserialize( cJSON , @oParseJSON ) 
		SetRestFault( 500 , "Nao foi possivel converter a req para JSON" )
		Return .F.
	EndIf

	CONOUT( cJson )

	DbSelectArea( "ZNT" )
	Reclock( "ZNT" , .T. )
	
	ZNT->ZNT_FILIAL  :=  FwCodFil()
	ZNT->ZNT_MSGREQ  :=  cjson			
	ZNT->ZNT_DTREQ   :=  FWTimeStamp( 5 )
	ZNT->ZNT_IDGUPY	 :=  Alltrim(CvaltoChar(( oParseJSON:data:candidate:id)))
	ZNT->ZNT_USRPRT  :=  oApp:cUserName
	ZNT->ZNT_STATUS  :=  "1"
	ZNT->ZNT_MSGSTA  :=  "Em processamento"
    
	Msunlock()

	::SetResponse( cJson )
	FreeObj( oParseJSON )

Return .T.
