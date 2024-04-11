#INCLUDE 'PARMTYPE.CH' 
#INCLUDE 'TBICONN.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWMBROWSE.CH'

#DEFINE STR0001 'Importar Funcionários - Gupy x Protheus'

/*/{Protheus.doc} NortoxMark

@history 31/01/2022, Pedro Silva 

- Função responsável por ler os registros da integração do Gupy e apresentar na tela.

@type function
@version  P12
@author ECR

@return 
/*/

User Function NtxMark()

Local  cTable              :=   GetNextAlias()                               as character
Local  cCodMun             :=   ''			                                 as character
Local  cCodPais            :=   ''			                                 as character
Local  cCentroCusto        :=   ''			                                 as character
Local  oTable              :=   FwTemporaryTable():New( cTable )             as object 
Local  aFields             :=   {}                                           as array
Local  oJson     		   :=   JsonObject():New()                           as object
Local  oSalario     	   				    		                         as object
Local  aJson 			   :=   {}						     				 as array
Local  aColumns       	   :=   {}										     as array 	

Private  aRotClone         :=   aClone( aRotina )
Private  oMark

aRotina := {}
MenuDef()

aAdd( aFields , { "SA_IDGUPY"  ,   "C"   ,  07   ,   0   } ) 
aAdd( aFields , { "SA_NOME"    ,   "C"   ,  030  ,   0   } ) 
aAdd( aFields , { "SA_CIC"     ,   "C"   ,  011  ,   0   } )
aAdd( aFields , { "SA_BIRTH"   ,   "D"   ,  08   ,   0   } ) 
aAdd( aFields , { "SA_MARK"    ,   "C"   ,  02   ,   0   } ) 
aAdd( aFields , { "SA_SEXO"    ,   "C"   ,  01   ,   0   } ) 
aAdd( aFields , { "SA_ESTCIVI" ,   "C"   ,  01   ,   0   } ) 
aAdd( aFields , { "SA_CPAISOR" ,   "C"   ,  05   ,   0   } ) 
aAdd( aFields , { "SA_NACIONA" ,   "C"   ,  02   ,   0   } ) 
aAdd( aFields , { "SA_CC"      ,   "C"   ,  011  ,   0   } ) 
aAdd( aFields , { "SA_ADMISSA" ,   "D"   ,  08   ,   0   } ) 
aAdd( aFields , { "SA_SALARIO" ,   "N"   ,  012  ,  02   } ) 
aAdd( aFields , { "SA_VIEMRAI" ,   "C"   ,  030  ,   0   } ) 
aAdd( aFields , { "SA_LOGRDSC" ,   "C"   ,  080  ,   0   } ) 
aAdd( aFields , { "SA_COMPLEM" ,   "C"   ,  030  ,   0   } ) 
aAdd( aFields , { "SA_ESTADO"  ,   "C"   ,  02   ,   0   } ) 
aAdd( aFields , { "SA_CODMUN"  ,   "C"   ,  05   ,   0   } ) 
aAdd( aFields , { "SA_MUNICIP" ,   "C"   ,  020  ,   0   } ) 
aAdd( aFields , { "SA_CEP"     ,   "C"   ,  08   ,   0   } ) 
aAdd( aFields , { "SA_EMAIL"   ,   "C"   ,  050  ,   0   } ) 
aAdd( aFields , { "SA_ENDEREC" ,   "C"   ,  030  ,   0   } ) 
aAdd( aFields , { "SA_NUMENDE" ,   "C"   ,  06   ,   0   } ) 
aAdd( aFields , { "SA_DTREQ"   ,   "C"   ,  020  ,   0   } ) 
aAdd( aFields , { "SA_MOEDA"   ,   "C"   ,  03   ,   0   } ) 

oTable:SetFields( aFields )
oTable:Create()

Dbselectarea( "ZNT" )
ZNT->( Dbgotop(  ) )

