codeunit 58150 BankXML
{

    trigger OnRun()
    begin
    end;

    var
        GVRE_GenJournalLine: Record "Gen. Journal Line";
        GVXM_BnkXML_57OPE: XMLport "BankXML_57OPE";
        GVXM_BnkXML_57OPT: XMLport "BankXML_57OPT";
        GVFL_XMLFile: File;
        GVOS_OutputStream: OutStream;
        GVOS_InputStream: InStream;
        GVTX_XMLName: Text;
        Text0001: Label 'Payment Jnl. XML file is exported (%1)';
        GVTX_Path: Text;
        GVBO_IsExported: Boolean;
        GVRE_XMLInterfaceLog: Record "XML Interface Log";
        Text0002: Label 'The Export Failed';
        XMLDom: Automation;
        XMLCurrNode: Automation;
        XMLPI: Automation;
        XMLAttr: Automation;

    procedure GVFN_ExportData(var PAR_Options: Integer)
    begin

        CASE PAR_Options OF
            1:
                BEGIN
                    //MESSAGE( FORMAT(TIME,5));
                    GVRE_GenJournalLine.RESET;
                    GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine."XML Export Completion", FALSE);
                    GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine."Journal Template Name", 'PAYMENT');
                    GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine.Comment, '57OPE');
                    GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine."Journal Batch Name", 'CITI');
                    IF NOT GVRE_GenJournalLine.FIND('-') THEN BEGIN
                        ERROR('No lines to export');
                    END;

                    GVTX_XMLName := 'GUERBET.NC4.IMPORT_ACK.' + FORMAT(TODAY, 0, '<Year4><Month,2><Day,2>') + DELCHR(FORMAT(TIME, 4, '<Hours24><Minutes,2><Seconds,2>'), '=', ':') + '57' +
                              '.PY_BULK.' + '57OPE' + '.null.null.xml';
                    GVTX_Path := 'C:\BankXML\';
                    GVFL_XMLFile.CREATE(GVTX_Path + GVTX_XMLName);
                    GVFL_XMLFile.CREATEOUTSTREAM(GVOS_OutputStream);
                    GVBO_IsExported := XMLPORT.EXPORT(XMLPORT::BankXML_57OPE, GVOS_OutputStream);
                    //GVFL_XMLFile.CREATEINSTREAM(GVOS_InputStream);//
                    //CREATE(XMLDom);//
                    //XMLDom.load(GVOS_InputStream);//
                    GVFL_XMLFile.CLOSE;
                    //XMLPI := XMLDom.firstChild;//
                    //XMLAttr := XMLPI.attributes;    //
                    //XMLCurrNode := XMLAttr.getNamedItem('standalone');//
                    //XMLCurrNode.text := 'yes';//
                    //XMLAttr.removeNamedItem('standalone');//
                    //XMLDom.save( GVTX_Path + GVTX_XMLName );//
                    //CLEAR( XMLDom );//
                    IF GVBO_IsExported THEN BEGIN
                        GVRE_XMLInterfaceLog.INIT;
                        GVRE_XMLInterfaceLog."Extract Date" := WORKDATE;
                        GVRE_XMLInterfaceLog."XML Name" := GVTX_XMLName;
                        GVRE_XMLInterfaceLog.Path := GVTX_Path;
                        GVRE_XMLInterfaceLog.INSERT;
                        /*
                        GVRE_GenJournalLine.RESET;
                        GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine."XML Export Completion", FALSE);
                        GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine."Journal Template Name",'PAYMENT');
                        GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine.Comment,'57OPE');
                        GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine."Journal Batch Name",'BANK');
                        */
                        IF GVRE_GenJournalLine.FIND('-') THEN BEGIN

                            REPEAT
                                GVRE_GenJournalLine."XML Export Completion" := TRUE;
                                GVRE_GenJournalLine.MODIFY;
                            UNTIL GVRE_GenJournalLine.NEXT = 0;
                        END;

                        MESSAGE(Text0001, GVTX_XMLName);
                    END ELSE BEGIN
                        ERASE(GVTX_Path + GVTX_XMLName);
                        MESSAGE(Text0002);
                    END;
                    /*
                  PAR_GenJournalLine.SETRANGE(Comment,'57OPE');
                  IF PAR_GenJournalLine.FIND('-') THEN BEGIN

                   GVXM_BnkXML_57OPE.SETTABLEVIEW(PAR_GenJournalLine);
                   GVXM_BnkXML_57OPE.RUN();
                   //GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine."Journal Batch Name",'BANK');
                  END;
                  */

                END;

            2:
                BEGIN
                    GVRE_GenJournalLine.RESET;
                    GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine."XML Export Completion", FALSE);
                    GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine."Journal Template Name", 'PAYMENT');
                    GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine.Comment, '57OPT');
                    GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine."Journal Batch Name", 'CITI');
                    IF NOT GVRE_GenJournalLine.FIND('-') THEN BEGIN
                        ERROR('No lines to export');
                    END;
                    GVTX_XMLName := 'GUERBET.NC4.IMPORT_ACK.' + FORMAT(TODAY, 0, '<Year4><Month,2><Day,2>') + DELCHR(FORMAT(TIME, 4, '<Hours24><Minutes,2><Seconds,2>'), '=', ':') + '57' +
                              '.PY_BULK.' + '57OPT' + '.null.null.xml';
                    // MESSAGE( GVTX_XMLName ); // :=   DELCHR(GVTX_XMLName,'=','');
                    GVTX_Path := 'C:\BankXML\';
                    GVFL_XMLFile.CREATE(GVTX_Path + GVTX_XMLName);
                    GVFL_XMLFile.CREATEOUTSTREAM(GVOS_OutputStream);
                    GVBO_IsExported := XMLPORT.EXPORT(XMLPORT::BankXML_57OPT, GVOS_OutputStream);
                    GVFL_XMLFile.CLOSE;
                    IF GVBO_IsExported THEN BEGIN
                        GVRE_XMLInterfaceLog.INIT;
                        GVRE_XMLInterfaceLog."Extract Date" := WORKDATE;
                        GVRE_XMLInterfaceLog."XML Name" := GVTX_XMLName;
                        GVRE_XMLInterfaceLog.Path := GVTX_Path;
                        GVRE_XMLInterfaceLog.INSERT;
                        /*
                        GVRE_GenJournalLine.RESET;
                        GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine."XML Export Completion", FALSE);
                        GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine."Journal Template Name",'PAYMENT');
                        GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine.Comment,'57OPT');
                        GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine."Journal Batch Name",'BANK');
                        */
                        IF GVRE_GenJournalLine.FIND('-') THEN BEGIN
                            REPEAT
                                GVRE_GenJournalLine."XML Export Completion" := TRUE;
                                GVRE_GenJournalLine.MODIFY;
                            UNTIL GVRE_GenJournalLine.NEXT = 0;
                        END;

                        MESSAGE(Text0001, GVTX_XMLName);
                    END ELSE BEGIN
                        ERASE(GVTX_Path + GVTX_XMLName);
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
                    GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine."Journal Template Name", 'PAYMENT');
                    GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine.Comment, '57OPE');
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
                    GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine."Journal Template Name", 'PAYMENT');
                    GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine.Comment, '57OPT');
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

