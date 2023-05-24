xmlport 58160 BankXML_53_ROPT
{
    Direction = Export;
    Encoding = UTF8;
    Namespaces = xsi = 'urn:iso:std:iso:20022:tech:xsd:pain.001.001.03', "" = 'urn:iso:std:iso:20022:tech:xsd:pain.001.001.03';
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
                            MsgId := 'GUERBET.NC4.JP1' + FORMAT(TODAY, 0, '<Year,2><Month,2><Day,2>') + '.' + FORMAT(TIME, 0, '<Hours24><Minutes,2><Seconds,2>') + '.53_ROPT';
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
                    textelement(InitgPty)
                    {
                        textelement(Nm)
                        {

                            trigger OnBeforePassVariable()
                            begin
                                Nm := 'GUERBET JAPAN KK'
                            end;
                        }
                    }
                }
                tableelement("Gen. Journal Line"; "Gen. Journal Line")
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
                    textelement(PmtTpInf)
                    {
                        textelement(SvcLvl)
                        {
                            textelement(Cd)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    Cd := 'URGP';
                                end;
                            }
                        }
                    }
                    textelement(ReqdExctnDt)
                    {
                        trigger OnBeforePassVariable()
                        begin
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
                                "<Nm2>" := 'GUERBET JAPAN KK';
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
                                    BIC := 'CITIJPJT';
                                end;
                            }
                            textelement(PstlAdr)
                            {
                                textelement(Ctry)
                                {

                                    trigger OnBeforePassVariable()
                                    begin
                                        Ctry := 'JP';
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
                                        IF "Gen. Journal Line"."Currency Code" = '' THEN BEGIN
                                            Ccy := 'JPY';
                                        END ELSE
                                            IF "Gen. Journal Line"."Currency Code" <> '' THEN BEGIN
                                                Ccy := "Gen. Journal Line"."Currency Code";
                                            END;
                                    end;
                                }

                                trigger OnBeforePassVariable()
                                begin
                                    InstdAmt := DELCHR(FORMAT("Gen. Journal Line".Amount), '=', ',');
                                end;
                            }
                        }
                        textelement(CdtrAgt)
                        {
                            textelement("<fininstnid2>")
                            {
                                XmlName = 'FinInstnId';
                                textelement("<bic2>")
                                {
                                    XmlName = 'BIC';

                                    trigger OnBeforePassVariable()
                                    begin
                                        IF "Gen. Journal Line"."Account Type" = "Gen. Journal Line"."Account Type"::Vendor THEN BEGIN

                                            GVRE_VendorBankAccount.RESET;
                                            GVRE_VendorBankAccount.SETFILTER(GVRE_VendorBankAccount.Code, "Gen. Journal Line"."Recipient Bank Account");
                                            GVRE_VendorBankAccount.SETFILTER(GVRE_VendorBankAccount."Vendor No.", "Gen. Journal Line"."Account No.");
                                            IF GVRE_VendorBankAccount.FINDSET THEN BEGIN
                                                IF GVRE_VendorBankAccount."SWIFT Code" <> '' THEN BEGIN
                                                    "<BIC2>" := GVRE_VendorBankAccount."SWIFT Code";
                                                END ELSE BEGIN
                                                    MESSAGE(Text0001, "Gen. Journal Line"."Account No.", 'SWIFT code');
                                                    ERROR('SWIFT code');
                                                END;
                                            END;
                                        END;

                                    end;
                                }
                                textelement("<pstladr2>")
                                {
                                    XmlName = 'PstlAdr';
                                    textelement("<ctry2>")
                                    {
                                        XmlName = 'Ctry';

                                        trigger OnBeforePassVariable()
                                        begin
                                            IF GVRE_VendorBankAccount."Country/Region Code" <> '' THEN BEGIN
                                                "<Ctry2>" := GVRE_VendorBankAccount."Country/Region Code";
                                            END ELSE BEGIN
                                                MESSAGE(Text0001, "Gen. Journal Line"."Account No.", 'Country/Region Code');
                                                ERROR('Country/Region Code');
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
                                    CLEAR(GVTX_VendorName);
                                    // GVRE_Vendor.RESET;
                                    // GVRE_Vendor.SETRANGE(GVRE_Vendor."No.", "Gen. Journal Line"."Account No.");
                                    // IF GVRE_Vendor.FIND('-') THEN BEGIN
                                    //     GVTX_VendorName := GVRE_Vendor.Name;
                                    // END;
                                    IF GVRE_VendorBankAccount.FindSet() then begin
                                        GVTX_VendorName := GVRE_VendorBankAccount.Name;
                                    end;
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
                                            //credit account no.
                                            IF GVRE_VendorBankAccount."Bank Account No." <> '' THEN BEGIN
                                                "<Id4>" := GVRE_VendorBankAccount."Bank Account No.";
                                            END ELSE BEGIN
                                                MESSAGE(Text0001, "Gen. Journal Line"."Account No.", 'Bank Account No.');
                                                ERROR('Bank Account No.');
                                            END;
                                        end;
                                    }
                                }
                            }
                        }
                        textelement(RgltryRptg)
                        {
                            textelement(Dtls)
                            {
                                textelement("<inf>")
                                {
                                    XmlName = 'Inf';

                                    trigger OnBeforePassVariable()
                                    begin
                                        "<Inf>" := '/TWNREG/3470A NW';
                                    end;
                                }
                            }
                        }
                    }
                }
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
        "Gen. Journal Line".SETRANGE("Gen. Journal Line"."Journal Template Name", 'PAYMENTS');
        "Gen. Journal Line".SETRANGE("Gen. Journal Line".Comment, '53_ROPT');
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
        Text0001: Label '%1 ''s %2 doesn''t exist.';
        GVCO_Currency: Code[10];
}

