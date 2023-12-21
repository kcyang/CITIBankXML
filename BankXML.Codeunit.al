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
        //base64Convert: Codeunit "Base64Convert Online";
        jsonBody: Text;
        httpClient: HttpClient;
        httpContent: HttpContent;
        httpResponse: HttpResponseMessage;
        httpRequest: HttpRequestMessage;
        httpHeader: HttpHeaders;
        respText: Text;
        GVRE_VendorBankAccount: Record "Vendor Bank Account";


    procedure GVFN_ExportData(var PAR_Options: Integer)
    var
        base64string: Text;
        xmlResult: Text;
    begin
        Clear(base64string);
        Clear(xmlResult);
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
                              '.PY_BULK.' + '53OPE' + '.NULL.NULL.TXT';
                    TempBlob.CreateOutStream(GVOS_OutputStream);
                    GVBO_IsExported := XMLPORT.EXPORT(XMLPORT::BankXML_53_ROPE, GVOS_OutputStream);
                    TempBlob.CreateInStream(GVOS_InputStream);
                    //파일로 내려받는 부분 삭제.START
                    //CopyStream(GVOS_OutputStream, GVOS_InputStream);
                    //DownloadFromStream(GVOS_InputStream, 'Export CITI XML', '', '', GVTX_XMLName);
                    //파일로 내려받는 부분 삭제.END
                    base64string := base64Convert.ToBase64(GVOS_InputStream);
                    jsonBody := ' {"base64":"' + base64string + '","fileName":"' + GVTX_XMLName + '","fileType":"text/xml", "fileExt":"TXT"}';
                    httpContent.WriteFrom(jsonBody);
                    httpContent.GetHeaders(httpHeader);
                    httpHeader.Remove('Content-Type');
                    httpHeader.Add('Content-Type', 'application/json');

                    httpClient.Post('https://bulk53sp-prod.azurewebsites.net/api/bulk53sp', httpContent, httpResponse);
                    httpResponse.Content().ReadAs(respText);

                    if httpResponse.HttpStatusCode = 200 then begin
                        Message('アップロードが完了しました。The upload is complete.!');
                    end else begin
                        Error('Error :: %1', respText);
                    end;

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
                              '.PY_BULK.' + '53OPT' + '.NULL.NULL.TXT';
                    TempBlob.CreateOutStream(GVOS_OutputStream);
                    /*
                    * If there is IBAN code in bank account vs. others.
                    */
                    IF GVRE_GenJournalLine."Account Type" = GVRE_GenJournalLine."Account Type"::Vendor THEN BEGIN
                        GVRE_VendorBankAccount.RESET;
                        GVRE_VendorBankAccount.SETFILTER(GVRE_VendorBankAccount.Code, GVRE_GenJournalLine."Recipient Bank Account");
                        GVRE_VendorBankAccount.SETFILTER(GVRE_VendorBankAccount."Vendor No.", GVRE_GenJournalLine."Account No.");
                        IF GVRE_VendorBankAccount.FINDSET THEN BEGIN
                            if GVRE_VendorBankAccount.IBAN <> '' then begin
                                GVBO_IsExported := XMLPORT.EXPORT(XMLPORT::BankXML_53_ROPT, GVOS_OutputStream);
                            end else begin
                                GVBO_IsExported := XMLPORT.EXPORT(XMLPORT::BankXML_53_ROPT_OTHER, GVOS_OutputStream);
                            end;
                        END ELSE BEGIN
                            ERROR('Bank Account');
                        END;
                    END;
                    TempBlob.CreateInStream(GVOS_InputStream);
                    //for Text download
                    //DownloadFromStream(GVOS_InputStream, 'Export CITI XML', '', '', GVTX_XMLName);

                    base64string := base64Convert.ToBase64(GVOS_InputStream);
                    jsonBody := ' {"base64":"' + base64string + '","fileName":"' + GVTX_XMLName + '","fileType":"text/xml", "fileExt":"TXT"}';
                    httpContent.WriteFrom(jsonBody);
                    httpContent.GetHeaders(httpHeader);
                    httpHeader.Remove('Content-Type');
                    httpHeader.Add('Content-Type', 'application/json');

                    httpClient.Post('https://bulk53sp-prod.azurewebsites.net/api/bulk53sp', httpContent, httpResponse);
                    httpResponse.Content().ReadAs(respText);

                    if httpResponse.HttpStatusCode = 200 then begin
                        Message('アップロードが完了しました。The upload is complete.!');
                    end else begin
                        Error('Error :: %1', respText);
                    end;

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

