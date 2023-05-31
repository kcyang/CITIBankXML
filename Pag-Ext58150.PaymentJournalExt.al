pageextension 58150 PaymentJournalExt extends "Payment Journal"
{
    layout
    {
        addfirst(Control1)
        {
            field("XML Export Completion"; Rec."XML Export Completion")
            {
                Editable = false;
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addlast("F&unctions")
        {
            action(BankXMLExport)
            {
                Caption = 'Bank XML Export';
                Image = CreateXMLFile;
                Promoted = true;
                PromotedIsBig = true;
                ApplicationArea = All;
                trigger OnAction()
                var
                    lineCnt: Integer;
                begin
                    IF COMPANYNAME = 'Guerbet Japan KK' THEN BEGIN

                        GVRE_GenJournalLine.RESET;
                        GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine."Journal Template Name", 'PAYMENTS');
                        GVRE_GenJournalLine.SETRANGE(GVRE_GenJournalLine."Journal Batch Name", 'CITI');
                        IF GVRE_GenJournalLine.FIND('-') THEN BEGIN
                            Clear(lineCnt);
                            lineCnt := 0;
                            repeat
                                lineCnt += 1;
                                if GVRE_GenJournalLine."Recipient Bank Account" = '' then
                                    Error('The Recipient Bank Account is missing.\n Please check line %1.', lineCnt);
                            until GVRE_GenJournalLine.Next() = 0;
                        END;

                        GVTX_Options := '国内送金(Domestic), 海外送金(Overseas)';
                        GVTX_OptionsMessage := 'Select the type of file you want to transfer.\n These are generated based on the type of Vendor Bank Transfer Type.';
                        GVIN_OptionNumber := DIALOG.STRMENU(GVTX_Options, 1, GVTX_OptionsMessage);

                        GVCU_BankXML.GVFN_ExportData(GVIN_OptionNumber);
                        CLEAR(GVCU_BankXML);
                    END;
                end;
            }
            action(XMLUncheck)
            {
                Caption = 'Uncheck XML Item';
                Image = DeleteXML;
                Promoted = true;
                PromotedIsBig = true;
                ApplicationArea = All;
                trigger OnAction()
                begin
                    IF (Rec."Journal Template Name" = 'PAYMENTS') AND (Rec."Journal Batch Name" = 'CITI') THEN BEGIN
                        GVTX_Options := '国内送金(Domestic), 海外送金(Overseas)';
                        GVTX_OptionsMessage := 'Select the type you want to recreate.';
                        GVIN_OptionNumber := DIALOG.STRMENU(GVTX_Options, 1, GVTX_OptionsMessage);

                        GVCU_BankXML.GVFN_UncheckXML(GVIN_OptionNumber);
                    END;
                end;
            }
        }
    }


    var
        GVCU_BankXML: Codeunit BankXML;
        GVTX_Options: Text;
        GVTX_OptionsMessage: Text;
        GVIN_OptionNumber: Integer;
        GVRE_GenJournalLine: Record "Gen. Journal Line";
}