While ZNT->( !EOF() ) 	

	While ZNT->( !EOF() ) .and. ZNT->ZNT_MSGREQ <> '' .and. ZNT->ZNT_STATUS <> "2"

    	oJson:FromJson( ZNT->ZNT_MSGREQ ) // receber json do registro posicionado 

		aJson   	    :=  oJson:GetJSonObject( "data" ) 
		oCandidate 	    := 	aJson[ "candidate" ]
		oJob    	    := 	aJson[ "job" ]  
		oApplication    := 	aJson[ "application" ]  
		oCentroCusto    :=  aJson[ "job" ][ "customFields" ]
		oSalario        :=  aJson[ "application" ][ "salary" ]

		if  aJson[ "salary" ]   <>   Nil
			oSalario        := 	aJson[ "salary" ] 
		endif

		if  oCentroCusto  <>   Nil
			cCentroCusto   := 	SubStr(oCentroCusto[1]['value'] , 1 , 11)
		else 
			cCentroCusto   :=  ''
		endif

		cString         :=  SUBSTR( Left( oApplication:GetJsonText( "hiringDate" ) , 10 ), 1, 4) +;
							SUBSTR( Left( oApplication:GetJsonText( "hiringDate" ) , 10 ), 6, 2) +;
							SUBSTR( Left( oApplication:GetJsonText( "hiringDate" ) , 10 ), 9, 2)

		DbselectArea( "CC2" )
		DbsetOrder( 4 )

		if CC2->( DbSeek( xFilial( "CC2" ) +  Decodeutf8(oCandidate:GetJsonText( "addressStateShortName" )) + FwNoAccent(Upper((oCandidate:GetJsonText( "addressState" )) ))) )
			cCodMun   :=  CC2->CC2_CODMUN
		endif 

		DbselectArea( "CCH" )
		DbsetOrder( 2 )

		if CCH->( DbSeek( xFilial( "CCH" ) +  Upper(Decodeutf8(oCandidate:GetJsonText( "addressCountry" ))) ))
			cCodPais   :=  Alltrim( CCH->CCH_CODIGO )
		endif 

		Reclock( cTable , .T. )

		( cTable )->SA_IDGUPY       := 	   oCandidate:GetJsonText("id")
    	( cTable )->SA_NOME         := 	   Alltrim( oCandidate:GetJsonText( "name" ) + " " + oCandidate:GetJsonText( "lastName" ))
    	( cTable )->SA_CIC          := 	   oCandidate:GetJsonText( "identificationDocument" )
    	( cTable )->SA_BIRTH        := 	   StoD( oCandidate:GetJsonText("birthdate")) 
		( cTable )->SA_SEXO   	    := 	   iif( oCandidate:GetJsonText("gender") == "Male", "M", "F" )
    	( cTable )->SA_NACIONA		:= 	   Decodeutf8( oCandidate:GetJsonText( "addressCountry" ), )
    	( cTable )->SA_ADMISSA		:= 	   StoD( cString )
    	( cTable )->SA_LOGRDSC		:=	   Decodeutf8( oCandidate:GetJsonText( "addressStreet" ), )
    	( cTable )->SA_COMPLEM		:=	   Decodeutf8( oCandidate:GetJsonText( "addressNumber" ), )
    	( cTable )->SA_ESTADO		:=	   oCandidate:GetJsonText( "addressStateShortName" )
    	( cTable )->SA_CODMUN		:=	   cCodMun
    	( cTable )->SA_CEP   		:=	   oCandidate:GetJsonText( "addressZipCode" )
    	( cTable )->SA_EMAIL 		:=	   oCandidate:GetJsonText( "email" )
    	( cTable )->SA_ENDEREC		:=	   oCandidate:GetJsonText( "addressStreet" )
    	( cTable )->SA_NUMENDE		:=	   oCandidate:GetJsonText( "addressNumber" )
    	( cTable )->SA_MOEDA 		:=	   oSalario:GetJsonText( 'currency' )
		( cTable )->SA_DTREQ		:= 	   ZNT->ZNT_DTREQ
		( cTable )->SA_CPAISOR		:= 	   cCodPais
		( cTable )->SA_CC		    := 	   cCentroCusto
		( cTable )->SA_SALARIO		:= 	   iif(oSalario <> Nil, Val(oSalario:GetJsonText( 'value' )), 0)

		MsUnlock()

    	ZNT->( DbSkip(  ) )
	end

	ZNT->( DbSkip(  ) )
end
//----------------------------- criando colunas para setar no markbrowse ----------------------------------------------

