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
                    GVRE_GenJournalLine.SetFilter(GVRE_GenJournalLine.Comment, '%1', '53_ROPE');
                    IF NOT GVRE_GenJournalLine.FIND('-') THEN BEGIN
                        ERROR('No lines to export');
                    END;

                    GVTX_XMLName := 'GUERBET.NC4.IMPORT_ACK.JP1' + FORMAT(TODAY, 0, '<Year,2><Month,2><Day,2>') + DELCHR(FORMAT(TIME, 4, '<Hours24><Minutes,2><Seconds,2>'), '=', ':') + '57' +
                              '.PY_BULK.' + '53_ROPE' + '.NULL.NULL.TXT';
                    //GVTX_Path := 'C:\BankXML\';
                    //GVFL_XMLFile.CREATE(GVTX_Path + GVTX_XMLName);
                    //GVFL_XMLFile.CREATEOUTSTREAM(GVOS_OutputStream);
                    TempBlob.CreateOutStream(GVOS_OutputStream);
                    GVBO_IsExported := XMLPORT.EXPORT(XMLPORT::BankXML_53_ROPE, GVOS_OutputStream);
                    TempBlob.CreateInStream(GVOS_InputStream);
                    CopyStream(GVOS_OutputStream, GVOS_InputStream);
                    DownloadFromStream(GVOS_InputStream, 'Export CITI XML', '', '', GVTX_XMLName);
                    //GVFL_XMLFile.CLOSE;
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
                        //ERASE(GVTX_Path + GVTX_XMLName);
                        MESSAGE(Text0002);
                    END;
                END;

            2:
                BEGIN
                    GVRE_GenJournalLine.RESET;
                    GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine."Journal Template Name", 'PAYMENTS');
                    GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine."Journal Batch Name", 'CITI');
                    GVRE_GenJournalLine.SetFilter(GVRE_GenJournalLine."XML Export Completion", '%1', FALSE);
                    GVRE_GenJournalLine.SetFilter(GVRE_GenJournalLine.Comment, '%1', '53_ROPT');
                    IF NOT GVRE_GenJournalLine.FIND('-') THEN BEGIN
                        ERROR('No lines to export');
                    END;
                    GVTX_XMLName := 'GUERBET.NC4.IMPORT_ACK.JP1' + FORMAT(TODAY, 0, '<Year,2><Month,2><Day,2>') + DELCHR(FORMAT(TIME, 4, '<Hours24><Minutes,2><Seconds,2>'), '=', ':') + '57' +
                              '.PY_BULK.' + '53_ROPT' + '.NULL.NULL.TXT';
                    // MESSAGE( GVTX_XMLName ); // :=   DELCHR(GVTX_XMLName,'=','');
                    //GVTX_Path := 'C:\BankXML\';
                    //GVFL_XMLFile.CREATE(GVTX_Path + GVTX_XMLName);
                    //GVFL_XMLFile.CREATEOUTSTREAM(GVOS_OutputStream);
                    TempBlob.CreateOutStream(GVOS_OutputStream);
                    GVBO_IsExported := XMLPORT.EXPORT(XMLPORT::BankXML_53_ROPT, GVOS_OutputStream);
                    TempBlob.CreateInStream(GVOS_InputStream);
                    CopyStream(GVOS_OutputStream, GVOS_InputStream);
                    DownloadFromStream(GVOS_InputStream, 'Export CITI XML', '', '', GVTX_XMLName);
                    //GVFL_XMLFile.CLOSE;
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
                        //ERASE(GVTX_Path + GVTX_XMLName);
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
                    GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine.Comment, '53_ROPE');
                    GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine."Journal Batch Name", 'CITI');
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
                    GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine.Comment, '53_ROPT');
                    GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine."Journal Batch Name", 'CITI');
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

