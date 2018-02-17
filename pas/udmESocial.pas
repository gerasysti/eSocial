unit udmESocial;

interface

uses
  udmPrincipal,
  ConfigurarCertificado,

  ACBrDFeConfiguracoes,
  ACBrBase,
  ACBrDFe,
  ACBrUtil,
  ACBreSocial,
  ACBrMail,
  ACBrDFeSSL,
  ACBrDFeOpenSSL,
  ACBreSocialWebServices,
  ACBrIntegrador,
  pcesConversaoeSocial,
  pcnConversao,

  TypInfo,
  synacode,
  blcksock,
  FileCtrl,
  StrUtils,
  Math,
  IniFiles,
  Windows,
  Forms,
  Dialogs,

  System.SysUtils, System.Classes, Controls, Vcl.StdCtrls, Vcl.Samples.Gauges,
  Data.FMTBcd, Data.SqlExpr, Data.DB, Datasnap.DBClient, Datasnap.Provider;

type
  TTipoOperacao = (toInclusao, toAlteracao, toExclusao);
//  TAnoMes = class
//    private
//      aAno : Integer;
//      aMes : Integer;
//    public
//      property Ano : Integer read aAno write aAno;
//      property Mes : Integer read aMes write aMes;
//  end;

  TdmESocial = class(TDataModule)
    ACBrESocial: TACBreSocial;
    ACBrIntegrador: TACBrIntegrador;
    ACBrMail: TACBrMail;
    dspTabela: TDataSetProvider;
    cdsTabela: TClientDataSet;
    qryTabela: TSQLQuery;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure btnSalvar(Sender: TObject);
  private
    { Private declarations }
    aForm : TfrmConfigurarCertificado;
    procedure AtualizaSSLLibsCombo;
    procedure GravarConfiguracao;
    procedure SetSQL(aSQL : TStringList);
  public
    { Public declarations }
    procedure ListarCompetencias(aLista : TComboBox);
    procedure LerConfiguracao;

    function CertificadoInstalado : Boolean;
    function CertificadoValido : Boolean;

    // procedures eventos de tabela
    function Gerar_eSocial1000(aCompetencia : String; aModoLancamento : TModoLancamento; aLabel : TLabel; aProcesso : TGauge) : Boolean;
    function Gerar_eSocial1005(aCompetencia : String; aModoLancamento : TModoLancamento; aLabel : TLabel; aProcesso : TGauge) : Boolean; virtual; abstract;
    function Gerar_eSocial1010(aCompetencia : String; aModoLancamento : TModoLancamento; aLabel : TLabel; aProcesso : TGauge) : Boolean; virtual; abstract;
    function Gerar_eSocial1020(aCompetencia : String; aModoLancamento : TModoLancamento; aLabel : TLabel; aProcesso : TGauge) : Boolean; virtual; abstract;
    function Gerar_eSocial1030(aCompetencia : String; aModoLancamento : TModoLancamento; aLabel : TLabel; aProcesso : TGauge) : Boolean; virtual; abstract;
    function Gerar_eSocial1035(aCompetencia : String; aModoLancamento : TModoLancamento; aLabel : TLabel; aProcesso : TGauge) : Boolean; virtual; abstract;
    function Gerar_eSocial1040(aCompetencia : String; aModoLancamento : TModoLancamento; aLabel : TLabel; aProcesso : TGauge) : Boolean; virtual; abstract;
    function Gerar_eSocial1050(aCompetencia : String; aModoLancamento : TModoLancamento; aLabel : TLabel; aProcesso : TGauge) : Boolean; virtual; abstract;
    function Gerar_eSocial1060(aCompetencia : String; aModoLancamento : TModoLancamento; aLabel : TLabel; aProcesso : TGauge) : Boolean; virtual; abstract;
    function Gerar_eSocial1070(aCompetencia : String; aModoLancamento : TModoLancamento; aLabel : TLabel; aProcesso : TGauge) : Boolean; virtual; abstract;
    function Gerar_eSocial1080(aCompetencia : String; aModoLancamento : TModoLancamento; aLabel : TLabel; aProcesso : TGauge) : Boolean; virtual; abstract;

    function ConfigurarCertificado(const AOwner : TComponent) : Boolean;
    function EventoEnviado_eSocial(aGrupo : TeSocialGrupo; aCompetencia : String; aLabel : TLabel; aProcesso : TGauge) : Boolean;
  end;

