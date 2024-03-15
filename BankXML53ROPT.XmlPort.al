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
                            MsgId := 'GUERBET.NC4.JP1' + FORMAT(TODAY, 0, '<Year,2><Month,2><Day,2>') + '.' + FORMAT(TIME, 0, '<Hours24><Minutes,2><Seconds,2>');
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
                                CtrlSum := DELCHR(FORMAT(GVIN_CtrlSum), '=', ',');
                            END;
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
                textelement(PmtInf)
                {
                    textelement(PmtInfId)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            PmtInfId := FORMAT("Gen. Journal Line"."Document No.");
                        end;
                    }
                    textelement(PmtMtd)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            PmtMtd := 'TRF';
                        end;
                    }
                    textelement(BtchBookg)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            BtchBookg := 'TRUE';
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
                        textelement(LclInstrm)
                        {
                            textelement(LclInstrmCd)
                            {
                                XmlName = 'Cd';

                                trigger OnBeforePassVariable()
                                begin
                                    LclInstrmCd := 'CITI392';
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
                        textelement(DbtrPstlAdr)
                        {
                            XmlName = 'PstlAdr';
                            textelement(DbtrPstlAdrCtry)
                            {
                                XmlName = 'Ctry';
                                trigger OnBeforePassVariable()
                                begin
                                    DbtrPstlAdrCtry := 'JP';
                                end;
                            }
                        }
                        textelement(DbtrId)
                        {
                            XmlName = 'Id';
                            textelement(DbtrIdOrdId)
                            {
                                XmlName = 'OrgId';
                                textelement(BICOrBEI)
                                {
                                    trigger OnBeforePassVariable()
                                    begin
                                        BICOrBEI := 'CITIJPJT';
                                    end;
                                }
                            }
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
                                        GVRE_BankAccount.SETFILTER(GVRE_BankAccount."No.", 'B001');
                                        IF GVRE_BankAccount.FINDSET THEN BEGIN
                                            "<Id2>" := GVRE_BankAccount."Bank Account No.";
                                        END;
                                        //bank account B001
                                    end;
                                }
                            }
                        }
                        textelement(DbtrAcctCcy)
                        {
                            XmlName = 'Ccy';

                            trigger OnBeforePassVariable()
                            begin
                                DbtrAcctCcy := 'JPY';
                            end;
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
                    tableelement("Gen. Journal Line"; "Gen. Journal Line")
                    {
                        XmlName = 'CdtTrfTxInf';

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
                                    InstdAmt := DELCHR(FORMAT("Gen. Journal Line"."Amount"), '=', ',');
                                end;
                            }
                        }
                        textelement(CdtrAgt)
                        {
                            textelement("<fininstnid2>")
                            {
                                XmlName = 'FinInstnId';
                                textelement(ClrSysMmbIdBIC)
                                {
                                    XmlName = 'BIC';

                                    trigger OnBeforePassVariable()
                                    var
                                        LV_BankBranchNo: Text;
                                    begin
                                        CLEAR(GVTX_VendorName);
                                        Clear(LV_BankBranchNo);
                                        IF "Gen. Journal Line"."Account Type" = "Gen. Journal Line"."Account Type"::Vendor THEN BEGIN
                                            GVRE_VendorBankAccount.RESET;
                                            GVRE_VendorBankAccount.SETFILTER(GVRE_VendorBankAccount.Code, "Gen. Journal Line"."Recipient Bank Account");
                                            GVRE_VendorBankAccount.SETFILTER(GVRE_VendorBankAccount."Vendor No.", "Gen. Journal Line"."Account No.");
                                            IF GVRE_VendorBankAccount.FINDSET THEN BEGIN
                                                GVTX_VendorName := GVRE_VendorBankAccount.Name;
                                                ClrSysMmbIdBIC := GVRE_VendorBankAccount."SWIFT Code";
                                            END ELSE BEGIN
                                                MESSAGE(Text0001, "Gen. Journal Line"."Account No.", 'SWIFT Code');
                                                ERROR('SWIFT Code');
                                            END;
                                        END;
                                    end;
                                }

                                textelement(ClrSysMmbIdPstlAdr)
                                {
                                    XmlName = 'PstlAdr';
                                    textelement(ClrSysMmbIdPstlAdrCtry)
                                    {
                                        XmlName = 'Ctry';
                                        trigger OnBeforePassVariable()
                                        begin
                                            //ClrSysMmbIdPstlAdrCtry := 'JP';
                                            IF GVRE_VendorBankAccount."Country/Region Code" <> '' THEN BEGIN
                                                ClrSysMmbIdPstlAdrCtry := GVRE_VendorBankAccount."Country/Region Code";
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
                                    "<Nm3>" := GVTX_VendorName;
                                end;
                            }
                            textelement(CdtrPstlAdr)
                            {
                                XmlName = 'PstlAdr';
                                textelement(CdtrPstlAdrCtry)
                                {
                                    XmlName = 'Ctry';
                                    trigger OnBeforePassVariable()
                                    begin
                                        //CdtrPstlAdrCtry := 'JP';
                                        IF GVRE_VendorBankAccount."Country/Region Code" <> '' THEN BEGIN
                                            CdtrPstlAdrCtry := GVRE_VendorBankAccount."Country/Region Code";
                                        END ELSE BEGIN
                                            MESSAGE(Text0001, "Gen. Journal Line"."Account No.", 'Country/Region Code');
                                            ERROR('Country/Region Code');
                                        END;
                                    end;
                                }
                            }
                        }
                        textelement(CdtrAcct)
                        {
                            textelement("<id3>")
                            {
                                XmlName = 'Id';

                                textelement("IBAN")
                                {
                                    trigger OnBeforePassVariable()
                                    begin
                                        IF GVRE_VendorBankAccount.FindSet() then begin
                                            if GVRE_VendorBankAccount.IBAN <> '' then
                                                IBAN := GVRE_VendorBankAccount.IBAN
                                            else
                                                currXMLport.Skip();

                                        end else begin
                                            MESSAGE(Text0001, GVRE_VendorBankAccount."Vendor No.", 'Bank Account No.');
                                            ERROR('Bank Account No.');
                                        end;
                                    end;
                                }
                                textelement("Othr3")
                                {
                                    XmlName = 'Othr';
                                    textelement("<id4>")
                                    {
                                        XmlName = 'Id';
                                        trigger OnBeforePassVariable()
                                        begin
                                            IF GVRE_VendorBankAccount.FindSet() then begin
                                                if GVRE_VendorBankAccount.IBAN <> '' then
                                                    "<id4>" := GVRE_VendorBankAccount.IBAN
                                                else
                                                    "<id4>" := GVRE_VendorBankAccount."Bank Account No.";
                                            end else begin
                                                MESSAGE(Text0001, GVRE_VendorBankAccount."Vendor No.", 'Bank Account No.');
                                                ERROR('Bank Account No.');
                                            end;
                                        end;

                                    }

                                    trigger OnBeforePassVariable()
                                    begin
                                        IF GVRE_VendorBankAccount.FindSet() then begin
                                            if GVRE_VendorBankAccount.IBAN <> '' then
                                                currXMLport.Skip();
                                        end
                                    end;
                                }
                            }
                            // textelement("<othr2>")
                            // {
                            //     XmlName = 'Othr';
                            //     textelement("<id4>")
                            //     {
                            //         XmlName = 'Id';

                            //         trigger OnBeforePassVariable()
                            //         begin
                            //             IF GVRE_VendorBankAccount.FINDSET THEN BEGIN
                            //                 if GVRE_VendorBankAccount.IBAN <> '' then
                            //                     "<id4>" := GVRE_VendorBankAccount.IBAN
                            //                 else
                            //                     "<Id4>" := GVRE_VendorBankAccount."Bank Account No.";
                            //             END ELSE BEGIN
                            //                 MESSAGE(Text0001, GVRE_VendorBankAccount."Vendor No.", 'Bank Account No.');
                            //                 ERROR('Bank Account No.');
                            //             END;
                            //         end;
                            //     }
                            // }

                        }
                        textelement(InstrForCdtrAgt)
                        {
                            textelement(InstrInf)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    InstrInf := '/REC/NRT';
                                end;
                            }
                        }
                        textelement(Purp)
                        {
                            textelement(PurpPrtry)
                            {
                                XmlName = 'Prtry';

                                trigger OnBeforePassVariable()
                                begin
                                    PurpPrtry := '21';
                                end;
                            }
                        }
                        textelement(RgltryRptg)
                        {
                            textelement(RgltryRptgDtls)
                            {
                                XmlName = 'Dtls';
                                textelement(RgltryRptgDtlsInf)
                                {
                                    XmlName = 'Inf';
                                    trigger OnBeforePassVariable()
                                    var
                                        resultTxt: Text;
                                        resultCode: Text;
                                        DimSetEntry: Record "Dimension Set Entry";
                                    begin
                                        Clear(resultTxt);
                                        resultTxt := '/MOF/' + GVRE_VendorBankAccount."Country/Region Code" + ' ';
                                        if "Gen. Journal Line"."Dimension Set ID" <> 0 then begin
                                            DimSetEntry.SetRange("Dimension Set ID", "Gen. Journal Line"."Dimension Set ID");
                                            DimSetEntry.SetFilter("Dimension Code", '%1', 'TRX PURPOSE');
                                            if DimSetEntry.FindSet() then
                                                resultCode := DimSetEntry."Dimension Value Code"
                                            else
                                                Error('You have not defined a value for the Transaction Purpose. Open the Line-Dimension, and define a value.');
                                        end else
                                            Error('You have not defined a value for the Dimension. Open the Dimension, and define a value.');

                                        resultTxt += resultCode;

                                        RgltryRptgDtlsInf := resultTxt;
                                    end;
                                }
                            }
                        }


                    }
                }
            }
        }
    }

    trigger OnInitXmlPort()
    begin
        "Gen. Journal Line".SETRANGE("Gen. Journal Line"."Journal Template Name", 'PAYMENTS');
        "Gen. Journal Line".SETRANGE("Gen. Journal Line"."Journal Batch Name", 'CITI');
        "Gen. Journal Line".SetFilter("Gen. Journal Line"."XML Export Completion", '%1', FALSE);
        "Gen. Journal Line".CalcFields("Bank Transfer Type");
        "Gen. Journal Line".SetFilter("Gen. Journal Line"."Bank Transfer Type", 'OVERSEAS');
    end;

    procedure PadZeroToFront(var InText: Text)
    var
        PaddedText: Text[7];
    begin
        PaddedText := StrSubstNo('%1%2', PadStr('', 7 - StrLen(InText), '0'), InText);
        InText := PaddedText;
    end;

    var
        GVTX_VendorName: Text;
        GVRE_BankAccount: Record "Bank Account";
        GVRE_VendorBankAccount: Record "Vendor Bank Account";
        Text0001: Label '%1 ''s bank %2 doesn''t exist.';
        GVIN_CtrlSum: Decimal;

}

