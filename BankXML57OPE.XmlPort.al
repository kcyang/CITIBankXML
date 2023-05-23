xmlport 55110 BankXML_57OPE
{
    Direction = Export;
    Encoding = UTF8;
    FormatEvaluate = Legacy;
    Namespaces = xsi = 'http://www.w3.org/2001/XMLSchema-instance', "" = 'urn:iso:std:iso:20022:tech:xsd:pain.001.001.03';
    UseDefaultNamespace = false;
    XMLVersionNo = V10;

    schema
    {
        textelement(Document)
        {
            textelement(CstmrCdtTrfInitn)
            {
                textelement(GrpHdr)
                {
                    textelement(MsgId)
                    {
                        TextType = Text;

                        trigger OnBeforePassVariable()
                        begin


                            MsgId := 'GUERBET.NC4.' + FORMAT(TODAY, 0, '<Year4><Month,2><Day,2>') + '.' + FORMAT(TIME, 0, '<Hours24><Minutes,2><Seconds,2>') + '.57OPE';
                            /*
                            IF STRLEN(Msgid) > 35 THEN BEGIN
                            
                            END;
                            */

                        end;
                    }
                    textelement(CreDtTm)
                    {

                        trigger OnBeforePassVariable()
                        begin

                            CreDtTm := FORMAT(DT2DATE(CURRENTDATETIME), 0, 9) + 'T'
                            + CONVERTSTR(FORMAT(DT2TIME(CURRENTDATETIME), 0, '<hours24,2>:<Minutes,2>:<Seconds,2>'), ' ', '0')
                            + '.111';
                        end;
                    }
                    textelement(NbOfTxs)
                    {

                        trigger OnBeforePassVariable()
                        begin

                            NbOfTxs := FORMAT("Gen. Journal Line".COUNT);
                        end;
                    }
                    textelement(CtrlSum)
                    {

                        trigger OnBeforePassVariable()
                        begin
                            IF "Gen. Journal Line".FIND('-') THEN BEGIN
                                REPEAT
                                    GVIN_CtrlSum += "Gen. Journal Line".Amount;
                                UNTIL "Gen. Journal Line".NEXT = 0;
                                CtrlSum := FORMAT(GVIN_CtrlSum);
                            END;
                        end;
                    }
                    textelement(InitgPty)
                    {
                        textelement(Nm)
                        {

                            trigger OnBeforePassVariable()
                            begin
                                Nm := 'GUERBET TAIWAN CO LTD'
                            end;
                        }
                    }
                }
                tableelement(Table81; Table81)
                {
                    XmlName = 'PmtInf';
                    textelement(PmtInfId)
                    {

                        trigger OnBeforePassVariable()
                        begin
                            PmtInfId := FORMAT("Gen. Journal Line"."Document No.") + '.' + FORMAT("Gen. Journal Line"."Line No.");
                        end;
                    }
                    textelement(PmtMtd)
                    {

                        trigger OnBeforePassVariable()
                        begin
                            PmtMtd := 'TRF';
                        end;
                    }
                    textelement(ReqdExctnDt)
                    {

                        trigger OnBeforePassVariable()
                        begin
                            //"<ReqdExctnDt>" := FORMAT("Gen. Journal Line"."Posting Date",0,9);
                            ReqdExctnDt := FORMAT("Gen. Journal Line"."Posting Date", 0, 9);
                        end;
                    }
                    textelement(Dbtr)
                    {
                        textelement("<nm2>")
                        {
                            XmlName = 'Nm';

                            trigger OnBeforePassVariable()
                            begin
                                "<Nm2>" := 'GUERBET TAIWAN CO LTD';
                            end;
                        }
                    }
                    textelement(DbtrAcct)
                    {
                        textelement(Id)
                        {
                            textelement(Othr)
                            {
                                textelement("<id2>")
                                {
                                    XmlName = 'Id';

                                    trigger OnBeforePassVariable()
                                    begin
                                        GVRE_BankAccount.RESET;
                                        GVRE_BankAccount.SETFILTER(GVRE_BankAccount."No.", 'B05');
                                        IF GVRE_BankAccount.FINDSET THEN BEGIN
                                            "<Id2>" := GVRE_BankAccount."Bank Account No.";
                                        END;
                                        //bank account b05
                                    end;
                                }
                            }
                        }
                    }
                    textelement(DbtrAgt)
                    {
                        MaxOccurs = Once;
                        textelement(FinInstnId)
                        {
                            textelement(BIC)
                            {

                                trigger OnBeforePassVariable()
                                begin
                                    BIC := 'CITITWTX';
                                end;
                            }
                            textelement(PstlAdr)
                            {
                                textelement(Ctry)
                                {

                                    trigger OnBeforePassVariable()
                                    begin
                                        Ctry := 'TW';
                                    end;
                                }
                            }
                        }
                    }
                    textelement(CdtTrfTxInf)
                    {
                        textelement(PmtId)
                        {
                            textelement(EndToEndId)
                            {

                                trigger OnBeforePassVariable()
                                begin
                                    EndToEndId := FORMAT("Gen. Journal Line"."Document No.") + '.' + FORMAT("Gen. Journal Line"."Line No.");
                                end;
                            }
                        }
                        textelement(Amt)
                        {
                            textelement(InstdAmt)
                            {
                                textattribute(Ccy)
                                {

                                    trigger OnBeforePassVariable()
                                    begin
                                        Ccy := 'TWD';
                                    end;
                                }

                                trigger OnBeforePassVariable()
                                begin
                                    InstdAmt := DELCHR(FORMAT("Gen. Journal Line"."Amount (LCY)"), '=', ',');
                                end;
                            }
                        }
                        textelement(ChqInstr)
                        {
                            textelement(DlvrTo)
                            {
                                textelement("<nm4>")
                                {
                                    XmlName = 'Nm';

                                    trigger OnBeforePassVariable()
                                    begin
                                        CLEAR(GVTX_VendorName);
                                        GVRE_Vendor.RESET;
                                        GVRE_Vendor.SETRANGE(GVRE_Vendor."No.", "Gen. Journal Line"."Account No.");
                                        IF GVRE_Vendor.FIND('-') THEN BEGIN
                                            GVTX_VendorName := GVRE_Vendor.Name;
                                        END;
                                        "<Nm4>" := GVTX_VendorName;
                                    end;
                                }
                                textelement(Adr)
                                {

                                    trigger OnBeforePassVariable()
                                    begin
                                        //"<Adr>" := GVRE_Vendor.Address;
                                    end;
                                }
                            }
                        }
                        textelement(CdtrAgt)
                        {
                            textelement("<fininstnid2>")
                            {
                                XmlName = 'FinInstnId';
                                textelement(ClrSysMmbId)
                                {
                                    textelement("<mmbid>")
                                    {
                                        XmlName = 'MmbId';

                                        trigger OnBeforePassVariable()
                                        begin
                                            IF "Gen. Journal Line"."Account Type" = "Gen. Journal Line"."Account Type"::Vendor THEN BEGIN

                                                GVRE_VendorBankAccount.RESET;
                                                GVRE_VendorBankAccount.SETFILTER(GVRE_VendorBankAccount.Code, "Gen. Journal Line"."Recipient Bank Account");
                                                GVRE_VendorBankAccount.SETFILTER(GVRE_VendorBankAccount."Vendor No.", "Gen. Journal Line"."Account No.");
                                                IF GVRE_VendorBankAccount.FINDSET THEN BEGIN
                                                    "<MmbId>" := GVRE_VendorBankAccount."Bank Branch No.";
                                                    //MESSAGE(GVRE_VendorBankAccount."Bank Account No.");
                                                END ELSE BEGIN
                                                    MESSAGE(Text0001, "Gen. Journal Line"."Account No.", 'Bank Branch No.');
                                                    ERROR('Bank Branch No.');
                                                END;
                                            END;
                                        end;
                                    }
                                }
                            }
                        }
                        textelement(Cdtr)
                        {
                            textelement("<nm3>")
                            {
                                XmlName = 'Nm';

                                trigger OnBeforePassVariable()
                                begin
                                    "<Nm3>" := GVTX_VendorName;
                                end;
                            }
                        }
                        textelement(CdtrAcct)
                        {
                            textelement("<id3>")
                            {
                                XmlName = 'Id';
                                textelement("<othr2>")
                                {
                                    XmlName = 'Othr';
                                    textelement("<id4>")
                                    {
                                        XmlName = 'Id';

                                        trigger OnBeforePassVariable()
                                        begin
                                            IF GVRE_VendorBankAccount.FINDSET THEN BEGIN
                                                "<Id4>" := GVRE_VendorBankAccount."Bank Account No.";
                                                //MESSAGE(GVRE_VendorBankAccount."Bank Account No.");
                                            END ELSE BEGIN
                                                MESSAGE(Text0001, GVRE_VendorBankAccount."Vendor No.", 'Bank Account No.');
                                                ERROR('Bank Account No.');
                                            END;
                                        end;
                                    }
                                }
                            }
                        }
                    }
                }

                trigger OnBeforePassVariable()
                begin
                    /*
                    currXMLport.FILENAME := 'GUERBET.NC4.IMPORT_ACK.' + FORMAT(TODAY,0,'<Year4><Month,2><Day,2>')+ '57' +
                    '.PY_BULK.' +'57OPE'+ '.null.null.xml';
                    */
                    /*
                    GVRE_XMLInterfaceLog.INIT;
                    GVRE_XMLInterfaceLog."XML Name" := currXMLport.FILENAME;
                    GVRE_XMLInterfaceLog."Extract Date" := WORKDATE;
                    */

                end;
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    trigger OnInitXmlPort()
    begin
        "Gen. Journal Line".SETRANGE("Gen. Journal Line"."Journal Template Name", 'PAYMENT');
        "Gen. Journal Line".SETRANGE("Gen. Journal Line".Comment, '57OPE');
        "Gen. Journal Line".SETRANGE("Gen. Journal Line"."Journal Batch Name", 'CITI');
    end;

    var
        GVRE_Vendor: Record "Vendor";
        GVTX_VendorName: Text;
        GVIN_Count: Integer;
        GVRE_GenJournalLine: Record "Gen. Journal Line";
        GVRE_BankAccount: Record "Bank Account";
        GVRE_VendorBankAccount: Record "Vendor Bank Account";
        GVRE_XMLInterfaceLog: Record "XML Interface Log";
        Text0001: Label '%1 ''s bank %2 doesn''t exist.';
        Text0002: Label '%1 ''s bank account no. doesn''t exist.';
        GVIN_CtrlSum: Integer;
        TA_Test: Text;
        GVTX_Hours: Text;
        GVTX_Minutes: Text;
        GVTX_Seconds: Text;
}