var
  dmESocial: TdmESocial;

  procedure ShowInforme(aTitulo, aMensagem : String);

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses
  VarGlobais, gsLib, UtilsDb;

{$R *.dfm}

procedure ShowInforme(aTitulo, aMensagem : String);
begin
  Application.MessageBox(PChar(aMensagem), PChar(aTitulo), MB_ICONINFORMATION);
end;

procedure TdmESocial.AtualizaSSLLibsCombo;
begin
  if Assigned(aForm) then
    with aForm do
    begin
      cbSSLLib.ItemIndex     := Integer(ACBrESocial.Configuracoes.Geral.SSLLib);
      cbCryptLib.ItemIndex   := Integer(ACBrESocial.Configuracoes.Geral.SSLCryptLib);
      cbHttpLib.ItemIndex    := Integer(ACBrESocial.Configuracoes.Geral.SSLHttpLib);
      cbXmlSignLib.ItemIndex := Integer(ACBrESocial.Configuracoes.Geral.SSLXmlSignLib);

      cbSSLType.Enabled := (ACBrESocial.Configuracoes.Geral.SSLHttpLib in [httpWinHttp, httpOpenSSL]);
    end;
end;

procedure TdmESocial.btnSalvar(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    GravarConfiguracao;
    LerConfiguracao;
  finally
    Screen.Cursor := crDefault;
  end;
end;

function TdmESocial.CertificadoInstalado: Boolean;
begin
  if Assigned(ACBrESocial.Configuracoes.Certificados) then
    Result := (Trim(ACBrESocial.Configuracoes.Certificados.NumeroSerie) <> EmptyStr)
  else
    Result := False;
end;

function TdmESocial.CertificadoValido: Boolean;
begin
  if Assigned(ACBrESocial.Configuracoes.Certificados) then
    Result := ACBrESocial.Configuracoes.Certificados.VerificarValidade
  else
    Result := False;
end;

function TdmESocial.ConfigurarCertificado(const AOwner: TComponent): Boolean;
begin
  if not Assigned(aForm) then
    aForm := TfrmConfigurarCertificado.Create(AOwner);

  try
    LerConfiguracao;
    Result := (aForm.ShowModal = mrOk);
  finally
  end;
end;

procedure TdmESocial.DataModuleCreate(Sender: TObject);
begin
  aForm := TfrmConfigurarCertificado.Create(Self);
  aForm.btnSalvarConfig.OnClick := btnSalvar;

  ACBrIntegrador.PastaInput  := ExtractFilePath(ParamStr(0)) + 'Integra\In\';
  ACBrIntegrador.PastaOutput := ExtractFilePath(ParamStr(0)) + 'Integra\Out\';
  ACBrIntegrador.ArqLOG      := ExtractFilePath(ParamStr(0)) + 'Integra_log_' + FormatDateTime('yyyymmdd".txt"', Now);

  if not DirectoryExists(ACBrIntegrador.PastaInput) then
    ForceDirectories(ACBrIntegrador.PastaInput);
  if not DirectoryExists(ACBrIntegrador.PastaOutput) then
    ForceDirectories(ACBrIntegrador.PastaOutput);
end;

procedure TdmESocial.DataModuleDestroy(Sender: TObject);
begin
  if Assigned(aForm) then
    FreeAndNil(aForm);
end;

function TdmESocial.EventoEnviado_eSocial(aGrupo: TeSocialGrupo;
  aCompetencia: String; aLabel: TLabel; aProcesso: TGauge): Boolean;
var
  aRetorno : Boolean;
begin
  aRetorno := False;
  try
    ACBrESocial.Eventos.TipoEmpregador := ACBrESocial.Configuracoes.Geral.TipoEmpregador;
    ACBrESocial.Eventos.GerarXMLs;
    ACBrESocial.Eventos.SaveToFiles;
    ACBrESocial.AssinarEventos;

    aRetorno := ACBrESocial.Enviar(aGrupo);
    Sleep(3000);
  finally
    Result := aRetorno;
  end;
end;

function TdmESocial.Gerar_eSocial1000(aCompetencia: String; aModoLancamento : TModoLancamento;
  aLabel: TLabel; aProcesso: TGauge): Boolean;
var
  aRetorno : Boolean;
  aSQL : TStringList;
begin
  aRetorno := False;
  aSQL := TStringList.Create;
  try
    aSQL.BeginUpdate;
    aSQL.Clear;
    aSQL.Add('Select *');
    aSQL.Add('from CONFIG_ORGAO c');
    aSQL.Add('where c.id = 1');
    aSQL.EndUpdate;
    SetSQL(aSQL);

    cdsTabela.First;
    while not cdsTabela.Eof do
    begin
      with ACBrESocial.Eventos.Iniciais.S1000.Add do
      begin
        // So tem na Vers�o 2.4.1
        // taProducao, taProducaoRestrita
        evtInfoEmpregador.Sequencial      := 0;
        evtInfoEmpregador.IdeEvento.TpAmb := taProducaoRestrita;

        evtInfoEmpregador.IdeEvento.ProcEmi := peAplicEmpregador;
        evtInfoEmpregador.IdeEvento.VerProc := '1.0';

        evtInfoEmpregador.IdeEmpregador.TpInsc := tiCNPJ;
        evtInfoEmpregador.IdeEmpregador.NrInsc := Trim(aForm.edtIdEmpregador.Text);

        evtInfoEmpregador.ModoLancamento := aModoLancamento;
        evtInfoEmpregador.InfoEmpregador.IdePeriodo.IniValid := aCompetencia;
        evtInfoEmpregador.InfoEmpregador.IdePeriodo.FimValid := '2099-12';

        with evtInfoEmpregador.InfoEmpregador.InfoCadastro do
        begin
          NmRazao   := Criptografa(cdsTabela.FieldByName('RAZAO_SOCIAL').AsString, '2', 60);
          ClassTrib := ct01;
//          if Checb_ZeraBase.Checked then
//          Begin
//            NmRazao := 'RemoverEmpregadorDaBaseDeDadosDaProducaoRestrita';
//            ClassTrib := ct00;
//          End
//          else
//          Begin
//            NmRazao := 'Empresa Teste';
//            ClassTrib := ct01;
//          End;
//
//          NatJurid    := '0001';
//          IndCoop     := TpIndCoop(1);
//          IndConstr   := TpIndConstr(2);
//          IndDesFolha := TpIndDesFolha(1);
//          IndOptRegEletron := TpIndOptRegEletron(1);
//          IndEtt      := tpSimNao(1);
//          nrRegEtt    := '';
//
//          InfoOp.nrSiafi := '12345';
//
//          InfoOp.infoEnte.nmEnte    := 'Ente federativo teste';
//          InfoOp.infoEnte.uf        := tpuf(ufSP);
//          InfoOp.infoEnte.vrSubteto := 100.00;
//
//          dadosIsencao.IdeMinLei    := 'Sigla Min';
//          dadosIsencao.NrCertif     := '1111';
//          dadosIsencao.DtEmisCertif := date;
//          dadosIsencao.DtVencCertif := date;
//          dadosIsencao.NrProtRenov  := '10';
//          dadosIsencao.DtProtRenov  := date;
//          dadosIsencao.DtDou        := date;
//          dadosIsencao.PagDou       := '111';
//
//          Contato.NmCtt    := 'Contato 1';
//          Contato.CpfCtt   := '00000222220';
//          Contato.FoneFixo := '34335856';
//          Contato.FoneCel  := '991524587';
//          Contato.email    := 'testecontato@testecontato.com';
//
          InfoOrgInternacional.IndAcordoIsenMulta := iaiSemacordo;  // (iaiSemacordo, iaiComacordo);
        end;

        evtInfoEmpregador.InfoEmpregador.InfoCadastro.SoftwareHouse.Clear;

        with evtInfoEmpregador.InfoEmpregador.InfoCadastro.SoftwareHouse.Add do
        begin
          CnpjSoftHouse := '11122050000168';
          NmRazao  := 'GERASYS TECNOINFO LTDA - ME';
          NmCont   := 'Gerson Farias';
          Telefone := '94981194915';
          email    := 'gerasys.ti.adm@gmail.com';
        end;

        with evtInfoEmpregador.InfoEmpregador.InfoCadastro.InfoComplementares do
        begin
          SituacaoPJ.IndSitPJ := isPJSitNormal;
          SituacaoPF.IndSitPF := isPFSitNormal;
        end;

        evtInfoEmpregador.InfoEmpregador.NovaValidade.IniValid := aCompetencia;
        evtInfoEmpregador.InfoEmpregador.NovaValidade.FimValid := '2099-12';
      end;

      cdsTabela.Next;
    end;

    aRetorno := True;
  finally
    aSQL.Free;
    Result := aRetorno;
  end;
end;

procedure TdmESocial.GravarConfiguracao;
var
  IniFile: String;
  Ini: TIniFile;
begin
  IniFile := ExtractFilePath(ParamStr(0)) + 'Certificado.ini'; //REMUNERATUS_INI;

  Ini := TIniFile.Create(IniFile);
  try
    with aForm do
    begin
      Ini.WriteInteger('Certificado', 'SSLLib',     cbSSLLib.ItemIndex);
      Ini.WriteInteger('Certificado', 'CryptLib',   cbCryptLib.ItemIndex);
      Ini.WriteInteger('Certificado', 'HttpLib',    cbHttpLib.ItemIndex);
      Ini.WriteInteger('Certificado', 'XmlSignLib', cbXmlSignLib.ItemIndex);
      Ini.WriteString ('Certificado', 'Caminho',  edtCaminho.Text);
      Ini.WriteString ('Certificado', 'Senha',    edtSenha.Text);
      Ini.WriteString ('Certificado', 'NumSerie', edtNumSerie.Text);

      Ini.WriteBool   ('Geral', 'AtualizarXML', ckSalvar.Checked);
      Ini.WriteBool   ('Geral', 'ExibirErroSchema', ckSalvar.Checked);
      Ini.WriteString ('Geral', 'FormatoAlerta', edtFormatoAlerta.Text);
      Ini.WriteInteger('Geral', 'VersaoDF', cbVersaoDF.ItemIndex);
      Ini.WriteBool   ('Geral', 'RetirarAcentos', cbxRetirarAcentos.Checked);
      Ini.WriteBool   ('Geral', 'Salvar', ckSalvar.Checked);
      Ini.WriteString ('Geral', 'PathSalvar', edtPathLogs.Text);
      Ini.WriteString ('Geral', 'PathSchemas', edtPathSchemas.Text);
      Ini.WriteString ('Geral', 'IdEmpregador', edtIdEmpregador.Text);
      Ini.WriteString ('Geral', 'IdTransmissor', edtIdTransmissor.Text);
      Ini.WriteInteger('Geral', 'TipoEmpregador', cbTEmpregador.ItemIndex);

      Ini.WriteInteger('WebService', 'Ambiente', rgTipoAmb.ItemIndex);
      Ini.WriteBool   ('WebService', 'Visualizar', cbxVisualizar.Checked);
      Ini.WriteBool   ('WebService', 'SalvarSOAP', cbxSalvarSOAP.Checked);
      Ini.WriteBool   ('WebService', 'AjustarAut', cbxAjustarAut.Checked);
      Ini.WriteString ('WebService', 'Aguardar', edtAguardar.Text);
      Ini.WriteString ('WebService', 'Tentativas', edtTentativas.Text);
      Ini.WriteString ('WebService', 'Intervalo', edtIntervalo.Text);
      Ini.WriteInteger('WebService', 'TimeOut', seTimeOut.Value);
      Ini.WriteInteger('WebService', 'SSLType', cbSSLType.ItemIndex);

      Ini.WriteString('Proxy', 'Host',  edtProxyHost.Text);
      Ini.WriteString('Proxy', 'Porta', edtProxyPorta.Text);
      Ini.WriteString('Proxy', 'User',  edtProxyUser.Text);
      Ini.WriteString('Proxy', 'Pass',  edtProxySenha.Text);

      Ini.WriteBool  ('Arquivos', 'Salvar',      cbxSalvarArqs.Checked);
      Ini.WriteBool  ('Arquivos', 'PastaMensal', cbxPastaMensal.Checked);
      Ini.WriteBool  ('Arquivos', 'AddLiteral',  cbxAdicionaLiteral.Checked);
      Ini.WriteBool  ('Arquivos', 'EmissaoPatheSocial', cbxEmissaoPatheSocial.Checked);
      Ini.WriteBool  ('Arquivos', 'SalvarPathEvento', cbxSalvaPathEvento.Checked);
      Ini.WriteBool  ('Arquivos', 'SepararPorCNPJ', cbxSepararPorCNPJ.Checked);
      Ini.WriteString('Arquivos', 'PatheSocial', edtPatheSocial.Text);
      Ini.WriteString('Arquivos', 'PathEvento', edtPathEvento.Text);
    end;
  finally
    Ini.Free;
  end;
end;

procedure TdmESocial.LerConfiguracao;
var
  IniFile   ,
  PathMensal,
  aSufixo   : String;
  Ini : TIniFile;
begin
  Screen.Cursor := crHourGlass;

  aSufixo := Pesquisa('CONFIG_ORGAO', 'ID', '1', 'COD_CLI_RH_TRANSP','');
  IniFile := ExtractFilePath(ParamStr(0)) + 'Certificado.ini'; //REMUNERATUS_INI;
  Ini     := TIniFile.Create(IniFile);

  try
    with aForm do
    begin
      cbSSLLib.ItemIndex     := Ini.ReadInteger('Certificado', 'SSLLib',     Ord(libCustom));
      cbCryptLib.ItemIndex   := Ini.ReadInteger('Certificado', 'CryptLib',   Ord(cryWinCrypt));
      cbHttpLib.ItemIndex    := Ini.ReadInteger('Certificado', 'HttpLib',    Ord(httpWinHttp));
      cbXmlSignLib.ItemIndex := Ini.ReadInteger('Certificado', 'XmlSignLib', Ord(xsLibXml2));
      edtCaminho.Text        := Ini.ReadString ('Certificado', 'Caminho',  '');
      edtSenha.Text          := Ini.ReadString ('Certificado', 'Senha',    '');
      edtNumSerie.Text       := Ini.ReadString ('Certificado', 'NumSerie', '');

      ACBrESocial.Configuracoes.Certificados.ArquivoPFX  := edtCaminho.Text;
      ACBrESocial.Configuracoes.Certificados.Senha       := edtSenha.Text;
      ACBrESocial.Configuracoes.Certificados.NumeroSerie := edtNumSerie.Text;

      cbxExibirErroSchema.Checked := Ini.ReadBool   ('Geral', 'ExibirErroSchema', True);
      edtFormatoAlerta.Text       := Ini.ReadString ('Geral', 'FormatoAlerta', 'TAG:%TAGNIVEL% ID:%ID%/%TAG%(%DESCRICAO%) - %MSG%.');
      cbVersaoDF.ItemIndex        := Ini.ReadInteger('Geral', 'VersaoDF', 0);
      ckSalvar.Checked            := Ini.ReadBool('Geral', 'Salvar', True);
      cbxRetirarAcentos.Checked   := Ini.ReadBool('Geral', 'RetirarAcentos', True);
      edtIdEmpregador.Text        := Ini.ReadString ('Geral', 'IdEmpregador', Pesquisa('CONFIG_ORGAO', 'ID', '1', 'CNPJ',''));
      edtIdTransmissor.Text       := Ini.ReadString ('Geral', 'IdTransmissor', '');
      cbTEmpregador.ItemIndex     := Ini.ReadInteger('Geral', 'TipoEmpregador', 0);

      if (Trim(edtIdEmpregador.Text) = EmptyStr) then
        edtIdEmpregador.Text := Criptografa(Pesquisa('CONFIG_ORGAO', 'ID', '1', 'CNPJ',''), '2', 14);

      ACBrESocial.SSL.DescarregarCertificado;

      with ACBrESocial.Configuracoes.Geral do
      begin
        SSLLib        := TSSLLib(cbSSLLib.ItemIndex);
        SSLCryptLib   := TSSLCryptLib(cbCryptLib.ItemIndex);
        SSLHttpLib    := TSSLHttpLib(cbHttpLib.ItemIndex);
        SSLXmlSignLib := TSSLXmlSignLib(cbXmlSignLib.ItemIndex);

        AtualizaSSLLibsCombo;

        ExibirErroSchema := cbxExibirErroSchema.Checked;
        RetirarAcentos   := cbxRetirarAcentos.Checked;
        FormatoAlerta    := edtFormatoAlerta.Text;
        VersaoDF         := TVersaoeSocial(cbVersaoDF.ItemIndex);
        Salvar           := ckSalvar.Checked;

        IdEmpregador   := edtIdEmpregador.Text;
        IdTransmissor  := edtIdTransmissor.Text;
        TipoEmpregador := TEmpregador(cbTEmpregador.ItemIndex);
      end;

      rgTipoAmb.ItemIndex   := Ini.ReadInteger('WebService', 'Ambiente',   0);
      cbxVisualizar.Checked := Ini.ReadBool   ('WebService', 'Visualizar', False);
      cbxSalvarSOAP.Checked := Ini.ReadBool   ('WebService', 'SalvarSOAP', False);
      cbxAjustarAut.Checked := Ini.ReadBool   ('WebService', 'AjustarAut', False);
      edtAguardar.Text      := Ini.ReadString ('WebService', 'Aguardar',   '0');
      edtTentativas.Text    := Ini.ReadString ('WebService', 'Tentativas', '5');
      edtIntervalo.Text     := Ini.ReadString ('WebService', 'Intervalo',  '0');
      seTimeOut.Value       := Ini.ReadInteger('WebService', 'TimeOut',    5000);
      cbSSLType.ItemIndex   := Ini.ReadInteger('WebService', 'SSLType',    0);

      edtProxyHost.Text  := Ini.ReadString('Proxy', 'Host',  '');
      edtProxyPorta.Text := Ini.ReadString('Proxy', 'Porta', '');
      edtProxyUser.Text  := Ini.ReadString('Proxy', 'User',  '');
      edtProxySenha.Text := Ini.ReadString('Proxy', 'Pass',  '');

      with ACBrESocial.Configuracoes.WebServices do
      begin
        Ambiente   := taHomologacao;
        Visualizar := cbxVisualizar.Checked;
        Salvar     := cbxSalvarSOAP.Checked;

        AjustaAguardaConsultaRet := cbxAjustarAut.Checked;

        if NaoEstaVazio(edtAguardar.Text) then
          AguardarConsultaRet := ifThen(StrToInt(edtAguardar.Text) < 1000,
            StrToInt(edtAguardar.Text) * 1000, StrToInt(edtAguardar.Text))
        else
          edtAguardar.Text := IntToStr(AguardarConsultaRet);

        if NaoEstaVazio(edtTentativas.Text) then
          Tentativas := StrToInt(edtTentativas.Text)
        else
          edtTentativas.Text := IntToStr(Tentativas);

        if NaoEstaVazio(edtIntervalo.Text) then
          IntervaloTentativas := ifThen(StrToInt(edtIntervalo.Text) < 1000,
            StrToInt(edtIntervalo.Text) * 1000, StrToInt(edtIntervalo.Text))
        else
          edtIntervalo.Text := IntToStr(ACBrESocial.Configuracoes.WebServices.IntervaloTentativas);

        TimeOut   := seTimeOut.Value;
        ProxyHost := edtProxyHost.Text;
        ProxyPort := edtProxyPorta.Text;
        ProxyUser := edtProxyUser.Text;
        ProxyPass := edtProxySenha.Text;
      end;

      ACBrESocial.SSL.SSLType := TSSLType(cbSSLType.ItemIndex);

      cbxSalvarArqs.Checked         := Ini.ReadBool('Arquivos', 'Salvar', False);
      cbxPastaMensal.Checked        := Ini.ReadBool('Arquivos', 'PastaMensal', False);
      cbxAdicionaLiteral.Checked    := Ini.ReadBool('Arquivos', 'AddLiteral', False);
      cbxEmissaoPatheSocial.Checked := Ini.ReadBool('Arquivos', 'EmissaoPatheSocial', False);
      cbxSalvaPathEvento.Checked    := Ini.ReadBool('Arquivos', 'SalvarPathEvento', False);
      cbxSepararPorCNPJ.Checked     := Ini.ReadBool('Arquivos', 'SepararPorCNPJ', False);
      edtPatheSocial.Text := Ini.ReadString('Arquivos', 'PatheSocial', '');
      edtPathEvento.Text  := Ini.ReadString('Arquivos', 'PathEvento', '');
      edtPathLogs.Text    := Ini.ReadString('Geral', 'PathSalvar', PathWithDelim(ExtractFilePath(ParamStr(0))) + 'Logs');
      edtPathSchemas.Text := Ini.ReadString('Geral', 'PathSchemas', PathWithDelim(ExtractFilePath(ParamStr(0))) + 'Schemas\' + GetEnumName(TypeInfo(TVersaoeSocial), Integer(cbVersaoDF.ItemIndex)));

      with ACBrESocial.Configuracoes.Arquivos do
      begin
        Salvar             := cbxSalvarArqs.Checked;
        SepararPorMes      := cbxPastaMensal.Checked;
        AdicionarLiteral   := cbxAdicionaLiteral.Checked;
        EmissaoPatheSocial := cbxEmissaoPatheSocial.Checked;
        SepararPorCNPJ     := cbxSepararPorCNPJ.Checked;
        PathSalvar  := edtPathLogs.Text;
        PathSchemas := edtPathSchemas.Text;
        PatheSocial := edtPatheSocial.Text;
      end;

      PathMensal := ACBrESocial.Configuracoes.Arquivos.GetPatheSocial(0);

      ACBrESocial.Configuracoes.Arquivos.PathSalvar := PathMensal;

      if not DirectoryExists(edtPathLogs.Text) then
        ForceDirectories(edtPathLogs.Text);
      if not DirectoryExists(edtPathSchemas.Text) then
        ForceDirectories(edtPathSchemas.Text);
    end;
  finally
    Ini.Free;
    Screen.Cursor := crDefault;
  end;
end;

procedure TdmESocial.ListarCompetencias(aLista: TComboBox);
var
  x ,
  i : Integer;
  s : String;
begin
  x := 0;
  s := FormatDateTime('YYYY', Date);
  aLista.Items.BeginUpdate;
  aLista.Items.Clear;
  try
    for I := 1 to 12 do
    begin
      aLista.Items.Add(s + ' - ' + FormatFloat('00', I));
      if (I = StrToInt(FormatDateTime('mm', Date)) ) then
        x := aLista.Items.Count - 1;
    end;
  finally
    aLista.Items.EndUpdate;
    aLista.ItemIndex := x;
  end;
end;

procedure TdmESocial.SetSQL(aSQL: TStringList);
begin
  if cdsTabela.Active then
    cdsTabela.Close;

  qryTabela.SQL.BeginUpdate;
  qryTabela.SQL.Clear;
  try
    qryTabela.SQL.AddStrings(aSQL);
  finally
    qryTabela.SQL.EndUpdate;
    cdsTabela.FetchParams;
    cdsTabela.Open;
  end;
end;

end.