oColumn := FWBrwColumn():New()
	oColumn:SetType( "C" )
	oColumn:SetData({|| ( cTable )->SA_NOME  })
	oColumn:SetTitle( "Nome do Funcionário" )
	oColumn:SetSize( 30 )
	oColumn:SetPicture( "@!" )
aAdd(aColumns, oColumn) 

oColumn := FWBrwColumn():New()
	oColumn:SetType( "C" )
	oColumn:SetData({|| ( cTable )->SA_CIC  })
	oColumn:SetTitle( "CPF Funcionário" ) 
	oColumn:SetSize( 11 )
	oColumn:SetPicture( "@9" )
aAdd(aColumns, oColumn) 

oColumn := FWBrwColumn():New()
	oColumn:SetType( "D" )
	oColumn:SetData({|| ( cTable )->SA_BIRTH  })
	oColumn:SetTitle( "Data de Nascimento" )
	oColumn:SetSize( 8 )
	oColumn:SetPicture( "@D" )
aAdd(aColumns, oColumn) 
 
oMark := FWMarkBrowse():New()
oMark:SetAlias( cTable ) 
oMark:SetTemporary() 
oMark:SetOnlyFields({ 'SA_NOME', 'SA_CIC', 'SA_BIRTH' } )
oMark:ForceQuitButton()
oMark:DisableReport()
oMark:SetColumns( aColumns )  
oMark:SetSemaphore( .T. )
oMark:SetDescription( STR0001 )
oMark:SetFieldMark( 'SA_MARK' )	 

oMark:Activate()  

Return

/*/{Protheus.doc} MenuDef

@history 31/01/2022, Pedro Silva 

- Manipulação genérica das opções do menu.

@type function
@version  P12
@author ECR

@return 
/*/

Static Function MenuDef()

ADD OPTION aRotina TITLE "Importar para o Protheus"    ACTION "u_MarkProcess"	OPERATION 0 ACCESS 0

Return aRotina

/*/{Protheus.doc} MarkProcess

@history 31/01/2022, Pedro Silva 

- Função responsável por preparar as informações para a rotina de gravação na SRA.

@type function
@version  P12
@author ECR

@return 
/*/

User Function MarkProcess()

Local aArea     :=    GetArea()	 					as array
Local cAlias    :=    aArea[1]   					as character		
Local aAuto     :=    {}			   				as array
Local cMat		:=	  ''						    as character
Local aTipoLrgd :=    {}							as array
Local i

Aadd( aTipoLrgd, { "Rua" , "Avenida" , "Travessa" , "Rodovia" , "Praça" ,;
"Residencial" , "Via" , "Quadra" , "Passarela" , "Pátio" , "Condomínio" , "Estrada"}  )

For i := 1 to len( aTipoLrgd[1] )

	if Upper( aTipoLrgd[ 1 ] [ i ] ) $ Upper( ( cAlias )->SA_ENDEREC )

		(cAlias)->SA_ENDEREC := Alltrim( StrTran( (cAlias)->SA_ENDEREC, aTipoLrgd[ 1 ] [ i ] ) )

	endif

next i

