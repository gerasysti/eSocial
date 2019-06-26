UPDATE OR INSERT INTO ESOCIAL_TIPO_DEPENDENTE (CODIGO, DESCRICAO)
                                       VALUES ('01', 'C�njuge')
                                     MATCHING (CODIGO);
UPDATE OR INSERT INTO ESOCIAL_TIPO_DEPENDENTE (CODIGO, DESCRICAO)
                                       VALUES ('02', 'Companheiro(a) com o(a) qual tenha filho ou viva h� mais de 5 (cinco) anos ou possua Declara��o de Uni�o Est�vel')
                                     MATCHING (CODIGO);
UPDATE OR INSERT INTO ESOCIAL_TIPO_DEPENDENTE (CODIGO, DESCRICAO)
                                       VALUES ('03', 'Filho(a) ou enteado(a)')
                                     MATCHING (CODIGO);
UPDATE OR INSERT INTO ESOCIAL_TIPO_DEPENDENTE (CODIGO, DESCRICAO)
                                       VALUES ('04', 'Filho(a) ou enteado(a), universit�rio(a) ou cursando escola t�cnica de 2� grau')
                                     MATCHING (CODIGO);
UPDATE OR INSERT INTO ESOCIAL_TIPO_DEPENDENTE (CODIGO, DESCRICAO)
                                       VALUES ('06', 'Irm�o(�), neto(a) ou bisneto(a) sem arrimo dos pais, do(a) qual detenha a guarda judicial')
                                     MATCHING (CODIGO);
UPDATE OR INSERT INTO ESOCIAL_TIPO_DEPENDENTE (CODIGO, DESCRICAO)
                                       VALUES ('07', 'Irm�o(�), neto(a) ou bisneto(a) sem arrimo dos pais, universit�rio(a) ou cursando escola t�cnica de 2� grau, do(a) qual detenha a guarda judicial')
                                     MATCHING (CODIGO);
UPDATE OR INSERT INTO ESOCIAL_TIPO_DEPENDENTE (CODIGO, DESCRICAO)
                                       VALUES ('09', 'Pais, av�s e bisav�s')
                                     MATCHING (CODIGO);
UPDATE OR INSERT INTO ESOCIAL_TIPO_DEPENDENTE (CODIGO, DESCRICAO)
                                       VALUES ('10', 'Menor pobre do qual detenha a guarda judicial')
                                     MATCHING (CODIGO);
UPDATE OR INSERT INTO ESOCIAL_TIPO_DEPENDENTE (CODIGO, DESCRICAO)
                                       VALUES ('11', 'A pessoa absolutamente incapaz, da qual seja tutor ou curador')
                                     MATCHING (CODIGO);
UPDATE OR INSERT INTO ESOCIAL_TIPO_DEPENDENTE (CODIGO, DESCRICAO)
                                       VALUES ('12', 'Ex-c�njuge')
                                     MATCHING (CODIGO);
UPDATE OR INSERT INTO ESOCIAL_TIPO_DEPENDENTE (CODIGO, DESCRICAO)
                                       VALUES ('99', 'Agregado/Outros')
                                     MATCHING (CODIGO);

COMMIT WORK;
