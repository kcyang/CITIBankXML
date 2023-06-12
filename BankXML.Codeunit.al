codeunit 58150 BankXML
{
    Permissions = tabledata "XML Interface Log" = RMID;

    var
        GVRE_GenJournalLine: Record "Gen. Journal Line";
        GVOS_OutputStream: OutStream;
        GVOS_InputStream: InStream;
        GVTX_XMLName: Text;
        Text0001: Label 'Payment Jnl. XML file is exported (%1)';
        GVTX_Path: Text;
        GVBO_IsExported: Boolean;
        GVRE_XMLInterfaceLog: Record "XML Interface Log";
        Text0002: Label 'The Export Failed';
        TempBlob: Codeunit "Temp Blob";
        base64Convert: Codeunit "Base64 Convert";
        jsonBody: Text;
        httpClient: HttpClient;
        httpContent: HttpContent;
        httpResponse: HttpResponseMessage;
        httpRequest: HttpRequestMessage;
        httpHeader: HttpHeaders;
        respText: Text;


    procedure GVFN_ExportData(var PAR_Options: Integer)
    begin

        CASE PAR_Options OF
            1:
                BEGIN
                    //MESSAGE( FORMAT(TIME,5));
                    GVRE_GenJournalLine.RESET;

                    GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine."Journal Template Name", 'PAYMENTS');
                    GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine."Journal Batch Name", 'CITI');
                    GVRE_GenJournalLine.SetFilter(GVRE_GenJournalLine."XML Export Completion", '%1', FALSE);
                    GVRE_GenJournalLine.CalcFields("Bank Transfer Type");
                    GVRE_GenJournalLine.SetFilter(GVRE_GenJournalLine."Bank Transfer Type", 'DOMESTIC');
                    IF NOT GVRE_GenJournalLine.FIND('-') THEN BEGIN
                        ERROR('No lines to export');
                    END;

                    GVTX_XMLName := 'GUERBET.NC4.IMPORT_ACK.JP1' + FORMAT(TODAY, 0, '<Year,2><Month,2><Day,2>') + DELCHR(FORMAT(TIME, 4, '<Hours24><Minutes,2><Seconds,2>'), '=', ':') + '57' +
                              '.PY_BULK.' + '53_ROPE' + '.NULL.NULL.TXT';
                    TempBlob.CreateOutStream(GVOS_OutputStream);
                    GVBO_IsExported := XMLPORT.EXPORT(XMLPORT::BankXML_53_ROPE, GVOS_OutputStream);
                    TempBlob.CreateInStream(GVOS_InputStream);
                    CopyStream(GVOS_OutputStream, GVOS_InputStream);
                    //파일로 내려받는 부분 삭제.
                    //DownloadFromStream(GVOS_InputStream, 'Export CITI XML', '', '', GVTX_XMLName);
                    jsonBody := ' {"base64":"' + base64Convert.ToBase64(GVOS_InputStream) + '","fileName":"' + GVTX_XMLName + '","fileType":text/xml"", "fileExt":"TXT"}';
                    httpContent.WriteFrom(jsonBody);
                    httpContent.GetHeaders(httpHeader);
                    httpHeader.Remove('Content-Type');
                    httpHeader.Add('Content-Type', 'application/json');

                    // 다른 방식의 POST START---------------
                    // httpRequest.SetRequestUri('https://bulk53.azurewebsites.net/api/UploadFile');
                    // httpRequest.Method('POST');
                    // httpRequest.GetHeaders(httpHeader);
                    // httpHeader.Add('accept', 'application/json');
                    // httpRequest.Content := httpContent;
                    // httpClient.Send(httpRequest, httpResponse);
                    // 다른 방식의 POST END-----------------

                    httpClient.Post('https://bulk53.azurewebsites.net/api/UploadFile', httpContent, httpResponse);
                    //Here we should read the response to retrieve the URI
                    httpResponse.Content().ReadAs(respText);
                    Message('Response :: %1', respText);
                    message('File uploaded.');


                    IF GVBO_IsExported THEN BEGIN
                        GVRE_XMLInterfaceLog.INIT;
                        GVRE_XMLInterfaceLog."Extract Date" := WORKDATE;
                        GVRE_XMLInterfaceLog."XML Name" := GVTX_XMLName;
                        GVRE_XMLInterfaceLog.Path := GVTX_Path;
                        GVRE_XMLInterfaceLog.INSERT;
                        IF GVRE_GenJournalLine.FIND('-') THEN BEGIN

                            REPEAT
                                GVRE_GenJournalLine."XML Export Completion" := TRUE;
                                GVRE_GenJournalLine.MODIFY;
                            UNTIL GVRE_GenJournalLine.NEXT = 0;
                        END;

                        MESSAGE(Text0001, GVTX_XMLName);
                    END ELSE BEGIN
                        MESSAGE(Text0002);
                    END;
                END;

            2:
                BEGIN
                    GVRE_GenJournalLine.RESET;
                    GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine."Journal Template Name", 'PAYMENTS');
                    GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine."Journal Batch Name", 'CITI');
                    GVRE_GenJournalLine.SetFilter(GVRE_GenJournalLine."XML Export Completion", '%1', FALSE);
                    GVRE_GenJournalLine.CalcFields("Bank Transfer Type");
                    GVRE_GenJournalLine.SetFilter(GVRE_GenJournalLine."Bank Transfer Type", 'OVERSEAS');
                    IF NOT GVRE_GenJournalLine.FIND('-') THEN BEGIN
                        ERROR('No lines to export');
                    END;
                    GVTX_XMLName := 'GUERBET.NC4.IMPORT_ACK.JP1' + FORMAT(TODAY, 0, '<Year,2><Month,2><Day,2>') + DELCHR(FORMAT(TIME, 4, '<Hours24><Minutes,2><Seconds,2>'), '=', ':') + '57' +
                              '.PY_BULK.' + '53_ROPT' + '.NULL.NULL.TXT';
                    TempBlob.CreateOutStream(GVOS_OutputStream);
                    GVBO_IsExported := XMLPORT.EXPORT(XMLPORT::BankXML_53_ROPT, GVOS_OutputStream);
                    TempBlob.CreateInStream(GVOS_InputStream);
                    CopyStream(GVOS_OutputStream, GVOS_InputStream);
                    DownloadFromStream(GVOS_InputStream, 'Export CITI XML', '', '', GVTX_XMLName);

                    IF GVBO_IsExported THEN BEGIN
                        GVRE_XMLInterfaceLog.INIT;
                        GVRE_XMLInterfaceLog."Extract Date" := WORKDATE;
                        GVRE_XMLInterfaceLog."XML Name" := GVTX_XMLName;
                        GVRE_XMLInterfaceLog.Path := GVTX_Path;
                        GVRE_XMLInterfaceLog.INSERT;
                        IF GVRE_GenJournalLine.FIND('-') THEN BEGIN
                            REPEAT
                                GVRE_GenJournalLine."XML Export Completion" := TRUE;
                                GVRE_GenJournalLine.MODIFY;
                            UNTIL GVRE_GenJournalLine.NEXT = 0;
                        END;

                        MESSAGE(Text0001, GVTX_XMLName);
                    END ELSE BEGIN
                        MESSAGE(Text0002);
                    END;

                END;
        END;

    end;

    procedure GVFN_UncheckXML(var PAR_Options: Integer)
    begin
        CASE PAR_Options OF
            1:
                BEGIN

                    GVRE_GenJournalLine.RESET;
                    GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine."XML Export Completion", TRUE);
                    GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine."Journal Template Name", 'PAYMENTS');
                    GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine."Journal Batch Name", 'CITI');
                    GVRE_GenJournalLine.CalcFields("Bank Transfer Type");
                    GVRE_GenJournalLine.SetFilter(GVRE_GenJournalLine."Bank Transfer Type", 'DOMESTIC');
                    IF GVRE_GenJournalLine.FIND('-') THEN BEGIN
                        REPEAT
                            GVRE_GenJournalLine."XML Export Completion" := FALSE;
                            GVRE_GenJournalLine.MODIFY;
                        UNTIL GVRE_GenJournalLine.NEXT = 0;
                    END;
                END;

            2:
                BEGIN
                    GVRE_GenJournalLine.RESET;
                    GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine."XML Export Completion", TRUE);
                    GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine."Journal Template Name", 'PAYMENTS');
                    GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine."Journal Batch Name", 'CITI');
                    GVRE_GenJournalLine.CalcFields("Bank Transfer Type");
                    GVRE_GenJournalLine.SetFilter(GVRE_GenJournalLine."Bank Transfer Type", 'OVERSEAS');
                    IF GVRE_GenJournalLine.FIND('-') THEN BEGIN
                        REPEAT
                            GVRE_GenJournalLine."XML Export Completion" := FALSE;
                            GVRE_GenJournalLine.MODIFY;
                        UNTIL GVRE_GenJournalLine.NEXT = 0;
                    END;
                END;
        END;
    end;
}