(cAlias)->( DbGoTop() ) 
While (cAlias)->( !EOF() ) 

	While (cAlias)->( !EOF() ) .and. (cAlias)->SA_MARK <> "  " 

		cMat      :=    GetSx8Num( 'SRA', 'RA_MAT', AllTrim( cEmpAnt ) + AllTrim( cFilAnt ) )

		aAuto  :=  { {	"RA_SEXO"		, ( cAlias )->SA_SEXO      													  ,  nil },;
					{	"RA_NOME"	    , Upper(Decodeutf8(Substr(Alltrim(( cAlias )->SA_NOME) 	 , 1 , 30 )))   	  ,  nil },;
					{	"RA_CIC"    	, ( cAlias )->SA_CIC       			     									  ,  nil },;
					{	"RA_NATURAL"  	, ( cAlias )->SA_ESTADO        			 									  ,  nil },;
					{	"RA_ADMISSA"	, ( cAlias )->SA_ADMISSA   			     									  ,  nil },;  
					{	"RA_LOGRDSC"	, Upper(Alltrim(( cAlias )->SA_LOGRDSC))        						      ,  nil },;    
					{	"RA_COMPLEM"	, Substr(Alltrim(( cAlias )->SA_COMPLEM) , 1 , 30 )                           ,  nil },;
					{	"RA_NUMENDE"	, ( cAlias )->SA_NUMENDE   				 								      ,  nil },;
					{	"RA_CODMUN"	    , ( cAlias )->SA_CODMUN   				 								      ,  nil },;
					{	"RA_CEP"    	, ( cAlias )->SA_CEP       				 								      ,  nil },;
					{	"RA_ESTADO"		, ( cAlias )->SA_ESTADO    				 								      ,  nil },;
					{	"RA_LOGRNUM"	, ( cAlias )->SA_NUMENDE     			 								      ,  nil },;
					{	"RA_SALARIO"	, ( cAlias )->SA_SALARIO     			 								      ,  nil },;
					{	"RA_NASC"		, ( cAlias )->SA_BIRTH     				 								      ,  nil },;	
					{	"RA_EMAIL"		, Alltrim(( cAlias )->SA_EMAIL)     	 								      ,  nil },;
					{	"RA_MAT"		, Alltrim( cMat )     	                 								      ,  nil },;
					{	"RA_CPAISOR"	, ( cAlias )->SA_CPAISOR      	         								      ,  nil },;
					{	"RA_CC"			, ( cAlias )->SA_CC      	         									      ,  nil },;
					{	"RA_SALARIO"	, ( cAlias )->SA_SALARIO      	         					    		      ,  nil },;
					{	"RA_ENDEREC"	, Decodeutf8(Upper(Alltrim(( cAlias )->SA_ENDEREC))) 						  ,  nil }}

					GupyInclui('SRA' , 0 , 1 , aAuto , cAlias , cMat )

		(cAlias)->( Dbskip() )
	End 
	(cAlias)->( Dbskip() )
end 

RestArea( aArea )

Return 

/*/{Protheus.doc} GupyInclui

@history 31/01/2022, Pedro Silva 

- Função responsável por criar cadastro genérico de funcionários.

@type function
@version  P12
@author ECR

@return 
/*/

Static Function GupyInclui( cAlias, nReg, nOpc, aAuto , cTable , cCod )

Local aArea				:=	GetArea()
Local aSize         	:=  MsAdvSize() 
Local aButtons	    	:=  {}
//Local cOk           	:=  "{||If(!obrigatorio(aGets,aTela),nOpca := 0,nOpcA:=1),oDlg:End()}"
Local nX            	:=  0
Local bCampo     		:= 	{ | nCPO | Field( nCPO ) }
Local nPosScan			:=	0

Private aMemos			:= 	{}
Private aRotina 		:= 	{ { 'STR0003',  ""  , 0 , 3}}
PRIVATE oGetd
PRIVATE aTela[0][0]
PRIVATE aGets[0]
Private cCadastro		:= 	'Atualização Funcionários - Integração Gupy'	

Default cAlias        	:=  'SRA'
Default nReg          	:=  0
Default nOpc          	:=  1
Default	aAuto			:=	{}

dbSelectArea( cAlias )
dbSetOrder(1)
( cAlias )->( DBGOTOP())

For nX := 1 to FCount() 
	M->&(Field(nX)):= FieldGet(nX)
	lInit := .F.
	If ExistIni(EVAL(bCampo,nX))
		lInit := .T.
		M->&(EVAL(bCampo,nX)):= InitPad(SX3->X3_RELACAO)
		If ValType(M->&(EVAL(bCampo,nX))) == "C"
			M->&(EVAL(bCampo,nX)):= PADR(M->&(EVAL(bCampo,nX)),SX3->X3_TAMANHO)

		Endif

		If M->&(EVAL(bCampo,nX)) == NIL
			lInit := .F.

		EndIf
	EndIf

	If !lInit
		IF ValType(M->&(EVAL(bCampo,nX))) == "C"
			M->&(EVAL(bCampo,nX)) := SPACE(LEN(M->&(EVAL(bCampo,nX))))

		ElseIf ValType(M->&(EVAL(bCampo,nX))) == "N"
			M->&(EVAL(bCampo,nX)) := 0

		ElseIf ValType(M->&(EVAL(bCampo,nX))) == "D"
			If ! "_DATA" $ Trim(EVAL(bCampo,nX))
				M->&(EVAL(bCampo,nX)) := dDataBase

			Else
				M->&(EVAL(bCampo,nX)) := cTod("  /  /  ")

			Endif	

		ElseIf ValType(M->&(EVAL(bCampo,nX))) == "L"
			M->&(EVAL(bCampo,nX)) := .F.

		EndIf
	EndIf

	If Len( aAuto ) > 0
		nPosScan	:=	aScan( aAuto, { | aX | aX[ 1 ] == Field( nX ) } )
		If nPosScan > 0
			M->&(EVAL(bCampo,nX)) := aAuto[ nPosScan, 2 ]
			
		EndIf

	EndIf
Next nX

aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } ) 
//AAdd( aObjects, { 100,  60, .T., .T. } )
aInfo := { aSize[1],aSize[2],aSize[3],aSize[4],3,3 }
aObj  := MsObjSize( aInfo, aObjects, .T. ) 

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL 
EnChoice( cAlias, nReg, nOpc, , , , , aObj[1], , 3 )
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||Seek( aAuto , cTable , cCod , oDlg)},{||Sair( @oDlg , cTable )},,aButtons)

RestArea( aArea )
Return

/*/{Protheus.doc} Seek

@history 31/01/2022, Pedro Silva 

- Função responsável por verificar campos obrigatórios, atualizar status de processamento 
e verificar se o CPF já está cadastrado no sistema. 

@type function
@version  P12
@author ECR

@return 
/*/


Static Function Seek( aDados as array, cTemp as character , cCod as character , oDlg as object)

DbSelectarea( "SRA" )
SRA->( dbsetorder( 5 ) )

If !obrigatorio(aGets,aTela)

	RollBackSX8()
Else
	if SRA->( dbseek( xfilial( "SRA" ) + aDados[3][2] ) )

		RollBackSX8()
		MsgStop( "CPF já cadastrado, verifique por favor." , "Erro")  
	else  

		ZNT->( Dbseek( Fwcodfil() + Alltrim(( cTemp )->SA_DTREQ )) ) 

		RecLock( "ZNT" , .F. )
		ZNT->ZNT_STATUS  := "2"
		ZNT->ZNT_MSGSTA  := "Integrado com sucesso"
		ZNT->ZNT_IDPRT   := cCod
		ZNT->ZNT_DTPRTS  :=  FWTimeStamp( 5 )
		ZNT->( MsUnlock() )
																													
		GupyGrava()
		MsgInfo( "Salvo com sucesso!", "Integração de funcionários")
		aRotina  :=  aRotClone
		( cTemp )->SA_MARK := '  '
		ConfirmSX8()
		oMark:Refresh()
		oDlg:end()
	endif 
endif 

Return 

/*/{Protheus.doc} Sair

@history 31/01/2022, Pedro Silva 

- Função responsável por sair da tela e desmarcar opções.

@type function
@version  P12
@author ECR

@return 
/*/

Static Function Sair( oDlg as object , cTable as character )

Local aAreaSRA  	    :=  SRA->( GetArea() )	 				as array

oDlg:End()
RollBackSX8()
aRotina  :=  aRotClone
( cTable )->SA_MARK := '  '

RestArea( aAreaSRA )

Return aRotina

/*/{Protheus.doc} GupyGrava

@history 31/01/2022, Pedro Silva 

- Função responsável por gravar as informações do cadastro genérico.

@type function
@version  P12
@author ECR

@return 
/*/

Static Function GupyGrava()
Local 	bCampo 		:= 	{|nCPO| Field(nCPO) }
Local 	i  			:= 	0 
Local 	nSaveSX8   	:= 	GetSx8Len()

RecLock("SRA", .T. ) 

For i := 1 TO FCount()
	If "FILIAL"$Field(i)
		FieldPut(i,xFilial())
	Else
		FieldPut(i,M->&(EVAL(bCampo,i)))
	EndIf
Next i
	
SRA->(MsUnLock())

SRA->(FkCommit())
Begin Transaction	

	While( GetSx8Len() > nSaveSx8 )
		ConfirmSX8()

	End
	EvalTrigger()

End Transaction

Return 
